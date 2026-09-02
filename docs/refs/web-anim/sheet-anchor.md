# Якорь холста и sprite sheet

Источники: [Pixnote — sprite sheets](https://pixnote.net/en/learn/animation/), [FreePixel — sprite sheets](https://freepixel.art/blog/creating-smooth-character-animations-with-sprite-sheets).

- Все кадры тега — **один** размер холста (у нас 96×96). Кадр 96×97 = дрожь в лупе.
- Подошва на **одной линии Y** (ground line). Не «плавать» якорь между кадрами.
- Padding: прыжок/удар влезает в тот же холст; не резать canvas под позу.
- В игре: Point filter, без bilinear. GIF в `preview/`, не в `work/`.
- Строка тега = одно действие (idle / walk / …) — как sidecar `tags`.

Гибрид не отменяет якорь: `shift_rect` частей, подошва `plant` не едет.
