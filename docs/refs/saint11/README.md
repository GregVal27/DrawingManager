# Saint11 craft cards — план мелкими шагами

Источник: [Pixel Art Tutorials](https://saint11.art/blog/pixel-art-tutorials/) (Pedro Medeiros / saint11).  
Лицензия: **CC BY 4.0**. Цитировать автора и URL. Принципы переписываем своими словами. **GIF и чужие спрайты не класть в `work/`.**

Канон DrawingManager не заменяется: [`docs/PIXEL_CRAFT.md`](../../PIXEL_CRAFT.md). Эти карточки — расширение (материалы, VFX, анимация). Top-down / isometric / UI — не дефолт (у нас **side-on**).

Индекс: [`inventory.yaml`](inventory.yaml) (79 уникальных `id`; у двух UI-гайдов один `id=UI`). Таблица: [`INDEX.md`](INDEX.md). Карточки: [`cards/`](cards/). Сводка: [`LEARNINGS.md`](LEARNINGS.md). Веб-галереи (Pixnote/Lospec): [`../web-anim/README.md`](../web-anim/README.md).

## Как агент пользуется этим

1. Смотри канон `PIXEL_CRAFT.md`.
2. По задаче открой карточку темы (`cards/shading-light.md`, `vfx-fire-smoke-water.md`, …).
3. Применяй **steps / don'ts / когда звать**. Не копируй пиксели с GIF.

Формат карточки:

```markdown
## {id}
- URL: …
- Когда: …
### Steps
- …
### Don'ts
- …
### Для DM
- слои / теги / 1px / sel-out …
```

Скрипты (кэш в `_ocr-cache/`, gitignored): `scripts/saint11_crawl.py`, `saint11_fetch.py`, `saint11_frames.py`, `saint11_montage.py`, `saint11_mark.py`, `saint11_index.py`.

На **один** `id` всегда одни и те же микрошаги:

1. Скачать GIF → `_ocr-cache/` (`saint11_fetch` / `saint11_montage`).
2. Собрать контакт-лист кадров с подписями.
3. Выписать captions своими словами (не копировать демо-спрайт).
4. Секции Steps / Don'ts / Для DM.
5. Одна строка в `LEARNINGS.md`, если правило новое.
6. `inventory.yaml`: `status: transcribed`, `card: cards/….md`.
7. Обновить `INDEX.md`.

Не пропускать шаг 6: иначе агент не найдёт карточку из инвентаря.

---

## Прогресс

| пачка | статус |
| --- | --- |
| 0 каталог | сделано |
| A фундамент | сделано → `fundamentals.md`, `shading-light.md` |
| B side-on движение + бой | сделано → `walk-run-jump.md`, `attack-combat.md` |
| C материалы | сделано → `materials.md` |
| D природа / VFX | сделано → `vfx-fire-smoke-water.md`, `environment-tiles.md` |
| E top-down (non-default) | сделано → `topdown-nondefault.md` |
| F UI / оружие / корабли | сделано → `ui-9slice.md`, `props-weapons.md` |
| G прочий VFX | сделано → `vfx-extra.md` |
| H тайминг и среда | сделано → `animation-theory.md`, хвост среды в `environment-tiles.md`, `game-design.md` |
| 6 свести в канон | сделано (указатели в PIXEL_CRAFT, без дубля 8 шагов) |
| 7 приёмка | готово: агент открывает карточку по теме |

---

## 0. Каталог

- [x] 0.1 Скачать HTML галереи.
- [x] 0.2 Распарсить `div.tutorial` → `inventory.yaml`.
- [x] 0.3 Сгруппировать темы → `INDEX.md`.
- [x] 0.4 `.gitignore` на `_ocr-cache/`.
- [x] 0.5 Ссылки из PIXEL_CRAFT / drawing.mdc / AGENTS.md / PLAN / sideon.

---

## 1. Пачка A — фундамент

По каждому id: микрошаги 1–7 выше.

- [x] A1 Alignment
- [x] A2 Outlines
- [x] A3 Shading
- [x] A4 Silhouette
- [x] A5 Fundamentals
- [x] A6 Fundamentals2
- [x] A7 Pipeline
- [x] A8 Planning
- [x] A9 Modular
- [x] A10 1-bit

Итог: `cards/fundamentals.md` + `cards/shading-light.md`.

---

## 2. Пачка B — side-on движение и бой

- [x] B1 Walk
- [x] B2 RunCycleSimple
- [x] B3 Jump
- [x] B4 characterIdle — bob 1px, лицо лагает, не только вертикаль
- [x] B5 Slide — roll / dash / slide, overshoot recover
- [x] B6 WallSlide — squash в стену, kick без длинного anticipation
- [x] B7 AttackSheet — без замаха у игрока, strike + recover
- [x] B8 Defend — попал, но цел; shine без шрапнели
- [x] B9 Death — extreme кадр 1, медленный recover / обрыв
- [x] B10 Wings — крыло против тела, вверх быстрее вниз

Итог: `cards/walk-run-jump.md` + `cards/attack-combat.md`.

---

## 3. Пачка C — материалы

- [x] C1 Metal — холодный блик, тёплая щель (исключение из «тень всегда холод»)
- [x] C2 Wood — фаски до текстуры, кора чешуйками
- [x] C3 Fabric — синус ветра, складки из сжатия, почти без specular
- [x] C4 Ice — снег на горизонталях, glow/трещины
- [x] C5 Rock — осадочная / метаморфическая / изверженная
- [x] C6 Sand — ветер задаёт дюну, холодная тень
- [x] C7 gems — блик на всю грань, shadow refraction
- [x] C8 Tech — швы, повтор, кабели, overshoot панелей
- [x] C9 Shine — едущая диагональ 1px, не рамп металла
- [x] C10 skull — приоритет глазница→maxilla→скула; undead-лаг суставов

Итог: `cards/materials.md`.

---

## 4. Пачка D — природа и VFX для пропов

- [x] D1 Fire
- [x] D2 SmokeSheet — одна частица целиком, contrast-кадр
- [x] D3 Water
- [x] D4 Wind — пыль/флаги, диски вихря
- [x] D5 Electric — быстро, blank-кадры
- [x] D6 Explosion — FLASH→BLAST→FIRE→SMOKE
- [x] D7 Clouds — сферы с плоским низом
- [x] D8 Vegetation — крона: силуэт→объём→край
- [x] D9 Vegetation2 — слои платформы, без случайных точек
- [x] D10 Vegetation3 — лист/ствол/мох по инвентарю форм
- [x] D11 Tiles

Итог: `cards/vfx-fire-smoke-water.md` + `cards/environment-tiles.md`.

---

## 5. Пачки E–H — остаток

Каждый id всё ещё проходит микрошаги 1–7. Top-down карточки начинать с строки **«не дефолт DM»**.

### E — top-down / isometric (non-default)

- [x] E1 Top
- [x] E2 TopDownWalkCycle
- [x] E3 TopDownRun
- [x] E4 TopDownAttack
- [x] E5 TopDownTricks
- [x] E6 Isometric

Итог (план): `cards/topdown-nondefault.md`.

### F — UI, оружие, корабли, hazards

- [x] F1 UI (9-slice; два GIF, один id)
- [x] F2 Spaceships
- [x] F3 FirearmDesign
- [x] F4 Swords
- [x] F5 Hazards

Итог (план): `cards/props-weapons.md` + `cards/ui-9slice.md`.

### G — прочий VFX

- [x] G1 Blood
- [x] G2 Goo
- [x] G3 DarkMagic
- [x] G4 LightMagic
- [x] G5 Glitch
- [x] G6 Bullets
- [x] G7 RocketTrail
- [x] G8 Holograms-Ghosts
- [x] G9 Impact
- [x] G10 Breaking

Итог (план): `cards/vfx-extra.md`.

### H — теория анимации и среда (остаток)

- [x] H1 Easings
- [x] H2 Squash
- [x] H3 Subpixel
- [x] H4 loop
- [x] H5 MotionBlur
- [x] H6 4LegsWalk
- [x] H7 IlluminationTechniques
- [x] H8 Parallax
- [x] H9 Resizing
- [x] H10 Portrait
- [x] H11 Cuteness
- [x] H12 City
- [x] H13 indoors
- [x] H14 Ruins
- [x] H15 Stars
- [x] H16 Darkness
- [x] H17 GD_LevelProgression

---

## 6. Свести в канон

- [x] Ссылки из PIXEL_CRAFT / PLAN / drawing.mdc / AGENTS.md.
- [x] В PIXEL_CRAFT: idle 1px + лаг лица; attack без замаха; squash/масса; металл почти без squash.
- [x] Не дублировать 8 шагов pass 2 (держать).
- [x] После E–H: только правила, которые усиливают кластеры / jaggies / sel-out / свет материала / позы тегов.

---

## 7. Приёмка

Запрос «нарисуй огонь / металл / walk» → агент открывает карточку, не тащит GIF в `work/`.

---

## Атрибуция

> Pixel-art technique notes adapted from Pedro Medeiros (saint11), [Pixel Art Tutorials](https://saint11.art/blog/pixel-art-tutorials/), CC BY 4.0.
