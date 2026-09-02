# Pixelblog 1 — палитры

- URL: https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes
- Каталог: https://www.slynyrd.com/pixelblog-catalogue
- Когда: `set_palette` / `apply_bundled_palette`, sidecar `local_palettes`, pass 2 шаг Local palettes.

Пересказ идей (не цитата поста, картинок нет):

- Рампу собирают в **HSB**, не тыкая случайные hex.
- Между соседними ступенями **hue-shift порядка 10–20°** (автор на широкой рампе шёл до ~20°). Светлые теплее, тёмные холоднее — или наоборот по брифу, но сдвиг обязателен.
- Saturation и brightness не обязаны идти равными шагами; равный шаг H часто красивее равного шага S.
- Одна картинка / персонаж **не должен съедать всю большую палитру**. Бандл EDG32/A64 — меню; локально 4–6 тонов на материал.
- Сохранить рампу (в DM: sidecar + бандл), чтобы цикл и still говорили одним языком.

## Для DM

- На 96: deep / shadow / base / terminator-or-bounce / highlight из одного бандла.
- Не один `#9e2835` на всю шкуру.
- Hue-shift тени в холод уже в PIXEL_CRAFT; эта карточка фиксирует **градусы и длину рампы**.
