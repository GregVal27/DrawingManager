"""Download saint11 GIFs into a gitignored OCR cache."""

from __future__ import annotations

import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "docs" / "refs" / "saint11" / "_ocr-cache"
INV = ROOT / "docs" / "refs" / "saint11" / "inventory.yaml"


def load_ids() -> dict[str, str]:
    ids: dict[str, str] = {}
    cur = None
    url = None
    for line in INV.read_text(encoding="utf-8").splitlines():
        if line.startswith("  - id:"):
            if cur and url:
                ids[cur] = url
            cur = line.split(":", 1)[1].strip()
            url = None
        elif line.strip().startswith("url:") and cur:
            url = line.split(":", 1)[1].strip()
    if cur and url:
        ids[cur] = url
    return ids


def main() -> None:
    wanted = sys.argv[1:]
    mapping = load_ids()
    CACHE.mkdir(parents=True, exist_ok=True)
    for name in wanted:
        url = mapping.get(name)
        if not url:
            print("missing", name)
            continue
        ext = Path(url).suffix or ".gif"
        dest = CACHE / f"{name}{ext}"
        req = urllib.request.Request(url, headers={"User-Agent": "DrawingManager-docs/1.0"})
        data = urllib.request.urlopen(req, timeout=60).read()
        dest.write_bytes(data)
        print("ok", dest.name, len(data))


if __name__ == "__main__":
    main()
