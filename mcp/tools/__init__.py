from __future__ import annotations

import json
from typing import Any

from fastmcp import FastMCP
from fastmcp.tools.tool import ToolResult
from mcp.types import TextContent

import ops
from aseprite_runner import AsepriteError, live_bridge, runner
from config import (
    aseprite_path,
    backend,
    bundled_palettes,
    live_host,
    live_port,
    set_backend as apply_backend,
    work_dir,
)
from live_relay import get_relay


def _image_cls():
    try:
        from fastmcp.utilities.types import Image
        return Image
    except ImportError:
        from fastmcp import Image
        return Image


Image = _image_cls()


def _preview_result(info: dict, image_path) -> ToolResult:
    return ToolResult(
        content=[
            TextContent(type="text", text=json.dumps(info)),
            Image(path=str(image_path)).to_image_content(),
        ],
        structured_content=info,
    )


def register(mcp: FastMCP) -> None:
    @mcp.tool()
    def status() -> dict[str, Any]:
        """Health check: Aseprite path, version, backend, live socket, work directory."""
        exe = aseprite_path()
        relay = get_relay()
        live = live_bridge()
        version = None
        error = None
        try:
            version = runner().version()
        except AsepriteError as exc:
            error = str(exc)
        return {
            "ok": error is None,
            "backend": backend(),
            "aseprite_path": str(exe),
            "aseprite_exists": exe.exists(),
            "aseprite_version": version,
            "work_dir": str(work_dir()),
            "live_host": live_host(),
            "live_port": live_port(),
            "live_connected": bool(live and live.connected()),
            "relay_started": relay is not None,
            "palettes": sorted(bundled_palettes().keys()),
            "error": error,
        }

    @mcp.tool()
    def set_backend(mode: str) -> dict[str, Any]:
        """Switch drawing backend: 'headless' (CLI) or 'live' (open Aseprite + extension)."""
        name = apply_backend(mode)
        bridge = live_bridge()
        return {"ok": True, "backend": name, "live_connected": bool(bridge and bridge.connected())}

    @mcp.tool()
    def create_sprite(path: str, width: int = 32, height: int = 32, color_mode: str = "rgb") -> dict[str, Any]:
        """Create a new .aseprite file. Relative paths resolve under work/."""
        return ops.create_sprite(path, width, height, color_mode)

    @mcp.tool()
    def open_sprite(path: str) -> dict[str, Any]:
        """Open an existing sprite and return layers, frames, and tags."""
        return ops.sprite_info(path)

    @mcp.tool()
    def save_sprite(path: str, dest: str | None = None) -> dict[str, Any]:
        """Save sprite. If dest is set, save-as to that path."""
        return ops.save_sprite(path, dest)

    @mcp.tool()
    def get_sprite_info(path: str) -> dict[str, Any]:
        """Return size, color mode, layers, frames (duration_ms), and tags."""
        return ops.sprite_info(path)

    @mcp.tool()
    def preview_sprite(path: str, scale: int | None = None) -> ToolResult:
        """Export a nearest-neighbor scaled PNG preview so the agent can see pixels."""
        dest, info = ops.export_preview_png(path, scale)
        return _preview_result(info, dest)

    @mcp.tool()
    def preview_animation(path: str, scale: int | None = None) -> ToolResult:
        """Export an animated GIF (headless) plus a horizontal frame strip PNG."""
        gif, sheet, info = ops.export_animation(path, scale)
        return _preview_result(info, sheet)

    @mcp.tool()
    def preview_onion(
        path: str,
        frame: int = 1,
        prev: int = 2,
        next_count: int = 2,
        scale: int | None = None,
    ) -> ToolResult:
        """Onion-skin composite: previous frames red, next frames blue, current on top."""
        dest, info = ops.export_onion(path, frame, prev, next_count, scale)
        return _preview_result(info, dest)

    @mcp.tool()
    def add_layer(path: str, name: str, parent: str | None = None) -> dict[str, Any]:
        """Add an empty image layer on top of the stack. Optional parent group name."""
        return ops.add_layer(path, name, parent)

    @mcp.tool()
    def rename_layer(path: str, old_name: str, new_name: str) -> dict[str, Any]:
        """Rename a layer."""
        return ops.rename_layer(path, old_name, new_name)

    @mcp.tool()
    def add_frames(path: str, count: int = 1) -> dict[str, Any]:
        """Append empty frames (no cel copy)."""
        return ops.add_frames(path, count)

    @mcp.tool()
    def duplicate_frame(path: str, number: int | None = None) -> dict[str, Any]:
        """Duplicate a frame and its cels. Defaults to the last/active frame."""
        return ops.duplicate_frame(path, number)

    @mcp.tool()
    def set_frame_duration(path: str, number: int, ms: int) -> dict[str, Any]:
        """Set one frame's duration in milliseconds."""
        return ops.set_frame_duration(path, number, ms)

    @mcp.tool()
    def create_tag(path: str, name: str, from_frame: int, to_frame: int) -> dict[str, Any]:
        """Create a named animation tag (1-based inclusive frame range)."""
        return ops.create_tag(path, name, from_frame, to_frame)

    @mcp.tool()
    def create_character_template(path: str, width: int = 96, height: int = 96) -> dict[str, Any]:
        """Create a side-on character sprite: layers silhouette/line/color/shade/fx and tags idle (1-4), walk (5-12), attack (13-16). Default 96×96."""
        return ops.create_character_template(path, width, height)

    @mcp.tool()
    def create_character_rig(
        path: str,
        width: int = 96,
        height: int = 96,
        facing: str = "right",
    ) -> dict[str, Any]:
        """Create and paint a side-on character (64–128 px canvas). Tags: idle, walk, attack. facing is 'left' or 'right'."""
        return ops.create_character_rig(path, width, height, facing)

    @mcp.tool()
    def draw_pixels(
        path: str,
        pixels: list[dict[str, Any]],
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Set individual pixels. Each item: {x, y, color} with color as #rrggbb or #rrggbbaa."""
        return ops.draw_pixels(path, pixels, layer, frame)

    @mcp.tool()
    def draw_line(
        path: str,
        x1: int,
        y1: int,
        x2: int,
        y2: int,
        color: str,
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Draw a 1px line in sprite coordinates."""
        return ops.draw_line(path, x1, y1, x2, y2, color, layer, frame)

    @mcp.tool()
    def draw_rect(
        path: str,
        x: int,
        y: int,
        w: int,
        h: int,
        color: str,
        filled: bool = True,
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Draw a rectangle. filled=true paints the interior."""
        return ops.draw_rect(path, x, y, w, h, color, filled, layer, frame)

    @mcp.tool()
    def draw_ellipse(
        path: str,
        cx: int,
        cy: int,
        rx: int,
        ry: int,
        color: str,
        filled: bool = True,
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Draw an ellipse/circle (rx=ry) centered at (cx, cy)."""
        return ops.draw_ellipse(path, cx, cy, rx, ry, color, filled, layer, frame)

    @mcp.tool()
    def draw_polyline(
        path: str,
        points: list[Any],
        color: str,
        close: bool = False,
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Stroke connected segments. Points are {x,y} or [x,y]. close=true joins last to first."""
        return ops.draw_polyline(path, points, color, close, layer, frame)

    @mcp.tool()
    def fill_area(
        path: str,
        x: int,
        y: int,
        color: str,
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """Flood-fill the contiguous region at (x, y)."""
        return ops.fill_area(path, x, y, color, layer, frame)

    @mcp.tool()
    def add_outline(
        path: str,
        color: str = "#181425",
        layer: str | None = None,
        frame: int | None = None,
    ) -> dict[str, Any]:
        """1px outline around opaque pixels of the active cel."""
        return ops.add_outline(path, color, layer, frame)

    @mcp.tool()
    def set_palette(path: str, colors: list[str]) -> dict[str, Any]:
        """Replace the sprite palette with a list of #rrggbb colors."""
        return ops.set_palette(path, colors)

    @mcp.tool()
    def apply_bundled_palette(path: str, palette_id: str = "EDG32") -> dict[str, Any]:
        """Load a bundled Aseprite palette: EDG32, EDG16, DB32, DB16, ZUGHY32, A64, ARNE16, ARNE32."""
        return ops.apply_bundled_palette(path, palette_id)

    @mcp.tool()
    def apply_user_palette(
        path: str,
        source: str | None = None,
        colors: list[str] | None = None,
    ) -> dict[str, Any]:
        """Apply a palette from bundle id, .gpl, .aseprite, comma-separated hex, or colors=[]."""
        return ops.apply_user_palette(path, source, colors)

    @mcp.tool()
    def create_palette(path: str, count: int = 32, seed: str | None = None) -> dict[str, Any]:
        """Generate a custom N-color palette (earth/foliage/sky/skin/metal ramps) and set it on the sprite."""
        return ops.create_palette(path, count, seed)

    @mcp.tool()
    def generate_ramp(path: str, base_color: str, steps: int = 5) -> dict[str, Any]:
        """Append a dark-to-light hue-shifted shading ramp to the palette."""
        return ops.generate_ramp(path, base_color, steps)

    @mcp.tool()
    def create_nature_prop(
        path: str,
        kind: str = "tree",
        height: int | None = None,
        frames: int = 6,
        width: int | None = None,
    ) -> dict[str, Any]:
        """Create a looping side-on nature prop (wraps create_prop with motion=shift)."""
        return ops.create_nature_prop(path, kind, height, frames, width)

    @mcp.tool()
    def create_tileset(
        path: str,
        columns: int | None = None,
        rows: int = 2,
        tile_size: int = 32,
        theme: str = "meadow",
        autotile: bool = True,
    ) -> dict[str, Any]:
        """Create a ground tileset. tile_size is 16, 32, or 64. autotile paints blob + grass/dirt/water seams."""
        return ops.create_tileset(path, columns, rows, tile_size, theme, autotile)

    @mcp.tool()
    def paint_tile(
        path: str,
        index: int,
        color: str,
        x: int = 0,
        y: int = 0,
        w: int = 32,
        h: int = 32,
        filled: bool = True,
    ) -> dict[str, Any]:
        """Paint a rectangle onto tileset tile index (1-based user tiles; 0 is empty)."""
        return ops.paint_tile(path, index, color, x, y, w, h, filled)

    @mcp.tool()
    def set_tiles(path: str, grid: list, layer: str | None = None) -> dict[str, Any]:
        """Set tilemap cells from a 2D array of tile indices (rows of columns, 1-based tiles, 0 empty)."""
        return ops.set_tiles(path, grid, layer)

    @mcp.tool()
    def assemble_location(
        path: str,
        tiles_w: int = 12,
        tiles_h: int = 6,
        palette: str | None = None,
        tileset_path: str | None = None,
        tile_size: int = 32,
        theme: str = "meadow",
    ) -> dict[str, Any]:
        """Create a side-on location: sky + ground tilemap + nature/furniture/characters. theme meadow|dirt|water|dungeon|interior_wood."""
        return ops.assemble_location(path, tiles_w, tiles_h, palette, tileset_path, tile_size, theme)

    @mcp.tool()
    def stamp_onto(
        path: str,
        src: str,
        layer: str,
        x: int,
        y: int,
        src_frame: int = 1,
    ) -> dict[str, Any]:
        """Stamp a flattened frame of another .aseprite onto a location layer (nature, furniture, or characters)."""
        return ops.stamp_onto(path, src, layer, x, y, src_frame)

    @mcp.tool()
    def extract_palette(path: str) -> dict[str, Any]:
        """Return hex colors from the sprite palette (also works as a palette source for apply_user_palette)."""
        return ops.extract_palette(path)

    @mcp.tool()
    def add_layer_group(path: str, name: str) -> dict[str, Any]:
        """Add a layer group (for complex creature skeleton/volume/paint stacks)."""
        return ops.add_layer_group(path, name)

    @mcp.tool()
    def set_layer_visible(path: str, name: str, visible: bool = True) -> dict[str, Any]:
        """Show or hide a layer. After skeleton approval, hide skeleton instead of deleting it."""
        return ops.set_layer_visible(path, name, visible)

    @mcp.tool()
    def copy_cels(path: str, from_frame: int, to_frame: int, layers: list[str] | None = None) -> dict[str, Any]:
        """Copy cels from one frame to another. Empty layers copies all image layers."""
        return ops.copy_cels(path, from_frame, to_frame, layers)

    @mcp.tool()
    def shift_cel(path: str, layer: str, frame: int, dx: int, dy: int) -> dict[str, Any]:
        """Nudge a cel by dx, dy pixels (shift motion)."""
        return ops.shift_cel(path, layer, frame, dx, dy)

    @mcp.tool()
    def clear_cel(path: str, layer: str, frame: int) -> dict[str, Any]:
        """Clear one cel (redraw motion)."""
        return ops.clear_cel(path, layer, frame)

    @mcp.tool()
    def create_creature(
        path: str,
        width: int = 96,
        height: int = 96,
        facing: str = "right",
        complex: bool = False,
        palette: str | None = "EDG32",
        tags: list | None = None,
    ) -> dict[str, Any]:
        """Create an empty two-pass creature (skeleton/volume/paint, default 8 tags). Does not paint. Next: pose_skeleton."""
        return ops.create_creature(path, width, height, facing, complex, palette, tags)

    @mcp.tool()
    def pose_skeleton(
        path: str,
        tag: str | None = None,
        description: str | None = None,
        facing: str | None = None,
    ) -> dict[str, Any]:
        """Pass 1: stick/volume poses. Then STOP and wait for the user to say ok before paint_creature."""
        return ops.pose_skeleton(path, tag, description, facing)

    @mcp.tool()
    def paint_creature(path: str, tag: str | None = None, facing: str | None = None) -> dict[str, Any]:
        """Pass 2: line/color/shade/fx after user approval. Hides skeleton layers."""
        return ops.paint_creature(path, tag, facing)

    @mcp.tool()
    def add_action(
        path: str,
        name: str,
        frames: int,
        description: str = "",
        ms: int = 100,
    ) -> dict[str, Any]:
        """Append a named animation with any frame count and a text brief. Then pose_skeleton for that tag."""
        return ops.add_action(path, name, frames, description, ms)

    @mcp.tool()
    def create_prop(
        path: str,
        kind: str = "tree",
        width: int | None = None,
        height: int | None = None,
        frames: int = 6,
        motion: str = "shift",
        palette: str | None = None,
    ) -> dict[str, Any]:
        """Nature or interior prop. motion is shift (1-2px), copy (clone previous), or redraw (new slides)."""
        return ops.create_prop(path, kind, width, height, frames, motion, palette)

    @mcp.tool()
    def preview_tileset_seams(path: str, scale: int | None = None) -> ToolResult:
        """PNG strip of 2x2 fill, grass-dirt, and water-shore to check tile seams."""
        dest, info = ops.preview_tileset_seams(path, scale)
        return _preview_result(info, dest)

    @mcp.tool()
    def run_lua(code: str, path: str | None = None) -> dict[str, Any]:
        """Run arbitrary Lua with the DM library loaded. If path is set, open and save that sprite. Local code execution."""
        return ops.run_lua(code, path)

    @mcp.tool()
    def undo() -> dict[str, Any]:
        """Undo the last edit. Only meaningful in live backend."""
        return ops.undo()
