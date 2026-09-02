from __future__ import annotations

from pathlib import Path

from aseprite_runner import (
    AsepriteError,
    new_preview_path,
    resolve_work_path,
    runner,
)
from config import bundled_palettes, lua_templates
from lua_gen import lua_value, posix
from sidecar import read_sidecar, write_sidecar


def _run(body: str, title: str, transaction: bool | None = None) -> dict:
    return runner().run_lua(body, title=title, transaction=transaction).result


def open_save(path: Path, ops: str, title: str, result: str = "DM.info()") -> dict:
    p = posix(path)
    body = f"""
DM.open({lua_value(p)})
{ops}
DM.save({lua_value(p)})
DM.result({result})
"""
    return _run(body, title)


def open_only(path: Path, ops: str, title: str) -> dict:
    p = posix(path)
    body = f"""
DM.open({lua_value(p)})
{ops}
"""
    return _run(body, title)


def preview_scale_for(width: int, height: int) -> int:
    m = max(width, height)
    if m <= 32:
        return 8
    if m <= 64:
        return 4
    if m <= 128:
        return 3
    if m <= 256:
        return 2
    return 1


def sprite_info(path: str) -> dict:
    p = resolve_work_path(path)
    return open_only(
        p,
        "DM.result(DM.info())",
        "DM: info",
    )


