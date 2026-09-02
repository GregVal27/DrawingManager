"""DrawingManager 1.0 demo. Uses headless unless DM_BACKEND=live and the extension is connected."""

from __future__ import annotations

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
os.environ.setdefault("DM_BACKEND", "headless")
sys.path.insert(0, str(ROOT / "mcp"))
import pathfix  # noqa: E402,F401

from aseprite_runner import live_bridge  # noqa: E402
from config import backend  # noqa: E402
from ops import (  # noqa: E402
    add_action,
    assemble_location,
    create_creature,
    create_prop,
    create_tileset,
    export_preview_png,
    extract_palette,
    paint_creature,
    pose_skeleton,
    preview_tileset_seams,
    sprite_info,
    stamp_onto,
)


def main() -> None:
    live = live_bridge()
    if backend() == "live" and not (live and live.connected()):
        print("skip live: Aseprite extension is not connected; running headless for this demo")
        os.environ["DM_BACKEND"] = "headless"

    print("create_creature")
    create_creature("characters/v1_hero.aseprite", 96, 96, "right", False, "EDG32")
    info = sprite_info("characters/v1_hero.aseprite")
    by_tag = {t["name"]: t for t in info.get("tags") or []}
    assert by_tag["idle"]["from"] == 1 and by_tag["idle"]["to"] == 4, by_tag.get("idle")
    assert by_tag["walk"]["from"] == 5 and by_tag["walk"]["to"] == 12, by_tag.get("walk")
    assert by_tag["die"]["from"] == 37 and by_tag["die"]["to"] == 42, by_tag.get("die")
    pal = extract_palette("characters/v1_hero.aseprite")
    assert pal.get("size", 0) >= 16, pal
    pose_skeleton("characters/v1_hero.aseprite", "idle")
    # Interactive chat would STOP here. The demo paints so the repo has a complete sample.
    paint_creature("characters/v1_hero.aseprite", "idle")
    add_action(
        "characters/v1_hero.aseprite",
        "balloon_die",
        12,
        "Смерть: превращение в воздушный шарик, который лопается",
        90,
    )
    pose_skeleton(
        "characters/v1_hero.aseprite",
        "balloon_die",
        "Смерть: превращение в воздушный шарик, который лопается",
    )
    info = sprite_info("characters/v1_hero.aseprite")
    by_tag = {t["name"]: t for t in info.get("tags") or []}
    assert by_tag["die"]["to"] == 42, by_tag.get("die")
    assert by_tag["balloon_die"]["from"] == 43 and by_tag["balloon_die"]["to"] == 54, by_tag.get("balloon_die")
    dest, _ = export_preview_png("characters/v1_hero.aseprite", 2)
    print("hero still", dest)

    print("complex creature groups")
    create_creature(
        "characters/v1_beast.aseprite",
        96,
        96,
        "right",
        True,
        "EDG32",
        tags=[{"name": "idle", "frames": 2, "ms": 200}],
    )
    pose_skeleton("characters/v1_beast.aseprite", "idle")
    names = [layer["name"] for layer in sprite_info("characters/v1_beast.aseprite").get("layers") or []]
    assert "sk_head" in names and "vol_head" in names, names
    paint_creature("characters/v1_beast.aseprite", "idle")

    print("props")
    create_prop("nature/v1_fire.aseprite", "fire", frames=6, motion="redraw")
    create_prop("nature/v1_flag.aseprite", "flag", frames=6, motion="shift")
    create_prop("interiors/v1_table.aseprite", "table", frames=1, motion="redraw")
    create_prop("interiors/v1_torch.aseprite", "torch", frames=6, motion="copy")
    create_prop("interiors/v1_chair.aseprite", "chair", frames=1, motion="redraw")

    print("tileset")
    create_tileset("tilesets/v1_meadow.aseprite", tile_size=32, theme="meadow", autotile=True)
    seam, _ = preview_tileset_seams("tilesets/v1_meadow.aseprite", 4)
    print("seams", seam)

    print("location meadow")
    assemble_location("locations/v1_meadow.aseprite", 12, 6, palette="EDG32", tile_size=32, theme="meadow")
    stamp_onto("locations/v1_meadow.aseprite", "nature/v1_flag.aseprite", "nature", 40, 48)
    stamp_onto("locations/v1_meadow.aseprite", "interiors/v1_table.aseprite", "furniture", 96, 96)
    stamp_onto("locations/v1_meadow.aseprite", "interiors/v1_torch.aseprite", "furniture", 160, 64)
    stamp_onto("locations/v1_meadow.aseprite", "characters/v1_hero.aseprite", "characters", 200, 40)
    dest, info = export_preview_png("locations/v1_meadow.aseprite", 2)
    print("location", dest, info.get("width"), info.get("height"))

    print("location interior")
    assemble_location(
        "locations/v1_interior.aseprite",
        8,
        5,
        palette="EDG32",
        tile_size=32,
        theme="interior_wood",
    )
    stamp_onto("locations/v1_interior.aseprite", "interiors/v1_table.aseprite", "furniture", 80, 80)
    stamp_onto("locations/v1_interior.aseprite", "interiors/v1_chair.aseprite", "furniture", 48, 80)
    stamp_onto("locations/v1_interior.aseprite", "interiors/v1_torch.aseprite", "furniture", 200, 48)
    dest, info = export_preview_png("locations/v1_interior.aseprite", 2)
    print("interior", dest, info.get("width"), info.get("height"))
    print("ok")


if __name__ == "__main__":
    main()
