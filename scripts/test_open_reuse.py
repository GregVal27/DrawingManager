"""Headless check: DM.open reuses one sprite instead of stacking copies."""

from __future__ import annotations

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "mcp"))
os.environ["DM_BACKEND"] = "headless"
import pathfix  # noqa: E402,F401

from aseprite_runner import resolve_work_path, runner  # noqa: E402
from lua_gen import lua_value, posix  # noqa: E402


def main() -> None:
    dest = resolve_work_path("_open_reuse.aseprite")
    dest.parent.mkdir(parents=True, exist_ok=True)
    p = posix(dest)
    body = f"""
DM.create(16, 16, "rgb", {lua_value(p)})
DM.save({lua_value(p)})
local after_create = #app.sprites
DM.open({lua_value(p)})
DM.open({lua_value(p)})
DM.open({lua_value(p)})
DM.save({lua_value(p)})
DM.result({{
  ok = true,
  after_create = after_create,
  after_reopen = #app.sprites,
  filename = app.activeSprite.filename,
}})
"""
    result = runner().run_lua(body, title="DM: open_reuse").result
    n1 = int(result.get("after_create") or 0)
    n2 = int(result.get("after_reopen") or 0)
    print("after_create", n1, "after_reopen", n2)
    if n2 != 1:
        raise SystemExit(f"expected 1 open sprite after repeated DM.open, got {n2}")
    dest.unlink(missing_ok=True)
    dest.with_suffix(".json").unlink(missing_ok=True)
    print("ok")


if __name__ == "__main__":
    main()
