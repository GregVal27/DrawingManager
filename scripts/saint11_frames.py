"""Extract a few frames from a GIF/PNG for OCR."""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

CACHE = Path(__file__).resolve().parent.parent / "docs" / "refs" / "saint11" / "_ocr-cache"


def main() -> None:
    name = sys.argv[1]
    srcs = list(CACHE.glob(name + ".*"))
    if not srcs:
        raise SystemExit(f"no file for {name}")
    src = srcs[0]
    im = Image.open(src)
    n = getattr(im, "n_frames", 1)
    picks = {0, n // 4, n // 2, (3 * n) // 4, n - 1} if n > 1 else {0}
    out_dir = CACHE / name
    out_dir.mkdir(exist_ok=True)
    for i in sorted(picks):
        im.seek(i)
        frame = im.convert("RGB")
        dest = out_dir / f"f{i:03d}.png"
        frame.save(dest)
        print(dest.name, frame.size, "of", n)


if __name__ == "__main__":
    main()