def create_sprite(
    path: str,
    width: int,
    height: int,
    color_mode: str = "rgb",
) -> dict:
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    body = f"""
DM.create({int(width)}, {int(height)}, {lua_value(color_mode)}, {lua_value(posix(dest))})
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    return _run(body, "DM: create_sprite")


def save_sprite(path: str, dest: str | None = None) -> dict:
    src = resolve_work_path(path)
    target = resolve_work_path(dest) if dest else src
    target.parent.mkdir(parents=True, exist_ok=True)
    return open_only(
        src,
        f"DM.save({lua_value(posix(target))})\nDM.result(DM.info())",
        "DM: save_sprite",
    )


def use_clause(layer: str | None, frame: int | None) -> str:
    return f"DM.use({lua_value(layer or '')}, {lua_value(frame)})"


def add_layer(path: str, name: str, parent: str | None = None) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.add_layer({lua_value(name)}, {lua_value(parent or '')})",
        "DM: add_layer",
    )


def rename_layer(path: str, old_name: str, new_name: str) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.rename_layer({lua_value(old_name)}, {lua_value(new_name)})",
        "DM: rename_layer",
    )


def add_frames(path: str, count: int = 1) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.add_frames({int(count)})",
        "DM: add_frames",
    )


def duplicate_frame(path: str, number: int | None = None) -> dict:
    arg = "nil" if number is None else str(int(number))
    return open_save(
        resolve_work_path(path),
        f"DM.duplicate_frame({arg})",
        "DM: duplicate_frame",
    )


def set_frame_duration(path: str, number: int, ms: int) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.set_frame_duration({int(number)}, {int(ms)})",
        "DM: set_frame_duration",
    )


def create_tag(path: str, name: str, from_frame: int, to_frame: int) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.create_tag({lua_value(name)}, {int(from_frame)}, {int(to_frame)})",
        "DM: create_tag",
    )


def _template(name: str) -> str:
    return posix(lua_templates() / name)


def create_character_template(path: str, width: int = 96, height: int = 96) -> dict:
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    body = f"""
DM.create({int(width)}, {int(height)}, "rgb", {lua_value(posix(dest))})
local info = DM.create_character_template({int(width)}, {int(height)})
DM.save({lua_value(posix(dest))})
DM.result(info)
"""
    return _run(body, "DM: character_template")


def draw_pixels(path: str, pixels: list, layer: str | None = None, frame: int | None = None) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.draw_pixels({lua_value(pixels)})",
        "DM: draw_pixels",
    )


def draw_line(
    path: str,
    x1: int,
    y1: int,
    x2: int,
    y2: int,
    color: str,
    layer: str | None = None,
    frame: int | None = None,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.draw_line({int(x1)},{int(y1)},{int(x2)},{int(y2)},{lua_value(color)})",
        "DM: draw_line",
    )


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
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.draw_rect({int(x)},{int(y)},{int(w)},{int(h)},{lua_value(color)},{lua_value(filled)})",
        "DM: draw_rect",
    )


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
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.draw_ellipse({int(cx)},{int(cy)},{int(rx)},{int(ry)},{lua_value(color)},{lua_value(filled)})",
        "DM: draw_ellipse",
    )


def draw_polyline(
    path: str,
    points: list,
    color: str,
    close: bool = False,
    layer: str | None = None,
    frame: int | None = None,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.draw_polyline({lua_value(points)},{lua_value(color)},{lua_value(close)})",
        "DM: draw_polyline",
    )


def fill_area(
    path: str,
    x: int,
    y: int,
    color: str,
    layer: str | None = None,
    frame: int | None = None,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.fill_area({int(x)},{int(y)},{lua_value(color)})",
        "DM: fill_area",
    )


def add_outline(
    path: str,
    color: str,
    layer: str | None = None,
    frame: int | None = None,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"{use_clause(layer, frame)}\nDM.add_outline({lua_value(color)})",
        "DM: add_outline",
    )


def set_palette(path: str, colors: list[str]) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.set_palette({lua_value(colors)})",
        "DM: set_palette",
    )


def apply_bundled_palette(path: str, palette_id: str) -> dict:
    palettes = bundled_palettes()
    key = palette_id.strip().upper()
    if key not in palettes:
        raise AsepriteError(f"unknown palette '{palette_id}'. Known: {', '.join(sorted(palettes))}")
    gpl = palettes[key]
    if not gpl.exists():
        raise AsepriteError(f"palette file missing: {gpl}")
    return open_save(
        resolve_work_path(path),
        f"DM.apply_palette_file({lua_value(posix(gpl))})",
        "DM: apply_palette",
    )


def generate_ramp(path: str, base_color: str, steps: int = 5) -> dict:
    return open_save(
        resolve_work_path(path),
        f"local ramp = DM.generate_ramp({lua_value(base_color)}, {int(steps)})",
        "DM: generate_ramp",
        result="ramp",
    )


def run_lua(code: str, path: str | None = None) -> dict:
    if path:
        p = posix(resolve_work_path(path))
        body = f"DM.open({lua_value(p)})\n{code}\nDM.save({lua_value(p)})"
    else:
        body = code
    return _run(body, "DM: run_lua")


def undo() -> dict:
    from config import backend

    if backend() != "live":
        raise AsepriteError("undo only works when DM_BACKEND=live")
    return _run("app.undo()\nDM.result({ ok = true })", "DM: undo", transaction=False)


def export_preview_png(path: str, scale: int | None = None) -> tuple[Path, dict]:
    src = resolve_work_path(path)
    raw = new_preview_path(".png")
    info = open_only(
        src,
        f"DM.result(DM.export_flat({lua_value(posix(raw))}, 1))",
        "DM: preview_flat",
    )
    from PIL import Image as PILImage

    factor = scale if scale else preview_scale_for(int(info.get("width") or 32), int(info.get("height") or 32))
    dest = new_preview_path(".png")
    im = PILImage.open(raw)
    if factor != 1:
        im = im.resize((im.width * factor, im.height * factor), PILImage.NEAREST)
    im.save(dest)
    info["preview"] = str(dest)
    info["preview_scale"] = factor
    return dest, info


def export_animation(path: str, scale: int | None = None) -> tuple[Path, Path, dict]:
    src = resolve_work_path(path)
    info = sprite_info(str(src))
    factor = scale if scale else preview_scale_for(int(info["width"]), int(info["height"]))
    gif = new_preview_path(".gif")
    sheet = new_preview_path(".png")
    r = runner()
    r.export_image(src, gif, scale=factor)
    r.export_image(
        src,
        sheet,
        scale=factor,
        extra_args=["--sheet-type", "horizontal"],
        sheet=True,
    )
    info["gif"] = str(gif)
    info["sheet"] = str(sheet)
    info["preview_scale"] = factor
    return gif, sheet, info


def export_onion(
    path: str,
    frame: int = 1,
    prev_n: int = 2,
    next_n: int = 2,
    scale: int | None = None,
) -> tuple[Path, dict]:
    src = resolve_work_path(path)
    raw = new_preview_path(".png")
    info = open_only(
        src,
        f"DM.result(DM.onion_composite({lua_value(posix(raw))}, {int(frame)}, {int(prev_n)}, {int(next_n)}, 96))",
        "DM: onion",
    )
    from PIL import Image as PILImage

    factor = scale if scale else preview_scale_for(int(info.get("width") or 32), int(info.get("height") or 32))
    if "width" not in info:
        meta = sprite_info(str(src))
        factor = scale if scale else preview_scale_for(int(meta["width"]), int(meta["height"]))
        info.update(meta)
    dest = new_preview_path(".png")
    im = PILImage.open(raw)
    if factor != 1:
        im = im.resize((im.width * factor, im.height * factor), PILImage.NEAREST)
    im.save(dest)
    info["preview"] = str(dest)
    info["preview_scale"] = factor
    return dest, info


NATURE_SIZES = {
    "tree": (64, 96),
    "bush": (48, 48),
    "grass": (32, 32),
    "water": (64, 32),
    "rock": (32, 32),
    "cloud": (80, 32),
}


def _palette_ops(palette: str | None, count: int = 32, seed: str | None = None) -> str:
    if palette:
        key = palette.strip()
        pals = bundled_palettes()
        if key.upper() in pals:
            gpl = pals[key.upper()]
            if not gpl.exists():
                raise AsepriteError(f"palette file missing: {gpl}")
            return f"DM.apply_palette_file({lua_value(posix(gpl))})\n"
        if key.lower().endswith((".gpl", ".aseprite", ".ase")) or "/" in key or "\\" in key:
            p = Path(key)
            if not p.is_absolute():
                cand = resolve_work_path(key)
                p = cand if cand.exists() else p
            if not p.exists():
                raise AsepriteError(f"palette file missing: {p}")
            if p.suffix.lower() in (".aseprite", ".ase"):
                return f"DM.copy_palette_from({lua_value(posix(p))})\n"
            return f"DM.apply_palette_file({lua_value(posix(p))})\n"
        if key.startswith("#") or "," in key:
            colors = [c.strip() for c in key.replace(";", ",").split(",") if c.strip()]
            return f"DM.set_palette({lua_value(colors)})\n"
        raise AsepriteError(f"unknown palette '{palette}'")
    return f"DM.create_palette({int(count)}, {lua_value(seed)})\n"


def apply_user_palette(path: str, source: str | None = None, colors: list[str] | None = None) -> dict:
    if colors:
        return set_palette(path, colors)
    if not source:
        raise AsepriteError("apply_user_palette needs source or colors")
    return open_save(
        resolve_work_path(path),
        _palette_ops(source),
        "DM: apply_user_palette",
    )


def create_palette(path: str, count: int = 32, seed: str | None = None) -> dict:
    return open_save(
        resolve_work_path(path),
        f"local pal = DM.create_palette({int(count)}, {lua_value(seed)})",
        "DM: create_palette",
        result="pal",
    )


def create_character_rig(
    path: str,
    width: int = 96,
    height: int = 96,
    facing: str = "right",
) -> dict:
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    face = "left" if str(facing).lower() == "left" else "right"
    body = f"""
