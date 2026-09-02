# DrawingManager

Cursor ↔ Aseprite bridge. The agent draws through MCP tools; Aseprite paints and saves `.aseprite` files under `work/`.

**Для пользователя (заказ в чате, Connect, форма брифа):** [`docs/USAGE.md`](docs/USAGE.md). Пустой шаблон: [`docs/REQUEST_FORM.md`](docs/REQUEST_FORM.md).

**Version 1.0.** Implementation plan: [`docs/PLAN.md`](docs/PLAN.md).

Style is **side-on**. Characters **64–128 px** (default 96×96). Tiles **16 / 32 / 64**. Locations = sky + tilemap + props.

## Requirements

- Windows, Aseprite 1.3+ at `Aseprite/aseprite.exe`
- Python 3.10+ (3.14 is fine)

## Setup

```powershell
cd C:\Cursor\DrawingManager
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
.\.venv\Scripts\python scripts\smoke.py
.\.venv\Scripts\python scripts\pack_extension.py
.\.venv\Scripts\python scripts\demo_v1.py
```

MCP: [`.cursor/mcp.json`](.cursor/mcp.json). Default backend is **live**. Reload until `drawing-manager` is green, open Aseprite, **File → Scripts → DrawingManager: Connect**, then `status` (`live_connected: true`).

The licensed Aseprite runtime in `Aseprite/` is gitignored. On another PC: clone this repo, put `aseprite.exe` at `Aseprite/aseprite.exe` (or set `ASEPRITE_PATH`), recreate `.venv`, run `pack_extension.py`. Palettes live under `Aseprite/data/extensions/`. Project docs and the 1.0 plan are in [`docs/PLAN.md`](docs/PLAN.md) — not in Cursor-only plan files.

## Headless vs live

- **Live** (product default): watch edits in the open editor. MCP must be running (`127.0.0.1:8765`).
- **Headless**: `aseprite.exe -b --script`. Used by scripts and GIF export (live GIF dialog would block the bridge).

Every drawing request starts with **canvas size** and **palette** (bundle, `.gpl`, hex, or palette copied from a `.aseprite`).

Creatures are two-pass: `pose_skeleton` → user «ок» in chat → `paint_creature`.

## Layout

- `docs/PLAN.md` — 1.0 plan
- `mcp/` — FastMCP server
- `lua/lib/dm.lua` — primitives
- `lua/templates/` — creature / character / nature / prop
- `work/characters|nature|interiors|tilesets|locations/` — sources (+ sidecar `.json`)
- `preview/` — agent PNG/GIF (gitignored)

## Tools (1.0 surface)

Session: `status`, `set_backend`, `create_sprite`, `open_sprite`, `save_sprite`, `get_sprite_info`  
Look: `preview_sprite`, `preview_animation`, `preview_onion`  
Timeline: `add_layer`, `add_layer_group`, `rename_layer`, `set_layer_visible`, `add_frames`, `duplicate_frame`, `set_frame_duration`, `create_tag`  
Creatures: `create_creature`, `pose_skeleton`, `paint_creature`, `add_action`, `create_character_template`, `create_character_rig`  
Cels: `copy_cels`, `shift_cel`, `clear_cel`  
Props: `create_prop`, `create_nature_prop`  
Tiles / locations: `create_tileset`, `paint_tile`, `set_tiles`, `preview_tileset_seams`, `assemble_location`, `stamp_onto`  
Draw: `draw_pixels`, `draw_line`, `draw_rect`, `draw_ellipse`, `draw_polyline`, `fill_area`, `add_outline`  
Color: `set_palette`, `apply_bundled_palette`, `apply_user_palette`, `create_palette`, `extract_palette`, `generate_ramp`  
Escape: `run_lua`, `undo` (live)

Bundled palettes: `EDG32`, `EDG16`, `DB32`, `DB16`, `ZUGHY32`, `A64`, `ARNE16`, `ARNE32`.

Default creature tags: idle, walk, run, attack, jump, fall, hurt, die (counts overridable). Prop motion: `shift` | `copy` | `redraw`.

Do not add MCP tools after 1.0 without a minor version bump.
