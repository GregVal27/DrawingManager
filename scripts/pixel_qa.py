"""Pixel-craft QA for a DrawingManager PNG preview.

Inspects a preview at native (×1) resolution. MCP `preview_sprite` often writes
nearest-neighbor ×3/×4/×8; this script detects that scale, analyzes the 1:1
pixels, and can export ×1 and ×8 PNGs for the agent to look at.

Flags (see docs / pixel-craft plan):
  - 4-connected outline ratio (comic wrap from outline_from_volume / add_outline)
  - orphan clusters of size 1 (8-connected same color)
  - bounding-box “everything is rectangles”
  - unique colors in the opaque silhouette + dominant-fill (flat ramp)
  - --anim: inter-frame flicker (isolated color changes between tag frames)

Usage:
  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py path\\to.png
  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py path\\to.png --export
  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py path\\to.png --json
  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py --anim preview\\idle.gif
  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py --anim f2.png f3.png f4.png f5.png
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import deque
from dataclasses import asdict, dataclass, field
from pathlib import Path

from PIL import Image

Pixel = tuple[int, int, int, int]
Grid = list[list[Pixel]]
Point = tuple[int, int]

N4: tuple[Point, ...] = ((1, 0), (-1, 0), (0, 1), (0, -1))
N8: tuple[Point, ...] = N4 + ((1, 1), (1, -1), (-1, 1), (-1, -1))

ALPHA_MIN = 16
INK_LUMA = 80.0
MAX_DETECT_SCALE = 16

# Comic 4-connected wrap: most of the silhouette edge is dark ink.
OUTLINE_RATIO_FLAG = 0.75
# 2px+ contour: inward neighbor of the edge is also dark.
THICK_OUTLINE_FLAG = 0.35
# Bresenham “doubles” on a 1px stroke (diagonal pair with one cardinal corner).
DOUBLE_SHARE_FLAG = 0.12

# Size-1 clusters allowed (eye / tooth / highlight); extra orphans are noise.
ORPHAN_ALLOW = 3

# Cluster fill vs its axis-aligned bbox — 1.0 means a solid rectangle.
RECT_FILL = 0.95
RECT_PIXEL_RATIO_FLAG = 0.50
RECT_MIN_AREA = 4
RECT_MIN_SIDE = 2

# Unique colors in silhouette (96-class canvas wants a live ramp, not one hex).
UNIQUE_TOO_FEW_64 = 6
UNIQUE_TOO_FEW_96 = 12
UNIQUE_TOO_MANY = 32
DOMINANT_FILL_FLAG = 0.62

# Isolated pixel-color changes between consecutive frames (severed limb / flicker).
FLICKER_FLAG = 0.28


def luma(p: Pixel) -> float:
    return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


def is_opaque(p: Pixel) -> bool:
    return p[3] >= ALPHA_MIN


def rgb_key(p: Pixel) -> tuple[int, int, int]:
    return (p[0], p[1], p[2])


def load_grid(path: Path) -> tuple[int, int, Grid]:
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    px = im.load()
    grid = [[px[x, y] for x in range(w)] for y in range(h)]
    return w, h, grid


def detect_nn_scale(grid: Grid) -> int:
    """Largest integer nearest-neighbor upsample, or 1 if already native."""
    h = len(grid)
    w = len(grid[0]) if h else 0
    if w == 0 or h == 0:
        return 1
    for scale in range(min(MAX_DETECT_SCALE, w, h), 1, -1):
        if w % scale or h % scale:
            continue
        if _is_nn_scale(grid, w, h, scale):
            return scale
    return 1


def _is_nn_scale(grid: Grid, w: int, h: int, scale: int) -> bool:
    for y in range(h):
        src_y = y - (y % scale)
        row = grid[y]
        src_row = grid[src_y]
        for x in range(w):
            if row[x] != src_row[x - (x % scale)]:
                return False
    return True


def downsample(grid: Grid, scale: int) -> Grid:
    if scale <= 1:
        return [list(row) for row in grid]
    return [row[::scale] for row in grid[::scale]]


def grid_to_image(grid: Grid) -> Image.Image:
    h = len(grid)
    w = len(grid[0]) if h else 0
    im = Image.new("RGBA", (w, h))
    if w and h:
        im.putdata([px for row in grid for px in row])
    return im


def upscale_nn(grid: Grid, scale: int) -> Grid:
    if scale <= 1:
        return [list(row) for row in grid]
    out: Grid = []
    for row in grid:
        wide = [px for px in row for _ in range(scale)]
        for _ in range(scale):
            out.append(list(wide))
    return out


def in_bounds(x: int, y: int, w: int, h: int) -> bool:
    return 0 <= x < w and 0 <= y < h


def opaque_mask(grid: Grid) -> list[list[bool]]:
    return [[is_opaque(px) for px in row] for row in grid]


def flood_clusters(
    w: int,
    h: int,
    start_ok,
    same,
    neigh: tuple[Point, ...],
) -> list[list[Point]]:
    seen = [[False] * w for _ in range(h)]
    clusters: list[list[Point]] = []
    for y in range(h):
        for x in range(w):
            if seen[y][x] or not start_ok(x, y):
                continue
            q: deque[Point] = deque([(x, y)])
            seen[y][x] = True
            cells: list[Point] = []
            while q:
                cx, cy = q.popleft()
                cells.append((cx, cy))
                for dx, dy in neigh:
                    nx, ny = cx + dx, cy + dy
                    if not in_bounds(nx, ny, w, h) or seen[ny][nx]:
                        continue
                    if not same(cx, cy, nx, ny):
                        continue
                    seen[ny][nx] = True
                    q.append((nx, ny))
            clusters.append(cells)
    return clusters


@dataclass
class FlagResult:
    key: str
    flagged: bool
    value: float
    threshold: float
    detail: str


@dataclass
class RectCluster:
    color: str
    area: int
    bbox: list[int]  # x, y, w, h
    fill: float


@dataclass
class QaReport:
    file: str
    source_width: int
    source_height: int
    detected_scale: int
    native_width: int
    native_height: int
    opaque: int
    four_connected_outline_ratio: float
    thick_outline_ratio: float
    diagonal_doubles: int
    outline_pixels: int
    perimeter: int
    orphans: int
    orphan_ratio: float
    rect_pixel_ratio: float
    rect_clusters: int
    sizable_clusters: int
    unique_colors: int = 0
    largest_color_share: float = 0.0
    rect_examples: list[RectCluster] = field(default_factory=list)
    flags: list[FlagResult] = field(default_factory=list)
    x1_path: str | None = None
    x8_path: str | None = None
    notes: list[str] = field(default_factory=list)

    @property
    def flagged(self) -> bool:
        return any(f.flagged for f in self.flags)


def _hex(p: Pixel) -> str:
    return f"#{p[0]:02x}{p[1]:02x}{p[2]:02x}"


def _empty_report(path: str, sw: int, sh: int, scale: int, nw: int, nh: int) -> QaReport:
    report = QaReport(
        file=path,
        source_width=sw,
        source_height=sh,
        detected_scale=scale,
        native_width=nw,
        native_height=nh,
        opaque=0,
        four_connected_outline_ratio=0.0,
        thick_outline_ratio=0.0,
        diagonal_doubles=0,
        outline_pixels=0,
        perimeter=0,
        orphans=0,
        orphan_ratio=0.0,
        rect_pixel_ratio=0.0,
        rect_clusters=0,
        sizable_clusters=0,
        notes=["no opaque pixels"],
    )
    report.flags = [
        FlagResult("four_connected_outline", False, 0.0, OUTLINE_RATIO_FLAG, "empty"),
        FlagResult("orphans", False, 0.0, float(ORPHAN_ALLOW), "empty"),
        FlagResult("rectangles", False, 0.0, RECT_PIXEL_RATIO_FLAG, "empty"),
        FlagResult("unique_colors_few", False, 0.0, float(UNIQUE_TOO_FEW_64), "empty"),
        FlagResult("unique_colors_many", False, 0.0, float(UNIQUE_TOO_MANY), "empty"),
        FlagResult("dominant_fill", False, 0.0, DOMINANT_FILL_FLAG, "empty"),
    ]
    return report


def analyze_grid(grid: Grid) -> dict:
    """Return metric dict used to build QaReport (without file/scale metadata)."""
    h = len(grid)
    w = len(grid[0]) if h else 0
    opaque = opaque_mask(grid)
    opaque_pts = [(x, y) for y in range(h) for x in range(w) if opaque[y][x]]
    n_opaque = len(opaque_pts)
    if n_opaque == 0:
        return {"opaque": 0}

    def has_empty_4(x: int, y: int) -> bool:
        for dx, dy in N4:
            nx, ny = x + dx, y + dy
            if not in_bounds(nx, ny, w, h) or not opaque[ny][nx]:
                return True
        return False

    perimeter_pts = [p for p in opaque_pts if has_empty_4(*p)]
    perimeter = len(perimeter_pts)

    def is_ink(x: int, y: int) -> bool:
        return opaque[y][x] and luma(grid[y][x]) <= INK_LUMA

    dark_perim = [(x, y) for x, y in perimeter_pts if is_ink(x, y)]
    four_ratio = (len(dark_perim) / perimeter) if perimeter else 0.0

    def ink_n8(x: int, y: int) -> int:
        n = 0
        for dx, dy in N8:
            nx, ny = x + dx, y + dy
            if in_bounds(nx, ny, w, h) and is_ink(nx, ny):
                n += 1
        return n

    # 2px contour = empty | ink | ink | body. A dark fill meeting the edge is not thick ink.
    thick = 0
    for x, y in dark_perim:
        band = False
        for dx, dy in N4:
            nx, ny = x + dx, y + dy
            empty = not in_bounds(nx, ny, w, h) or not opaque[ny][nx]
            if not empty:
                continue
            ix, iy = x - dx, y - dy
            if not (in_bounds(ix, iy, w, h) and is_ink(ix, iy)):
                continue
            jx, jy = x - 2 * dx, y - 2 * dy
            if not in_bounds(jx, jy, w, h) or not is_ink(jx, jy):
                band = True
                break
        if band:
            thick += 1
    thick_ratio = (thick / len(dark_perim)) if dark_perim else 0.0

    # Doubles on a 1px stroke, not on the staircase of a filled dark mass.
    thin = {(x, y) for x, y in dark_perim if ink_n8(x, y) <= 4}
    doubles = 0
    for x, y in thin:
        for dx, dy in ((1, 1), (1, -1)):
            nx, ny = x + dx, y + dy
            if (nx, ny) not in thin:
                continue
            c1 = (x + dx, y) in thin
            c2 = (x, y + dy) in thin
            if c1 != c2:
                doubles += 1
    outline = {(x, y) for x, y in dark_perim}

    def same_color(ax: int, ay: int, bx: int, by: int) -> bool:
        return rgb_key(grid[ay][ax]) == rgb_key(grid[by][bx]) and opaque[by][bx]

    color_clusters = flood_clusters(
        w,
        h,
        start_ok=lambda x, y: opaque[y][x],
        same=same_color,
        neigh=N8,
    )
    orphans = sum(1 for c in color_clusters if len(c) == 1)
    orphan_ratio = orphans / n_opaque

    sizable = [c for c in color_clusters if len(c) >= RECT_MIN_AREA]
    rects: list[RectCluster] = []
    rect_pixels = 0
    for cells in sizable:
        xs = [p[0] for p in cells]
        ys = [p[1] for p in cells]
        minx, maxx = min(xs), max(xs)
        miny, maxy = min(ys), max(ys)
        bw = maxx - minx + 1
        bh = maxy - miny + 1
        if min(bw, bh) < RECT_MIN_SIDE:
            continue
        area = len(cells)
        fill = area / float(bw * bh)
        if fill >= RECT_FILL:
            px0 = grid[cells[0][1]][cells[0][0]]
            rects.append(
                RectCluster(
                    color=_hex(px0),
                    area=area,
                    bbox=[minx, miny, bw, bh],
                    fill=round(fill, 4),
                )
            )
            rect_pixels += area
    rect_pixel_ratio = rect_pixels / n_opaque
    rects.sort(key=lambda r: r.area, reverse=True)

    counts: dict[tuple[int, int, int], int] = {}
    for x, y in opaque_pts:
        key = rgb_key(grid[y][x])
        counts[key] = counts.get(key, 0) + 1
    unique_colors = len(counts)
    largest = max(counts.values()) if counts else 0
    largest_color_share = largest / n_opaque if n_opaque else 0.0
    min_side = min(w, h)
    few_thresh = UNIQUE_TOO_FEW_96 if min_side >= 80 else UNIQUE_TOO_FEW_64
    few_flag = unique_colors < few_thresh
    many_flag = unique_colors > UNIQUE_TOO_MANY
    dominant_flag = largest_color_share >= DOMINANT_FILL_FLAG

    outline_flag = False
    outline_reasons: list[str] = []
    if four_ratio >= OUTLINE_RATIO_FLAG:
        outline_flag = True
        outline_reasons.append(
            f"{four_ratio:.2f} of 4-connected silhouette edge is dark ink "
            f"(>= {OUTLINE_RATIO_FLAG:.2f})"
        )
    if thick_ratio >= THICK_OUTLINE_FLAG and dark_perim:
        outline_flag = True
        outline_reasons.append(
            f"thick inward outline {thick_ratio:.2f} (>= {THICK_OUTLINE_FLAG:.2f})"
        )
    double_share = (doubles / len(thin)) if thin else 0.0
    if thin and double_share >= DOUBLE_SHARE_FLAG and doubles >= 6:
        outline_flag = True
        outline_reasons.append(
            f"{doubles} diagonal doubles ({double_share:.2f} of thin ink edge, "
            f">= {DOUBLE_SHARE_FLAG:.2f})"
        )
    if not outline_reasons:
        outline_reasons.append(
            f"{four_ratio:.2f} of 4-edge is dark; thick={thick_ratio:.2f}; "
            f"doubles={doubles}"
        )

    orphan_allow = ORPHAN_ALLOW
    orphan_flag = orphans > orphan_allow
    rect_flag = rect_pixel_ratio >= RECT_PIXEL_RATIO_FLAG

    flags = [
        FlagResult(
            key="four_connected_outline",
            flagged=outline_flag,
            value=round(four_ratio, 4),
            threshold=OUTLINE_RATIO_FLAG,
            detail="; ".join(outline_reasons),
        ),
        FlagResult(
            key="orphans",
            flagged=orphan_flag,
            value=float(orphans),
            threshold=float(orphan_allow),
            detail=(
                f"{orphans} size-1 8-connected color clusters "
                f"({orphan_ratio:.1%} of opaque); allow {orphan_allow}"
            ),
        ),
        FlagResult(
            key="rectangles",
            flagged=rect_flag,
            value=round(rect_pixel_ratio, 4),
            threshold=RECT_PIXEL_RATIO_FLAG,
            detail=(
                f"{rect_pixel_ratio:.2f} of opaque pixels sit in bbox-filled clusters "
                f"({len(rects)}/{len(sizable)} sizable); threshold {RECT_PIXEL_RATIO_FLAG:.2f}"
            ),
        ),
        FlagResult(
            key="unique_colors_few",
            flagged=few_flag,
            value=float(unique_colors),
            threshold=float(few_thresh),
            detail=(
                f"{unique_colors} unique RGB in silhouette; "
                f"want >={few_thresh} on {w}x{h} (live ramp, not one hex)"
            ),
        ),
        FlagResult(
            key="unique_colors_many",
            flagged=many_flag,
            value=float(unique_colors),
            threshold=float(UNIQUE_TOO_MANY),
            detail=(
                f"{unique_colors} unique RGB in silhouette; "
                f"want <={UNIQUE_TOO_MANY} (orphans / noise, not a longer ramp)"
            ),
        ),
        FlagResult(
            key="dominant_fill",
            flagged=dominant_flag,
            value=round(largest_color_share, 4),
            threshold=DOMINANT_FILL_FLAG,
            detail=(
                f"largest color is {largest_color_share:.0%} of opaque "
                f"(>={DOMINANT_FILL_FLAG:.0%} = flat hide/fill)"
            ),
        ),
    ]

    return {
        "opaque": n_opaque,
        "four_connected_outline_ratio": round(four_ratio, 4),
        "thick_outline_ratio": round(thick_ratio, 4),
        "diagonal_doubles": doubles,
        "outline_pixels": len(outline),
        "perimeter": perimeter,
        "orphans": orphans,
        "orphan_ratio": round(orphan_ratio, 4),
        "rect_pixel_ratio": round(rect_pixel_ratio, 4),
        "rect_clusters": len(rects),
        "sizable_clusters": len(sizable),
        "unique_colors": unique_colors,
        "largest_color_share": round(largest_color_share, 4),
        "rect_examples": rects[:8],
        "flags": flags,
    }


def analyze_png(
    path: Path,
    *,
    scale: int | None = None,
    export_dir: Path | None = None,
) -> QaReport:
    sw, sh, source = load_grid(path)
    detected = detect_nn_scale(source) if scale is None else max(1, int(scale))
    native = downsample(source, detected)
    nw = len(native[0]) if native else 0
    nh = len(native)
    metrics = analyze_grid(native)
    if metrics.get("opaque", 0) == 0:
        report = _empty_report(str(path), sw, sh, detected, nw, nh)
    else:
        report = QaReport(
            file=str(path),
            source_width=sw,
            source_height=sh,
            detected_scale=detected,
            native_width=nw,
            native_height=nh,
            opaque=int(metrics["opaque"]),
            four_connected_outline_ratio=float(metrics["four_connected_outline_ratio"]),
            thick_outline_ratio=float(metrics["thick_outline_ratio"]),
            diagonal_doubles=int(metrics["diagonal_doubles"]),
            outline_pixels=int(metrics["outline_pixels"]),
            perimeter=int(metrics["perimeter"]),
            orphans=int(metrics["orphans"]),
            orphan_ratio=float(metrics["orphan_ratio"]),
            rect_pixel_ratio=float(metrics["rect_pixel_ratio"]),
            rect_clusters=int(metrics["rect_clusters"]),
            sizable_clusters=int(metrics["sizable_clusters"]),
            unique_colors=int(metrics.get("unique_colors", 0)),
            largest_color_share=float(metrics.get("largest_color_share", 0.0)),
            rect_examples=list(metrics["rect_examples"]),
            flags=list(metrics["flags"]),
        )
        report.notes.append(
            f"analysis at x1 ({nw}x{nh}); inspect stairs/doubles on x8 "
            f"({nw * 8}x{nh * 8} nearest-neighbor)"
        )

    if export_dir is not None:
        export_dir.mkdir(parents=True, exist_ok=True)
        stem = path.stem
        x1_path = export_dir / f"{stem}_x1.png"
        x8_path = export_dir / f"{stem}_x8.png"
        grid_to_image(native).save(x1_path)
        grid_to_image(upscale_nn(native, 8)).save(x8_path)
        report.x1_path = str(x1_path)
        report.x8_path = str(x8_path)

    return report


def report_to_dict(report: QaReport) -> dict:
    data = asdict(report)
    data["flagged"] = report.flagged
    data["flag_count"] = sum(1 for f in report.flags if f.flagged)
    return data


def format_report(report: QaReport) -> str:
    lines = [
        "=== pixel_qa ===",
        f"file: {report.file}",
        (
            f"source: {report.source_width}x{report.source_height}  "
            f"nn_scale: x{report.detected_scale}  "
            f"native: {report.native_width}x{report.native_height}  "
            f"opaque: {report.opaque}"
        ),
    ]
    if report.x1_path or report.x8_path:
        lines.append(f"x1: {report.x1_path}")
        lines.append(f"x8: {report.x8_path}")
    lines.append("")
    lines.append("FLAGS")
    for flag in report.flags:
        mark = "FLAG" if flag.flagged else "ok  "
        lines.append(
            f"  [{mark}] {flag.key:24}  {flag.value}  (threshold {flag.threshold})"
        )
        lines.append(f"         {flag.detail}")
    extra = (
        f"         perimeter={report.perimeter}  outline_ink={report.outline_pixels}  "
        f"thick={report.thick_outline_ratio}  doubles={report.diagonal_doubles}  "
        f"unique={report.unique_colors}  dominant={report.largest_color_share:.0%}"
    )
    lines.append(extra)
    if report.rect_examples:
        bits = [
            f"{ex.color} {ex.bbox[2]}x{ex.bbox[3]}@{ex.bbox[0]},{ex.bbox[1]}"
            for ex in report.rect_examples[:5]
        ]
        lines.append("         rect bboxes: " + "; ".join(bits))
    lines.append("")
    nflag = sum(1 for f in report.flags if f.flagged)
    if report.opaque == 0:
        lines.append("RESULT: EMPTY")
    elif nflag:
        lines.append(f"RESULT: FAIL  {nflag} flag(s)")
    else:
        lines.append("RESULT: PASS")
    for note in report.notes:
        lines.append(note)
    return "\n".join(lines)


def native_grid(path: Path, scale: int | None = None) -> Grid:
    _w, _h, source = load_grid(path)
    detected = detect_nn_scale(source) if scale is None else max(1, int(scale))
    return downsample(source, detected)


def gif_frame_grids(path: Path, scale: int | None = None) -> list[Grid]:
    im = Image.open(path)
    frames: list[Grid] = []
    index = 0
    while True:
        frame = im.convert("RGBA")
        w, h = frame.size
        px = frame.load()
        grid: Grid = [[px[x, y] for x in range(w)] for y in range(h)]
        detected = detect_nn_scale(grid) if scale is None else max(1, int(scale))
        frames.append(downsample(grid, detected))
        index += 1
        try:
            im.seek(index)
        except EOFError:
            break
    return frames


def pair_flicker(a: Grid, b: Grid) -> dict:
    """Share of changed pixels that sit in size-1 8-connected change clusters."""
    ha, wa = len(a), (len(a[0]) if a else 0)
    hb, wb = len(b), (len(b[0]) if b else 0)
    h, w = min(ha, hb), min(wa, wb)
    changed: list[Point] = []
    xor_sil = 0
    for y in range(h):
        for x in range(w):
            oa = is_opaque(a[y][x])
            ob = is_opaque(b[y][x])
            if oa != ob:
                xor_sil += 1
            if oa or ob:
                if (not oa) or (not ob) or rgb_key(a[y][x]) != rgb_key(b[y][x]):
                    changed.append((x, y))
    n_ch = len(changed)
    if n_ch == 0:
        return {
            "changed": 0,
            "flicker": 0.0,
            "isolated": 0,
            "silhouette_xor": xor_sil,
        }
    chset = set(changed)
    clusters = flood_clusters(
        w,
        h,
        start_ok=lambda x, y: (x, y) in chset,
        same=lambda _ax, _ay, nx, ny: (nx, ny) in chset,
        neigh=N8,
    )
    isolated = sum(1 for c in clusters if len(c) == 1)
    return {
        "changed": n_ch,
        "flicker": round(isolated / n_ch, 4),
        "isolated": isolated,
        "silhouette_xor": xor_sil,
        "change_clusters": len(clusters),
    }


def collect_anim_grids(inputs: list[Path], scale: int | None = None) -> list[tuple[str, Grid]]:
    if len(inputs) == 1 and inputs[0].is_dir():
        files = sorted(
            p for p in inputs[0].iterdir() if p.suffix.lower() in {".png", ".gif"}
        )
        if not files:
            raise FileNotFoundError(f"no png/gif in {inputs[0]}")
        return collect_anim_grids(files, scale=scale)
    out: list[tuple[str, Grid]] = []
    for path in inputs:
        if not path.exists():
            raise FileNotFoundError(str(path))
        if path.is_dir():
            out.extend(collect_anim_grids([path], scale=scale))
            continue
        suffix = path.suffix.lower()
        if suffix == ".gif":
            for i, grid in enumerate(gif_frame_grids(path, scale=scale)):
                out.append((f"{path}#f{i + 1}", grid))
        else:
            out.append((str(path), native_grid(path, scale=scale)))
    return out


def analyze_anim(
    inputs: list[Path],
    *,
    scale: int | None = None,
) -> dict:
    labeled = collect_anim_grids(inputs, scale=scale)
    stills = []
    keep = (
        "opaque",
        "unique_colors",
        "largest_color_share",
        "orphans",
        "orphan_ratio",
        "rect_pixel_ratio",
    )
    for name, grid in labeled:
        metrics = analyze_grid(grid)
        row = {"file": name}
        for k in keep:
            if k in metrics:
                row[k] = metrics[k]
        row["flagged"] = any(f.flagged for f in metrics.get("flags", []))
        stills.append(row)
    pairs = []
    worst = 0.0
    for i in range(len(labeled) - 1):
        stats = pair_flicker(labeled[i][1], labeled[i + 1][1])
        stats["from"] = labeled[i][0]
        stats["to"] = labeled[i + 1][0]
        stats["flagged"] = stats["flicker"] >= FLICKER_FLAG and stats["changed"] >= 8
        pairs.append(stats)
        if stats["flicker"] > worst:
            worst = stats["flicker"]
    seam = None
    if len(labeled) >= 2:
        seam = pair_flicker(labeled[-1][1], labeled[0][1])
        seam["from"] = labeled[-1][0]
        seam["to"] = labeled[0][0]
        seam["flagged"] = seam["flicker"] >= FLICKER_FLAG and seam["changed"] >= 8
        if seam["flicker"] > worst:
            worst = seam["flicker"]
    flagged = any(p["flagged"] for p in pairs) or (seam["flagged"] if seam else False)
    return {
        "kind": "anim",
        "frames": len(labeled),
        "worst_flicker": round(worst, 4),
        "flicker_threshold": FLICKER_FLAG,
        "pairs": pairs,
        "loop_seam": seam,
        "stills": stills,
        "flagged": flagged,
    }


def format_anim(report: dict) -> str:
    lines = [
        "=== pixel_qa --anim ===",
        f"frames: {report['frames']}  worst_flicker: {report['worst_flicker']}  "
        f"threshold: {report['flicker_threshold']}",
        "",
    ]
    for p in report["pairs"]:
        mark = "FLAG" if p["flagged"] else "ok  "
        lines.append(
            f"  [{mark}] {p['from']} -> {p['to']}  "
            f"flicker={p['flicker']}  changed={p['changed']}  "
            f"isolated={p['isolated']}  sil_xor={p['silhouette_xor']}"
        )
    if report.get("loop_seam"):
        s = report["loop_seam"]
        mark = "FLAG" if s["flagged"] else "ok  "
        lines.append(
            f"  [{mark}] loop seam {s['from']} -> {s['to']}  "
            f"flicker={s['flicker']}  changed={s['changed']}"
        )
    lines.append("")
    n_still_flag = sum(1 for s in report["stills"] if s.get("flagged"))
    lines.append(f"still flags in {n_still_flag}/{len(report['stills'])} frames")
    lines.append("RESULT: FAIL" if report["flagged"] else "RESULT: PASS")
    return "\n".join(lines)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description=(
            "QA a pixel-art PNG preview: 4-connected outline wrap, "
            "orphan 1px clusters, rectangle bounding-box heuristic, "
            "unique silhouette colors; --anim for tag flicker."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "examples:\n"
            "  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py preview\\foo.png\n"
            "  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py preview\\foo.png --export\n"
            "  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py --anim preview\\idle.gif\n"
            "  .\\.venv\\Scripts\\python.exe scripts\\pixel_qa.py --anim f2.png f3.png f4.png\n"
        ),
    )
    p.add_argument(
        "inputs",
        nargs="+",
        type=Path,
        help="Preview PNG, or with --anim a GIF / directory / frame list",
    )
    p.add_argument(
        "--anim",
        action="store_true",
        help="Compare consecutive frames (GIF, directory, or listed PNGs)",
    )
    p.add_argument(
        "--scale",
        type=int,
        default=None,
        help="Force NN downsample factor (1 = already native). Default: auto-detect",
    )
    p.add_argument(
        "--export",
        action="store_true",
        help="Write <stem>_x1.png and <stem>_x8.png (native + nearest x8)",
    )
    p.add_argument(
        "--outdir",
        type=Path,
        default=None,
        help="Directory for --export (default: same folder as the PNG)",
    )
    p.add_argument("--json", action="store_true", help="Print JSON instead of text")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.anim:
        try:
            report = analyze_anim(list(args.inputs), scale=args.scale)
        except (OSError, FileNotFoundError) as exc:
            print(f"pixel_qa: cannot read anim: {exc}", file=sys.stderr)
            return 2
        if args.json:
            print(json.dumps(report, indent=2))
        else:
            print(format_anim(report))
        return 1 if report["flagged"] else 0

    path: Path = args.inputs[0]
    if not path.is_file():
        print(f"pixel_qa: file not found: {path}", file=sys.stderr)
        return 2
    export_dir = None
    if args.export or args.outdir is not None:
        export_dir = args.outdir if args.outdir is not None else path.parent
    try:
        report = analyze_png(path, scale=args.scale, export_dir=export_dir)
    except OSError as exc:
        print(f"pixel_qa: cannot read image: {exc}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report_to_dict(report), indent=2))
    else:
        print(format_report(report))
    if report.opaque == 0:
        return 0
    return 1 if report.flagged else 0


if __name__ == "__main__":
    sys.exit(main())