DM.create({int(width)}, {int(height)}, "rgb", {lua_value(posix(dest))})
DM.create_character_template({int(width)}, {int(height)})
dofile({lua_value(_template("character.lua"))})
paint_humanoid({lua_value(face)})
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    return _run(body, "DM: character_rig")


def create_tileset(
    path: str,
    columns: int | None = None,
    rows: int = 2,
    tile_size: int = 32,
    theme: str = "meadow",
    autotile: bool = True,
) -> dict:
    tile_size = int(tile_size)
    if tile_size not in (16, 32, 64):
        raise AsepriteError("tile_size must be 16, 32, or 64")
    ntiles = 16 if autotile else 7
    if columns is None:
        columns = 8 if autotile else 7
    columns = max(1, int(columns))
    rows = max(1, int(rows))
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    w, h = columns * tile_size, rows * tile_size
    paint = "DM.paint_autotile" if autotile else "DM.paint_ground_tiles"
    extra_args = f"({tile_size}, {lua_value(theme)})" if autotile else "()"
    body = f"""
DM.create({w}, {h}, "rgb", {lua_value(posix(dest))})
DM.ensure_tilemap({tile_size}, {max(ntiles, columns * rows)})
{paint}{extra_args}
local i = 1
local max_i = {ntiles}
for ty = 0, {rows} - 1 do
  for tx = 0, {columns} - 1 do
    if i <= max_i then
      DM.set_tile(tx, ty, i)
    end
    i = i + 1
  end
end
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    info = _run(body, "DM: create_tileset")
    write_sidecar(dest, {"kind": "tileset", "tile_size": tile_size, "theme": theme, "autotile": autotile})
    return info


def paint_tile(
    path: str,
    index: int,
    color: str,
    x: int = 0,
    y: int = 0,
    w: int = 32,
    h: int = 32,
    filled: bool = True,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.draw_on_tile({int(index)}, {int(x)}, {int(y)}, {int(w)}, {int(h)}, {lua_value(color)}, {lua_value(filled)})",
        "DM: paint_tile",
    )


def set_tiles(path: str, grid: list, layer: str | None = None) -> dict:
    extra = ""
    if layer:
        extra = f"-- layer hint {lua_value(layer)}\n"
    return open_save(
        resolve_work_path(path),
        extra + f"DM.set_tile_grid({lua_value(grid)})",
        "DM: set_tiles",
    )


def assemble_location(
    path: str,
    tiles_w: int = 12,
    tiles_h: int = 6,
    palette: str | None = None,
    tileset_path: str | None = None,
    tile_size: int = 32,
    theme: str = "meadow",
) -> dict:
    tiles_w = max(2, int(tiles_w))
    tiles_h = max(3, int(tiles_h))
    tile_size = int(tile_size)
    if tile_size not in (16, 32, 64):
        raise AsepriteError("tile_size must be 16, 32, or 64")
    theme = (theme or "meadow").strip().lower()
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    w, h = tiles_w * tile_size, tiles_h * tile_size
    extra = ""
    if tileset_path:
        extra = f"-- tileset reference {lua_value(posix(resolve_work_path(tileset_path)))}\n"
    body = f"""
