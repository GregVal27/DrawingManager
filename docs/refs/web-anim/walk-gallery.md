# Walk — что видно на стрипах

Источники: Google Images (side-view sheets), [Pixnote](https://pixnote.net/en/learn/animation/), [FreePixel sheets](https://freepixel.art/blog/creating-smooth-character-animations-with-sprite-sheets), гайд поз (не ИИ-пайплайн), SLYNYRD 50 / saint11 Walk (уже в репо). Lospec: [walkcycle tag](https://lospec.com/pixel-art-tutorials/tags/walkcycle).

## 4 ключа (минимум) vs 8 кадров (наш дефолт)

Минимум: contact R → passing R → contact L → passing L.

На 96 дефолт **8×100ms** = ключи + in-betweens, как SLYNYRD 50:

1. **Contact** — пятка/копыто, конечности в экстремуме, корпус **ниже**.
2. **Down / recoil** — стопа плоская, вес, другая нога отрывается.
3. **Passing** — ноги скрещены, корпус **выше** (~1px на 64, 1–2 на 96).
4. **Up / swing** — маховая нога вперёд, ещё в воздухе.
5. Зеркало 1–4 с **оклюзией** (дальняя короче и темнее, не copy ближней).

Pogo: равный прыжок каждый кадр. Нужен **треугольник** высоты головы (contact низкий, passing высокий), не идеальный sine (SLYNYRD 50).

Руки **против** ног. Волосы/плащ/хвост лаг 1 кадр. Ground line — [`sheet-anchor.md`](sheet-anchor.md).

Четвероногие: [`quadruped.md`](quadruped.md).

## Для DM

- Гибрид: `copy_cels` still → `shift_rect` бёдер/рук (копыта plant на contact) → кисть швов и оклюзии.
- Не ускоренная ходьба без фазы «в воздухе» — это уже **run** ([`run-jump.md`](run-jump.md)).
- Walk не красить без «ок» на ключах.
