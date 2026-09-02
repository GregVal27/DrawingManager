# Pixnote shade → наши рампы

Источник: [Pixnote shading](https://pixnote.net/en/learn/shading/). Не заменяет [`PIXEL_CRAFT.md`](../../PIXEL_CRAFT.md) и [`../craft/light.md`](../craft/light.md).

- Свет один (у нас верх-лево), иначе pillow.
- Тень: темнее **и** hue в холод, насыщенность чуть выше — не серый mul.
- Стадии по размеру: 16² → 2; 32² → 3; 64+ → 4–5. Совпадает с таблицей PIXEL_CRAFT (64→3, 96→4–5, 128→5–6).
- Материалы: кожа мягкая; металл жёсткий spec 1–2px; ткань matte по складке; мокрое — spec на `fx`.
- Sel-out: светлая кромка к свету, тёмная в тени — у нас финал, не `add_outline`.

Proof: сфера ~32px тем же бандлом ([`cycle-b.md`](../craft/cycle-b.md)).