DM.create({w}, {h}, "rgb", {lua_value(posix(dest))})
{_palette_ops(palette)}
{extra}DM.assemble_location_scaffold({tile_size}, {lua_value(theme)})
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    info = _run(body, "DM: assemble_location")
    write_sidecar(
        dest,
        {
            "kind": "location",
            "tile_size": tile_size,
            "tiles_w": tiles_w,
            "tiles_h": tiles_h,
            "palette": palette,
            "theme": theme,
        },
    )
    return info


def stamp_onto(
    path: str,
    src: str,
    layer: str,
    x: int,
    y: int,
    src_frame: int = 1,
) -> dict:
    src_p = posix(resolve_work_path(src))
    return open_save(
        resolve_work_path(path),
        f"DM.stamp_sprite({lua_value(src_p)}, {lua_value(layer)}, {int(x)}, {int(y)}, {int(src_frame)})",
        "DM: stamp_onto",
    )


DEFAULT_CREATURE_TAGS = [
    {"name": "idle", "frames": 4, "ms": 200},
    {"name": "walk", "frames": 8, "ms": 100},
    {"name": "run", "frames": 8, "ms": 80},
    {"name": "attack", "frames": 6, "ms": 90},
    {"name": "jump", "frames": 3, "ms": 80},
    {"name": "fall", "frames": 3, "ms": 100},
    {"name": "hurt", "frames": 4, "ms": 100},
    {"name": "die", "frames": 6, "ms": 120},
]

