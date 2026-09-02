"""Download GIFs and write a 3x3 contact sheet for caption reading."""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "docs" / "refs" / "saint11" / "_ocr-cache"
sys.path.insert(0, str(ROOT / "scripts"))
from saint11_fetch import load_ids  # noqa: E402

import urllib.request


def fetch_one(name: str, url: str) -> Path:
    CACHE.mkdir(parents=True, exist_ok=True)
    ext = Path(url).suffix or ".gif"
    dest = CACHE / f"{name}{ext}"
    if dest.exists() and dest.stat().st_size > 1000:
        return dest
    req = urllib.request.Request(url, headers={"User-Agent": "DrawingManager-docs/1.0"})
    dest.write_bytes(urllib.request.urlopen(req, timeout=60).read())
    return dest


def frames_of(src: Path) -> list[Image.Image]:
    im = Image.open(src)
    n = getattr(im, "n_frames", 1)
    out: list[Image.Image] = []
    for i in range(n):
        im.seek(i)
        out.append(im.convert("RGB"))
    return out


def pick(frames: list[Image.Image], k: int = 9) -> list[Image.Image]:
    n = len(frames)
    if n <= k:
        return frames
    idxs = [round(i * (n - 1) / (k - 1)) for i in range(k)]
    seen: set[int] = set()
    picked: list[Image.Image] = []
    for i in idxs:
        if i not in seen:
            seen.add(i)
            picked.append(frames[i])
    return picked


def montage(picked: list[Image.Image], cols: int = 3) -> Image.Image:
    w, h = picked[0].size
    rows = (len(picked) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * w, rows * h), (20, 20, 24))
    for i, fr in enumerate(picked):
        r, c = divmod(i, cols)
        sheet.paste(fr, (c * w, r * h))
    return sheet


def main() -> None:
    wanted = sys.argv[1:]
    mapping = load_ids()
    for name in wanted:
        url = mapping.get(name)
        if not url:
            print("missing", name)
            continue
        src = fetch_one(name, url)
        frames = frames_of(src)
        picked = pick(frames, 9)
        sheet = montage(picked)
        dest = CACHE / f"{name}_sheet.png"
        sheet.save(dest, optimize=True)
        print(name, "frames", len(frames), "sheet", dest.name, sheet.size)


if __name__ == "__main__":
    main()
