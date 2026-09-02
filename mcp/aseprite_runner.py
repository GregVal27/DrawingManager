from __future__ import annotations

import json
import os
import subprocess
import tempfile
import threading
import time
import uuid
from dataclasses import dataclass
from pathlib import Path

from config import (
    aseprite_path,
    backend,
    lua_lib,
    preview_dir,
    tmp_dir,
    work_dir,
)
from lua_gen import wrap_script


class AsepriteError(RuntimeError):
    pass


@dataclass
class RunOutcome:
    ok: bool
    result: dict
    stdout: str
    stderr: str
    elapsed_ms: int


def resolve_work_path(path: str | os.PathLike[str]) -> Path:
    p = Path(path)
    if not p.is_absolute():
        p = work_dir() / p
    return p.resolve()


def parse_dm_result(stdout: str) -> dict:
    line = None
    for raw in stdout.splitlines():
        if raw.startswith("DM_RESULT:"):
            line = raw[len("DM_RESULT:") :]
    if line is None:
        raise AsepriteError("Aseprite produced no DM_RESULT line")
    try:
        data = json.loads(line)
    except json.JSONDecodeError as exc:
        raise AsepriteError(f"invalid DM_RESULT JSON: {line}") from exc
    if not isinstance(data, dict):
        raise AsepriteError("DM_RESULT is not an object")
    return data


class LiveBridge:
    """Filled in by live_relay after the websocket server starts."""

    def execute(self, lua: str, timeout: float) -> dict:  # pragma: no cover
        raise AsepriteError("live backend is not connected")

    def connected(self) -> bool:
        return False


_live: LiveBridge | None = None


def set_live_bridge(bridge: LiveBridge | None) -> None:
    global _live
    _live = bridge


def live_bridge() -> LiveBridge | None:
    return _live


class AsepriteRunner:
    def __init__(self, exe: Path | None = None, timeout: float = 60.0) -> None:
        self.exe = Path(exe) if exe else aseprite_path()
        self.timeout = timeout

    def version(self) -> str:
        if not self.exe.exists():
            raise AsepriteError(f"Aseprite not found: {self.exe}")
        proc = subprocess.run(
            [str(self.exe), "--version"],
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        text = (proc.stdout or proc.stderr or "").strip()
        return text.splitlines()[0] if text else "unknown"

    def run_lua(
        self,
        body: str,
        title: str = "DM",
        timeout: float | None = None,
        transaction: bool | None = None,
    ) -> RunOutcome:
        started = time.perf_counter()
        timeout = self.timeout if timeout is None else timeout
        if transaction is None:
            transaction = backend() == "live"
        script = wrap_script(lua_lib(), body, title=title, transaction=transaction)
        mode = backend()
        if mode == "live":
            if _live is None or not _live.connected():
                raise AsepriteError(
                    "live backend selected but Aseprite extension is not connected. "
                    "Open Aseprite, run File > Scripts > DrawingManager: Connect "
                    "(or install the extension), then retry."
                )
            result = _live.execute(script, timeout)
            elapsed = int((time.perf_counter() - started) * 1000)
            ok = bool(result.get("ok", False))
            if not ok:
                raise AsepriteError(str(result.get("error") or result))
            return RunOutcome(ok=True, result=result, stdout="", stderr="", elapsed_ms=elapsed)
        return self._run_headless(script, timeout, started)

    def _run_headless(self, script: str, timeout: float, started: float) -> RunOutcome:
        if not self.exe.exists():
            raise AsepriteError(f"Aseprite not found: {self.exe}")
        tmp_dir().mkdir(parents=True, exist_ok=True)
        fd, name = tempfile.mkstemp(suffix=".lua", prefix="dm_", dir=str(tmp_dir()))
        path = Path(name)
        try:
            with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
                handle.write(script)
            proc = subprocess.run(
                [str(self.exe), "-b", "--script", str(path)],
                capture_output=True,
                text=True,
                timeout=timeout,
                check=False,
            )
        except subprocess.TimeoutExpired as exc:
            raise AsepriteError(f"Aseprite timed out after {timeout}s") from exc
        finally:
            try:
                path.unlink(missing_ok=True)
            except OSError:
                pass
        stdout = proc.stdout or ""
        stderr = proc.stderr or ""
        elapsed = int((time.perf_counter() - started) * 1000)
        if proc.returncode != 0 and "DM_RESULT:" not in stdout:
            raise AsepriteError(
                f"Aseprite exited {proc.returncode}: {(stderr or stdout)[-2000:]}"
            )
        result = parse_dm_result(stdout)
        if not result.get("ok", False):
            raise AsepriteError(str(result.get("error") or result))
        return RunOutcome(
            ok=True,
            result=result,
            stdout=stdout,
            stderr=stderr,
            elapsed_ms=elapsed,
        )

    def export_image(
        self,
        sprite: Path,
        dest: Path,
        *,
        scale: int | None = None,
        extra_args: list[str] | None = None,
        timeout: float | None = None,
        sheet: bool = False,
        frame: int | None = None,
    ) -> Path:
        if not self.exe.exists():
            raise AsepriteError(f"Aseprite not found: {self.exe}")
        dest.parent.mkdir(parents=True, exist_ok=True)
        cmd = [str(self.exe), "-b", str(sprite)]
        if scale and scale != 1:
            cmd.extend(["--scale", str(scale)])
        if frame is not None:
            cmd.extend(["--frame-range", f"{int(frame)},{int(frame)}"])
        if extra_args:
            cmd.extend(extra_args)
        if sheet:
            cmd.extend(["--sheet", str(dest)])
        else:
            cmd.extend(["--save-as", str(dest)])
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=self.timeout if timeout is None else timeout,
            check=False,
        )
        if proc.returncode != 0 or not dest.exists():
            raise AsepriteError(
                f"export failed: {(proc.stderr or proc.stdout or str(dest))[-2000:]}"
            )
        return dest


_runner: AsepriteRunner | None = None
_lock = threading.Lock()


def runner() -> AsepriteRunner:
    global _runner
    with _lock:
        if _runner is None:
            _runner = AsepriteRunner()
        return _runner


def new_preview_path(suffix: str) -> Path:
    preview_dir().mkdir(parents=True, exist_ok=True)
    return preview_dir() / f"{uuid.uuid4().hex}{suffix}"