PROP_SIZES = {
    **NATURE_SIZES,
    "fire": (32, 48),
    "flag": (48, 48),
    "torch": (24, 48),
    "smoke": (32, 48),
    "wall": (32, 48),
    "floor": (32, 16),
    "door": (32, 48),
    "window": (32, 32),
    "table": (48, 32),
    "chair": (24, 32),
    "chest": (32, 24),
    "bed": (48, 32),
    "banner": (32, 48),
}

INTERIOR_KINDS = {"wall", "floor", "door", "window", "table", "chair", "chest", "bed", "banner"}


def extract_palette(path: str) -> dict:
    return open_only(
        resolve_work_path(path),
        "DM.result(DM.extract_palette())",
        "DM: extract_palette",
    )


def add_layer_group(path: str, name: str) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.add_layer_group({lua_value(name)})",
        "DM: add_layer_group",
    )


def set_layer_visible(path: str, name: str, visible: bool = True) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.set_layer_visible({lua_value(name)}, {lua_value(bool(visible))})",
        "DM: set_layer_visible",
    )


def copy_cels(path: str, from_frame: int, to_frame: int, layers: list[str] | None = None) -> dict:
    names = layers or []
    return open_save(
        resolve_work_path(path),
        f"DM.copy_cels({int(from_frame)}, {int(to_frame)}, {lua_value(names)})",
        "DM: copy_cels",
    )


def shift_cel(path: str, layer: str, frame: int, dx: int, dy: int) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.shift_cel({lua_value(layer)}, {int(frame)}, {int(dx)}, {int(dy)})",
        "DM: shift_cel",
    )


def shift_rect(
    path: str,
    layer: str,
    frame: int,
    x: int,
    y: int,
    w: int,
    h: int,
    dx: int,
    dy: int,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.shift_rect({lua_value(layer)}, {int(frame)}, {int(x)}, {int(y)}, {int(w)}, {int(h)}, {int(dx)}, {int(dy)})",
        "DM: shift_rect",
    )


def rotate_pixels(
    path: str,
    layer: str,
    frame: int,
    cx: float,
    cy: float,
    angle_deg: float,
    radius: float,
) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.rotate_pixels({lua_value(layer)}, {int(frame)}, {float(cx)}, {float(cy)}, {float(angle_deg)}, {float(radius)})",
        "DM: rotate_pixels",
    )


def clear_cel(path: str, layer: str, frame: int) -> dict:
    return open_save(
        resolve_work_path(path),
        f"DM.clear_cel({lua_value(layer)}, {int(frame)})",
        "DM: clear_cel",
    )


def _normalize_tags(tags: list | None) -> list[dict]:
    if not tags:
        return list(DEFAULT_CREATURE_TAGS)
    out = []
    for item in tags:
        if not isinstance(item, dict):
            raise AsepriteError("each tag must be {name, frames, ms?, description?}")
        name = str(item.get("name") or "").strip()
        if not name:
            raise AsepriteError("tag name required")
        out.append(
            {
                "name": name,
                "frames": max(1, int(item.get("frames") or 1)),
                "ms": int(item.get("ms") or 100),
                "description": str(item.get("description") or ""),
            }
        )
    return out


