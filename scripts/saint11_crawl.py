"""Parse saint11 GIF tutorial gallery HTML into inventory.yaml."""

from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "refs" / "saint11" / "inventory.yaml"
PAGE = "https://saint11.art/blog/pixel-art-tutorials/"
BASE = "https://saint11.art"

THEME_OF: dict[str, str] = {}


def theme_for(tid: str, tags: str) -> str:
    t = (tid + " " + tags).lower()
    if any(x in t for x in ("top", "isometric", "9-slice", "ui")):
        return "topdown-ui"
    if any(x in t for x in ("walk", "run", "jump", "idle", "slide", "attack", "defend", "death", "wing", "wall")):
        return "character-motion"
    if any(x in t for x in ("fire", "smoke", "water", "wind", "electric", "explosion", "blood", "goo", "magic", "glitch", "bullet", "rocket")):
        return "vfx"
    if any(x in t for x in ("metal", "wood", "fabric", "ice", "rock", "sand", "gem", "tech", "skull")):
        return "materials"
    if any(x in t for x in ("tile", "veget", "cloud", "ruin", "city", "indoor", "star", "parallax")):
        return "environment"
    if any(x in t for x in ("sword", "firearm", "spaceship", "hazard")):
        return "props"
    if "game" in t and "design" in t:
        return "game-design"
    if any(x in t for x in ("fundament", "shading", "outline", "silhouette", "align", "pipeline", "planning", "modular", "easing", "loop", "squash", "subpixel", "1-bit", "portrait", "resiz", "illumin", "darkness", "shine", "impact")):
        return "fundamentals"
    return "misc"


def main() -> None:
    req = urllib.request.Request(PAGE, headers={"User-Agent": "DrawingManager-docs/1.0"})
    html = urllib.request.urlopen(req, timeout=45).read().decode("utf-8", "replace")
    blocks = re.findall(
        r'<div class="tutorial"[^>]*id="([^"]+)"[^>]*data-tags="([^"]*)"[^>]*>\s*<img[^>]*src="([^"]+)"',
        html,
        flags=re.I,
    )
    if not blocks:
        blocks = re.findall(
            r"id=\"([^\"]+)\"[^>]*data-tags=\"([^\"]*)\"[^>]*>.*?src=\"([^\"]+)\"",
            html,
            flags=re.I | re.S,
        )
    items = []
    seen = set()
    for tid, tags, src in blocks:
        if tid in seen:
            continue
        seen.add(tid)
        src = src.replace("&amp;", "&")
        if src.startswith("/"):
            url = BASE + src
        elif src.startswith("http"):
            url = src
        else:
            url = BASE + "/" + src.lstrip("./")
        items.append(
            {
                "id": tid,
                "url": url,
                "page": f"{PAGE}#{tid}",
                "tags": [x.strip() for x in tags.split(",") if x.strip()],
                "theme": theme_for(tid, tags),
                "status": "listed",
                "card": None,
            }
        )
    OUT.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Saint11 pixel tutorial inventory. Source: https://saint11.art/blog/pixel-art-tutorials/",
        "# License: CC BY 4.0 (Pedro Medeiros). Transcribe principles; do not copy GIFs into work/.",
        f"source: {PAGE}",
        "license: CC-BY-4.0",
        f"count: {len(items)}",
        "items:",
    ]
    for it in items:
        tags = ", ".join(it["tags"])
        lines.append(f"  - id: {it['id']}")
        lines.append(f"    url: {it['url']}")
        lines.append(f"    page: {it['page']}")
        lines.append(f"    theme: {it['theme']}")
        lines.append(f"    status: {it['status']}")
        lines.append(f"    tags: [{tags}]")
        lines.append("    card: null")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"count": len(items), "out": str(OUT), "ids": [i["id"] for i in items]}, ensure_ascii=False))


if __name__ == "__main__":
    main()
