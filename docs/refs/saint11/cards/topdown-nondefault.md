# Top-down / isometric (пачка E) — не дефолт DM

Адаптация saint11, CC BY 4.0. **Вид DM по умолчанию — side-on.** Эти карточки только если пользователь явно просит top-down / iso.

---

## Top

- URL: https://saint11.art/img/pixel-tutorials/Top-Down-Houses-Compressed.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#Top
- Когда: дом сверху, только по заказу top-down.

### Steps

1. Начать с коробок; складывать L/T, штабеля.
2. Крыша чуть больше коробки.
3. Гнуть линии; чуть fake-perspective; динамичнее массы.
4. Двери/окна блоками → глубина → свет/тень → текстуры.
5. Цоколь «выпрямляет» силуэт у земли.

### Don'ts

- Fake-perspective рядом с честной 3:4 сеткой — ломает стык.
- Текстура крыши до объёма.

### Для DM

- Не собирать локацию из этих домов, пока вид не top-down. Side-on интерьер — карточка `indoors`.

---

## TopDownWalkCycle

- URL: https://saint11.art/img/pixel-tutorials/TopDownWalkCycle.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#TopDownWalkCycle
- Когда: персонаж сверху (не дефолт).

### Steps

- Idle первым. Стек: стопы за ногами, ноги за торсом, торс за головой.
- Нога вперёд + рука **той же стороны** назад. Три кадра, потом **горизонтальный flip** на вторую ногу (6 кадров база).
- Дублировать кадры → in-between + bob.
- Вверх (спиной): меньше вертикали у торса/головы, та же логика.
- Боком: сильный контраст кистей и стоп; ближе к platform walk.

### Don'ts

- Путать с side-on Walk (там руки **против** ног).

### Для DM

- Дефолт walk — [`walk-run-jump.md`](walk-run-jump.md). Этот цикл не подставлять в `facing` right side-on.

---

## TopDownRun

- URL: https://saint11.art/img/pixel-tutorials/TopDownRun.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#TopDownRun
- Когда: бег сверху.

### Steps

- Голова / тело / стопы — три пятна друг над другом.
- Минимум 4 кадра вниз: вторая половина = flip первой, кроме волос и асимметрий.
- 3 кадра растянутых ног (волосы/ткань вверх) + 2 кадра смены ног (низшая точка). Бок и спина — та же схема.
- Руки преувеличить. Альтернатива: platformer run, дальняя нога почти скрыта.

### Don'ts

- Flip вместе с асимметричным волосом.

### Для DM

- Side-on run — 4 ключа × 2 ноги и фаза в воздухе ([`walk-run-jump.md`](walk-run-jump.md)).

---

## TopDownAttack

- URL: https://saint11.art/img/pixel-tutorials/TopDownAttack.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#TopDownAttack
- Когда: удар сверху.

### Steps

- Слои «налегают» вперёд. Противофаза руки/ноги; одна стопа на земле; голову чуть повернуть.
- Anticipation: оружие **от** цели. У **игрока** обычно пропускать (лаг).
- Slash: первый кадр = полный жест + большой smear; дальше стабилизация, blur гаснет.
- Recover другой дугой, last-frame overshoot.

### Don'ts

- Замах у игрока в несколько кадров.

### Для DM

- Та же идея, что AttackSheet: игрок без anticipation. Smear на `fx`.

---

## TopDownTricks

- URL: https://saint11.art/img/pixel-tutorials/TopDownTricks.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#TopDownTricks
- Когда: сортировка спрайтов в движке (не рисование кадра).

### Steps

- `order = pos.Y + offset`; offset у низа коллизии; у летающего — у воображаемой точки на земле.
- Высокие/L-формы резать на куски, у каждого свой Y-sort.
- Коллайдер = проекция на пол, не высота спрайта.
- Слои GROUND / OBJECTS для крупных групп.

### Don'ts

- Один спрайт всего здания для Y-sort (нельзя пройти «за крышу»).
- Коллайдер по силуэту на всю высоту дерева.

### Для DM

- `assemble_location` — слои sky/ground/nature/furniture/characters, не Y-sort. Эта карточка для экспорта в игру, не для Aseprite-кадра.

---

## Isometric

- URL: https://saint11.art/img/pixel-tutorials/Isometric.gif
- Страница: https://saint11.art/blog/pixel-art-tutorials/#Isometric
- Когда: явно iso, не side-on.

### Steps

- Сетка **2:1** (2 px по X, 1 по Y). Вертикали прямые.
- Складывать кубы; объект можно двигать без смены перспективы.
- Контур часто заменяют переходом тона и светлым углом.
- Форма из кубоида **вырезанием**; текстура после объёма.
- Плоский рисунок → поворот 45° → сжать Y ~50% на верхнюю грань.

### Don'ts

- Смешивать iso-сетку с side-on персонажем без заказа.
- Текстура до «вырезания».

### Для DM

- Не дефолт. Тайлы DM — ортогональный blob, не iso.
