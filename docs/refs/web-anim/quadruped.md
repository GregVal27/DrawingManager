# Четвероногий walk / trot

Источники имён фаз: SLYNYRD 50 (бипед) + индекс [Lospec walkcycle](https://lospec.com/pixel-art-tutorials/tags/walkcycle) (карточка Quadruped Walk/Trot, автор Pedro Medeiros = saint11; смотреть GIF на сайте автора, не копировать в `work/`). Канон DM: [`ANIM_CRAFT.md`](../../ANIM_CRAFT.md), очередь: [`PLAN_CRAFT_NEXT.md`](../../PLAN_CRAFT_NEXT.md). Saint11: [`../saint11/README.md`](../saint11/README.md).

## Walk vs trot

- **Walk:** почти всегда **три** опоры; корпус качается мало. Contact копытом (не человеческая пятка).
- **Trot:** диагональные пары (ближняя передняя + дальняя задняя, потом наоборот); больше воздуха; быстрее.

На 96 digitigrade: имена те же, что у бипеда — **contact / down / passing / up** на **каждой** паре ног, со сдвигом фазы перед/зад (~половина цикла).

## Side-on

- Дальняя пара короче и темнее, часто перекрыта торсом.
- Щель между ближней и дальней ногой на contact — иначе blob.
- Хвост/грива **лаг** 1 кадр от таза.

Walk не красить без «ок» на ключах. Гибрид: plant опорных копыт, `shift_rect` свободных, кисть оклюзии.
