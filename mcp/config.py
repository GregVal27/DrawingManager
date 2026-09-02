from __future__ import annotations

import os
from pathlib import Path


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def aseprite_path() -> Path:
    raw = os.environ.get("ASEPRITE_PATH")
    if raw:
        return Path(raw)
    return repo_root() / "Aseprite" / "aseprite.exe"


def work_dir() -> Path:
    raw = os.environ.get("DM_WORK_DIR")
    if raw:
        return Path(raw)
    return repo_root() / "work"


def preview_dir() -> Path:
    raw = os.environ.get("DM_PREVIEW_DIR")
    if raw:
        return Path(raw)
    return repo_root() / "preview"


def tmp_dir() -> Path:
    raw = os.environ.get("DM_TMP_DIR")
    if raw:
        return Path(raw)
    return repo_root() / ".dm_tmp"


def lua_lib() -> Path:
    return repo_root() / "lua" / "lib" / "dm.lua"


def bundled_palettes() -> dict[str, Path]:
    ext = repo_root() / "Aseprite" / "data" / "extensions"
    return {
        "EDG32": ext / "endesga-palettes" / "edg32.gpl",
        "EDG16": ext / "endesga-palettes" / "edg16.gpl",
        "DB32": ext / "dawnbringer-palettes" / "db32.gpl",
        "DB16": ext / "dawnbringer-palettes" / "db16.gpl",
        "ZUGHY32": ext / "zughy-palettes" / "zughy-32.gpl",
        "A64": ext / "arne-palettes" / "a64.gpl",
        "ARNE16": ext / "arne-palettes" / "arne16.gpl",
        "ARNE32": ext / "arne-palettes" / "arne32.gpl",
    }


def backend() -> str:
    return os.environ.get("DM_BACKEND", "live").strip().lower()


def set_backend(name: str) -> str:
    name = name.strip().lower()
    if name not in ("headless", "live"):
        raise ValueError("backend must be 'headless' or 'live'")
    os.environ["DM_BACKEND"] = name
    return name


def live_host() -> str:
    return os.environ.get("DM_LIVE_HOST", "127.0.0.1")


def live_port() -> int:
    return int(os.environ.get("DM_LIVE_PORT", "8765"))


def lua_templates() -> Path:
    return repo_root() / "lua" / "templates"
