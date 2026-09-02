# Run / jump — галереи и гайды

Источники: Pixnote; sprite-ai.art (паттерн поз, не one-click ИИ); FreePixel sprite sheets; saint11 Walk/Jump.

## Run ≠ быстрый walk

- Корпус вперёд (на 96: 1–3px lean).
- Шаг длиннее.
- Обязателен кадр **обе ноги в воздухе**. Если всегда есть посадка — это walk.
- Timing короче walk (у нас run **80ms**).

## Jump (Pixnote / indie cheat)

Полный: crouch (squash 1px) → launch (stretch) → apex → fall → land squash.
На 64–128 игроку часто хватает **3** кадра (crouch / air / land) — у нас дефолт jump 3×80, fall 3×100.

Не крутить весь холст. Гибрид: `shift_rect` корпуса, копыта в воздухе можно сдвигать, при land — plant + кисть.

## Для DM

Ждать «ок» на ключах. Smear только на быстром launch, на `fx`.