def _sidecar_tags_from_info(info: dict, descriptions: dict[str, str] | None = None, specs: list[dict] | None = None) -> list[dict]:
    descriptions = descriptions or {}
    ms_by_name = {str(t.get("name")): t.get("ms") for t in (specs or [])}
    tags = []
    for tag in info.get("tags") or []:
        name = tag.get("name")
        tags.append(
            {
                "name": name,
                "from": tag.get("from"),
                "to": tag.get("to"),
                "ms": ms_by_name.get(name),
                "description": descriptions.get(name, ""),
            }
        )
    return tags


def create_creature(
    path: str,
    width: int = 96,
    height: int = 96,
    facing: str = "right",
    complex: bool = False,
    palette: str | None = None,
    tags: list | None = None,
) -> dict:
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    face = "left" if str(facing).lower() == "left" else "right"
    tag_list = _normalize_tags(tags)
    pal = _palette_ops(palette or "EDG32")
    body = f"""
DM.create({int(width)}, {int(height)}, "rgb", {lua_value(posix(dest))})
{pal}DM.create_creature_template({int(width)}, {int(height)}, {lua_value(bool(complex))}, {lua_value(tag_list)})
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    info = _run(body, "DM: create_creature")
    descs = {t["name"]: t.get("description") or "" for t in tag_list}
    write_sidecar(
        dest,
        {
            "kind": "creature",
            "width": width,
            "height": height,
            "facing": face,
            "complex": bool(complex),
            "palette": palette or "EDG32",
            "pass": "empty",
            "tags": _sidecar_tags_from_info(info, descs, tag_list),
        },
    )
    info["sidecar"] = str(dest.with_suffix(".json"))
    info["awaiting"] = "pose_skeleton"
    return info


def pose_skeleton(path: str, tag: str | None = None, description: str | None = None, facing: str | None = None) -> dict:
    dest = resolve_work_path(path)
    meta = read_sidecar(dest)
    face = facing or meta.get("facing") or "right"
    desc = description or ""
    if not desc and tag:
        for item in meta.get("tags") or []:
            if item.get("name") == tag:
                desc = item.get("description") or ""
    body = f"""
dofile({lua_value(_template("creature.lua"))})
pose_humanoid_skeleton({lua_value(face)}, {lua_value(tag or "")}, {lua_value(desc)})
"""
    info = open_save(dest, body, "DM: pose_skeleton")
    meta["pass"] = "skeleton"
    if tag and desc:
        tags = meta.get("tags") or []
        found = False
        for item in tags:
            if item.get("name") == tag:
                item["description"] = desc
                found = True
        if not found:
            tags.append({"name": tag, "description": desc})
        meta["tags"] = tags
    write_sidecar(dest, meta)
    info["awaiting"] = "user_ok_then_paint_creature"
    info["sidecar"] = str(dest.with_suffix(".json"))
    return info


def paint_creature(path: str, tag: str | None = None, facing: str | None = None) -> dict:
    dest = resolve_work_path(path)
    meta = read_sidecar(dest)
    face = facing or meta.get("facing") or "right"
    body = f"""
dofile({lua_value(_template("creature.lua"))})
paint_creature({lua_value(face)}, {lua_value(tag or "")})
"""
    info = open_save(dest, body, "DM: paint_creature")
    meta["pass"] = "paint"
    write_sidecar(dest, meta)
    return info


def add_action(
    path: str,
    name: str,
    frames: int,
    description: str = "",
    ms: int = 100,
) -> dict:
    dest = resolve_work_path(path)
    info = sprite_info(str(dest))
    start = int(info.get("frame_count") or 1) + 1
    n = max(1, int(frames))
    end = start + n - 1
    extra = n
    body = f"""
