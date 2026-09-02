from collections import defaultdict
from pathlib import Path

p = Path("docs/refs/saint11/inventory.yaml")
items: list[dict] = []
cur: dict = {}
for line in p.read_text(encoding="utf-8").splitlines():
    s = line.strip()
    if s.startswith("- id:"):
        if cur:
            items.append(cur)
        cur = {"id": s.split(":", 1)[1].strip()}
    elif s.startswith("theme:") and cur:
        cur["theme"] = s.split(":", 1)[1].strip()
    elif s.startswith("url:") and cur:
        cur["url"] = s.split(":", 1)[1].strip()
    elif s.startswith("page:") and cur:
        cur["page"] = s.split(":", 1)[1].strip()
    elif s.startswith("card:") and cur:
        val = s.split(":", 1)[1].strip()
        cur["card"] = None if val in ("null", "~", "") else val
    elif s.startswith("status:") and cur:
        cur["status"] = s.split(":", 1)[1].strip()
if cur:
    items.append(cur)

by: dict[str, list] = defaultdict(list)
for it in items:
    by[it.get("theme", "misc")].append(it)

order = [
    "fundamentals",
    "character-motion",
    "materials",
    "vfx",
    "environment",
    "props",
    "topdown-ui",
    "game-design",
    "misc",
]
theme_titles = {
    "fundamentals": "Фундамент и теория",
    "character-motion": "Движение персонажа",
    "materials": "Материалы",
    "vfx": "VFX / стихии",
    "environment": "Среда / тайлы",
    "props": "Пропы / оружие",
    "topdown-ui": "Top-down / UI (не дефолт DM)",
    "game-design": "Геймдизайн",
    "misc": "Прочее",
}
lines = [
    "# Saint11 index",
    "",
    f"Всего: **{len(items)}**. С карточками: **{sum(1 for it in items if it.get('card'))}**. Источник: [галерея](https://saint11.art/blog/pixel-art-tutorials/). Карточки: [cards/](cards/). План шагов: [README.md](README.md).",
    "",
]
for th in order:
    chunk = by.get(th)
    if not chunk:
        continue
    lines.append(f"## {theme_titles.get(th, th)} ({len(chunk)})")
    lines.append("")
    lines.append("| id | карточка | ссылка |")
    lines.append("| --- | --- | --- |")
    for it in chunk:
        card = it.get("card")
        card_cell = f"[card]({card})" if card else "—"
        lines.append(f"| `{it['id']}` | {card_cell} | [gif]({it['url']}) · [page]({it['page']}) |")
    lines.append("")
Path("docs/refs/saint11/INDEX.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
print({k: len(v) for k, v in sorted(by.items())})
