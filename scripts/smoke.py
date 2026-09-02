from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "mcp"))
import pathfix  # noqa: E402,F401

from aseprite_runner import new_preview_path, resolve_work_path, runner  # noqa: E402
from lua_gen import lua_value, posix  # noqa: E402


def main() -> None:
    dest = resolve_work_path("_smoke.aseprite")
    dest.parent.mkdir(parents=True, exist_ok=True)
    preview = new_preview_path(".png")
    body = f"""
DM.create(32, 32, "rgb")
DM.draw_pixels({{
  {{ x=8, y=8, color="#e43b44" }},
  {{ x=9, y=8, color="#e43b44" }},
  {{ x=8, y=9, color="#3a4466" }},
  {{ x=9, y=9, color="#ead4aa" }},
}})
DM.draw_ellipse(20, 20, 6, 6, "#0d95e9", true)
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    outcome = runner().run_lua(body, title="DM: smoke")
    runner().export_image(dest, preview, scale=8)
    print("ok", outcome.result.get("filename"), "preview", preview)


if __name__ == "__main__":
    main()
