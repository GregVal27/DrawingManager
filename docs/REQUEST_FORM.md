# Форма заказа DrawingManager

Скопируйте блок в чат Cursor и заполните. Лишние разделы удалите. Инструкция: [`USAGE.md`](USAGE.md).

```
# DrawingManager — заказ

## Объект
тип: существо | проп | тайлсет | локация
имя файла:
размер:
палитра: EDG32 | A64 | DB32 | список hex | файл .gpl | палитра из work/….aseprite
вид: side-on
facing: right

## Существо
сложность: простая
кто:
акцент:
материалы:
поза (проход 1):
анимации: дефолт 8 циклов | только still | список тегов ниже
- idle:
- walk:
- run:
- attack:
- jump:
- fall:
- hurt:
- die:
- своё (имя, кадры, ТЗ):

## Проп
вид: fire | torch | flag | tree | bush | grass | water | rock | cloud | smoke | wall | floor | door | window | table | chair | chest | bed | banner
кадры:
движение: shift | copy | redraw
папка: work/nature/ | work/interiors/

## Тайлсет
tile_size: 16 | 32 | 64
тема: meadow | dirt | water | dungeon | interior_wood
автотайл: да | нет

## Локация
размер (кратно тайлу):
тема:
собрать из:

## Не делать

```