DM.add_frames({extra})
DM.set_frame_durations({start}, {end}, {int(ms)})
DM.create_tag({lua_value(name)}, {start}, {end})
"""
    result = open_save(dest, body, "DM: add_action")
    meta = read_sidecar(dest)
    tags = list(meta.get("tags") or [])
    tags.append(
        {
            "name": name,
            "from": start,
            "to": end,
            "ms": int(ms),
            "description": description,
        }
    )
    meta["tags"] = tags
    write_sidecar(dest, meta)
    result["awaiting"] = "pose_skeleton"
    result["new_tag"] = {"name": name, "from": start, "to": end, "description": description}
    return result


def create_prop(
    path: str,
    kind: str = "tree",
    width: int | None = None,
    height: int | None = None,
    frames: int = 6,
    motion: str = "shift",
    palette: str | None = None,
) -> dict:
    kind = kind.strip().lower()
    if kind not in PROP_SIZES:
        raise AsepriteError(f"unknown prop kind '{kind}'. Known: {', '.join(sorted(PROP_SIZES))}")
    motion = (motion or "shift").strip().lower()
    if motion not in ("shift", "copy", "redraw"):
        raise AsepriteError("motion must be shift, copy, or redraw")
    dw, dh = PROP_SIZES[kind]
    if height:
        dh = int(height)
    if width:
        dw = int(width)
    frames = max(1, int(frames))
    dest = resolve_work_path(path)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with_skel = "true" if kind in ("flag", "banner", "fire") else "false"
    pal = _palette_ops(palette) if palette else ""
    body = f"""
DM.create({int(dw)}, {int(dh)}, "rgb", {lua_value(posix(dest))})
{pal}DM.create_prop_template({frames}, {with_skel})
dofile({lua_value(_template("prop.lua"))})
paint_prop({lua_value(kind)}, {lua_value(motion)})
DM.save({lua_value(posix(dest))})
DM.result(DM.info())
"""
    info = _run(body, "DM: create_prop")
    write_sidecar(
        dest,
        {
            "kind": "prop",
            "prop": kind,
            "motion": motion,
            "width": dw,
            "height": dh,
            "frames": frames,
            "interior": kind in INTERIOR_KINDS,
        },
    )
    return info


def create_nature_prop(
    path: str,
    kind: str = "tree",
    height: int | None = None,
    frames: int = 6,
    width: int | None = None,
) -> dict:
    return create_prop(path, kind=kind, width=width, height=height, frames=frames, motion="shift")


def preview_tileset_seams(path: str, scale: int | None = None) -> tuple:
    src = resolve_work_path(path)
    meta = read_sidecar(src)
    tile_size = int(meta.get("tile_size") or 32)
    raw = new_preview_path(".png")
    info = open_only(
        src,
        f"""
local ts = app.activeSprite.tilesets[1]
local sz = {tile_size}
local out = Image(ImageSpec{{ width = sz * 4, height = sz * 2, colorMode = ColorMode.RGB }})
out:clear()
local function blit(index, ox, oy)
  local tile = ts:tile(index)
  if tile then
    out:drawImage(tile.image, Point(ox, oy))
  end
end
-- 2x2 of fill
blit(1, 0, 0); blit(1, sz, 0); blit(1, 0, sz); blit(1, sz, sz)
-- grass-dirt pair
blit(14, sz * 2, 0); blit(1, sz * 2, sz)
-- water shore
blit(16, sz * 3, 0); blit(15, sz * 3, sz)
out:saveAs({lua_value(posix(raw))})
DM.result({{ ok = true, path = {lua_value(posix(raw))}, tile_size = sz, width = sz * 4, height = sz * 2 }})
""",
        "DM: tileset_seams",
    )
    from PIL import Image as PILImage

    factor = scale if scale else preview_scale_for(int(info.get("width") or 64), int(info.get("height") or 32))
    dest = new_preview_path(".png")
    im = PILImage.open(raw)
    if factor != 1:
        im = im.resize((im.width * factor, im.height * factor), PILImage.NEAREST)
    im.save(dest)
    info["preview"] = str(dest)
    info["preview_scale"] = factor
    return dest, info
