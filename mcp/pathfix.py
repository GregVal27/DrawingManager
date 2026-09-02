"""Keep the official `mcp` SDK importable; this repo folder is also named mcp."""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent


def apply() -> None:
    cleaned: list[str] = []
    seen: set[str] = set()
    for raw in sys.path:
        try:
            resolved = str(Path(raw).resolve()) if raw else str(Path.cwd().resolve())
        except OSError:
            cleaned.append(raw)
            continue
        if resolved == str(REPO):
            continue
        if resolved in seen:
            continue
        seen.add(resolved)
        cleaned.append(raw)
    sys.path[:] = cleaned
    here = str(HERE)
    if here not in sys.path:
        sys.path.insert(0, here)


apply()
