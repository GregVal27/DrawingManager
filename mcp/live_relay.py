from __future__ import annotations

import asyncio
import threading
import uuid
from dataclasses import dataclass, field

from config import live_host, live_port, lua_lib
from lua_gen import posix


class LiveNotConnected(RuntimeError):
    pass


@dataclass
class _Job:
    event: threading.Event = field(default_factory=threading.Event)
    payload: bytes = b""
    error: str | None = None


class LiveRelay:
    def __init__(self, host: str | None = None, port: int | None = None) -> None:
        self.host = host or live_host()
        self.port = port if port is not None else live_port()
        self._loop: asyncio.AbstractEventLoop | None = None
        self._thread: threading.Thread | None = None
        self._ws = None
        self._jobs: dict[str, _Job] = {}
        self._lock = threading.Lock()
        self._ready = threading.Event()

    def start(self) -> None:
        if self._thread and self._thread.is_alive():
            return
        self._thread = threading.Thread(target=self._run, name="dm-live-relay", daemon=True)
        self._thread.start()
        self._ready.wait(timeout=5)

    def connected(self) -> bool:
        return self._ws is not None

    def execute(self, lua: str, timeout: float) -> dict:
        if self._ws is None or self._loop is None:
            raise LiveNotConnected("Aseprite live extension is not connected")
        job_id = uuid.uuid4().hex
        title = "DM"
        payload = f"{job_id}\0{title}\0{lua}".encode("utf-8")
        job = _Job()
        with self._lock:
            self._jobs[job_id] = job
        fut = asyncio.run_coroutine_threadsafe(self._send(payload), self._loop)
        try:
            fut.result(timeout=5)
        except Exception as exc:
            with self._lock:
                self._jobs.pop(job_id, None)
            raise LiveNotConnected(f"failed to send to Aseprite: {exc}") from exc
        if not job.event.wait(timeout=timeout):
            with self._lock:
                self._jobs.pop(job_id, None)
            raise TimeoutError(f"live Aseprite did not reply within {timeout}s")
        with self._lock:
            self._jobs.pop(job_id, None)
        if job.error:
            raise RuntimeError(job.error)
        from aseprite_runner import parse_dm_result

        text = job.payload.decode("utf-8", errors="replace")
        if text.startswith("DM_RESULT:"):
            return parse_dm_result(text)
        return parse_dm_result("DM_RESULT:" + text)

    async def _send(self, payload: bytes) -> None:
        ws = self._ws
        if ws is None:
            raise LiveNotConnected("socket gone")
        await ws.send(payload)

    def _run(self) -> None:
        import websockets

        async def handler(ws):
            self._ws = ws
            lib = posix(lua_lib())
            hello = f"hello\0 \0{lib}".encode("utf-8")
            try:
                await ws.send(hello)
                async for message in ws:
                    if isinstance(message, bytes):
                        self._on_bytes(message)
                    elif isinstance(message, str):
                        self._on_bytes(message.encode("utf-8"))
            finally:
                if self._ws is ws:
                    self._ws = None

        async def main():
            async with websockets.serve(handler, self.host, self.port, max_size=8_000_000):
                self._ready.set()
                await asyncio.Future()

        self._loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self._loop)
        try:
            self._loop.run_until_complete(main())
        except OSError:
            self._ready.set()
            raise

    def _on_bytes(self, data: bytes) -> None:
        parts = data.split(b"\0", 2)
        if len(parts) < 3:
            text = data.decode("utf-8", errors="replace")
            if text.startswith("DM_RESULT:"):
                # no id; complete the only job
                with self._lock:
                    jobs = list(self._jobs.values())
                for job in jobs:
                    job.payload = data
                    job.event.set()
            return
        kind, job_id, rest = parts[0], parts[1].decode("utf-8"), parts[2]
        if kind.decode("utf-8") != "DM_RESULT":
            return
        with self._lock:
            job = self._jobs.get(job_id)
        if not job:
            return
        job.payload = rest
        job.event.set()


_relay: LiveRelay | None = None


def start_live_relay() -> LiveRelay:
    global _relay
    if _relay is None:
        _relay = LiveRelay()
        _relay.start()
        from aseprite_runner import set_live_bridge

        set_live_bridge(_relay)  # type: ignore[arg-type]
    return _relay


def get_relay() -> LiveRelay | None:
    return _relay
