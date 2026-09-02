from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "mcp"))
import pathfix  # noqa: E402,F401

from config import repo_root  # noqa: E402
from lua_gen import lua_value, posix  # noqa: E402
from ops import apply_bundled_palette, create_character_template, export_animation, run_lua  # noqa: E402


def paint(path: str, width: int, height: int) -> dict:
    create_character_template(path, width, height)
    apply_bundled_palette(path, "EDG32")
    char = posix(repo_root() / "lua" / "templates" / "character.lua")
    return run_lua(f"dofile({lua_value(char)})\npaint_humanoid()", path)


def main() -> None:
    char32 = "bootcamp/char_32.aseprite"
    char128 = "hd/char_128.aseprite"
    info32 = paint(char32, 32, 32)
    gif32, sheet32, _ = export_animation(char32, scale=8)
    info128 = paint(char128, 128, 128)
    gif128, sheet128, _ = export_animation(char128, scale=2)
    print("char32", info32.get("filename"), "sheet", sheet32)
    print("char128", info128.get("filename"), "sheet", sheet128)
    print("gif32", gif32)
    print("gif128", gif128)


if __name__ == "__main__":
    main()
