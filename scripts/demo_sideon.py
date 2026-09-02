"""Build a side-on meadow: tileset, nature loops, 96px character, location."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "mcp"))
import pathfix  # noqa: E402,F401

from ops import (  # noqa: E402
    assemble_location,
    create_character_rig,
    create_nature_prop,
    create_tileset,
    export_animation,
    export_preview_png,
    stamp_onto,
)


def main() -> None:
    tiles = create_tileset("tilesets/ground_32.aseprite", columns=7, rows=1)
    print("tileset", tiles.get("filename"), "layers", [L.get("name") for L in tiles.get("layers") or []])
    tp, tinfo = export_preview_png("tilesets/ground_32.aseprite", scale=4)
    print("tileset preview", tp)

    for kind in ("tree", "bush", "grass", "water", "rock", "cloud"):
        info = create_nature_prop(f"nature/{kind}.aseprite", kind=kind, frames=6)
        print("nature", kind, info.get("width"), info.get("height"), info.get("frame_count"))

    char = create_character_rig("characters/hero_96.aseprite", 96, 96, "right")
    print("character", char.get("filename"), "frames", char.get("frame_count"), "tags", char.get("tags"))
    _gif, sheet, _ = export_animation("characters/hero_96.aseprite", scale=2)
    print("character sheet", sheet)

    loc = assemble_location("locations/meadow.aseprite", 12, 6, palette="A64")
    print("location", loc.get("filename"), loc.get("width"), loc.get("height"))

    # Ground top is tile row (6-2)=4 → pixel y=128. Stamp feet onto grass.
    stamp_onto("locations/meadow.aseprite", "nature/tree.aseprite", "nature", 48, 32)
    stamp_onto("locations/meadow.aseprite", "nature/bush.aseprite", "nature", 140, 80)
    stamp_onto("locations/meadow.aseprite", "nature/grass.aseprite", "nature", 250, 96)
    stamp_onto("locations/meadow.aseprite", "nature/water.aseprite", "nature", 280, 128)
    stamp_onto("locations/meadow.aseprite", "characters/hero_96.aseprite", "characters", 200, 40)
    dest, info = export_preview_png("locations/meadow.aseprite", scale=2)
    print("meadow preview", dest, info.get("width"), info.get("height"))


if __name__ == "__main__":
    main()
