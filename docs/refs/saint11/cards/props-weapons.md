# Пропы: корабли, оружие, ловушки (пачка F)

Адаптация saint11, CC BY 4.0. Side-on, кроме где отмечено. Не копировать демо-оружие с GIF.

---

## Spaceships

- URL: https://saint11.art/img/pixel-tutorials/Spaceships.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#Spaceships
- Когда: корабль сбоку, выхлоп — [`vfx-extra.md`](vfx-extra.md) RocketTrail.

### Steps

- Идея из бытовых форм (геймпад, здание, эскимо, кальмар).
- Силуэт важнее всего. В космосе аэродинамика не закон. Контрастные зоны. Правила вселенной свои.
- Render: детали и свет; силуэт **править**, если деталь его ломает. Итерация thumbs ↔ render.
- Greeble: окна, фаски, антенны, повтор панелей, венты, выхлоп.

### Don'ts

- Начинать с окон до читаемого силуэта.
- Копировать корабль с GIF в `work/`.

### Для DM

- Проп, не creature. Выхлоп на `fx`. Металл — карточка Metal.

---

## FirearmDesign

- URL: https://saint11.art/img/pixel-tutorials/FirearmDesign.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#FirearmDesign
- Когда: пистолет/винтовка в руке side-on.

### Steps

- Сначала пистолет: rear/forward sight, slide, trigger, grip, magazine; позже ejection, rail, safety. Винтовка = большой пистолет + надстройки.
- Выдумка: преувеличить размер части, число винтов, обвес; или случайная масса → назначить дуло / магазин / хват.
- Смешивать типы (дробовик + энергия и т.д.).

### Don'ts

- Оружие без читаемого дула и хвата.
- Обводить подошву хвата (PIXEL_CRAFT: хват без контура).

### Для DM

- Инвентарь форм до пикселей. Металл: холодный блик. Shine по клинку/стволу — карточка Shine, не рамп кожи.

---

## Swords

- URL: https://saint11.art/img/pixel-tutorials/Swords.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#Swords
- Когда: клинок в руке, тег `attack`.

### Steps

- Анатомия по типу: viking (pommel, grip, cross-guard, fuller, edge, point); longsword (+ ridge); rapier (knuckle-guard); saber (кривая); katana (tsuba, habaki, hamon).
- Стойки разные (plow, ox, fool, wrath…) — не одна «палка вперёд».
- Атака: **wind-up** (NPC ок, игрока обычно нет) → **overshoot** + smear → **recover** самый длинный; следить за ногами.

### Don'ts

- Замах игрока в несколько кадров (AttackSheet).
- Один ромб вместо гарды/дольки/хамона, если тип задан.

### Для DM

- Молот/меч: боёк или клинок как акцент, полоска отражения (Metal). Smear на `fx`.

---

## Hazards

- URL: https://saint11.art/img/pixel-tutorials/Hazards.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#Hazards
- Когда: шипы, пила, лава, лазер в локации.

### Steps

- Всегда **tell** до срабатывания. Острые формы, дёрганый motion. Ритм, который игрок учит. Сильный импакт (вспышка/shake).
- «Скрытое» всё равно с крошечным знаком. Зона опасности: красный / ядовитый зелёный.
- Пилу **не вращать** спрайтом — fake motion blur. Пыль с потолка = «сейчас упадёт».

### Don'ts

- Ловушка без кадра-предупреждения.
- `rotate` пиксельного диска.

### Для DM

- Проп `redraw` (огонь/лава) или `shift` (капля). Tell на `fx` 1–2 кадра. Карточки Fire / Electric / Impact.
