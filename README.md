## Назначение этого проекта

`СМ2201` (`SM2201`) - мессбауэровский спектрометр с высоким скоростным разрешением, оригинальный спектрометр был разработан в `1989` г, мелкосерийное производство продолжалось до `1991` г. Несмотря на свой солидный возраст этот спектрометр продолжает обеспечивать получение передовых научных результатов и на момент написания этой страницы (янв. 2023). 

Несмотря *на устаревшую элементную базу* (микросхемы серии `ТТЛ`, `ТТЛШ`- `155`, `1533`) этот спектрометр **обладает уникальными характеристиками**, позволяющими считать его одним из лучших в мире. ***Основное*** его ***преимущество*** перед другими спектрометрами - ***существенно меньшая величина ошибки значения скорости*** в системе допплеровской модуляции, что ***обусловлено большим количеством научных работ и исследований в области систем регулирования***. Известно, что в мессбаэуровской спектрометрии энергия гамма-квантов модулируется эффектом Доплера, скорость изменяется дискретно, при этом *за интервал 1 точки спектра* (для спектров на `4096` точек это `16 мкс`) *скорость должна поддерживаться условно постоянной* (на самом деле нет и идет постоянное приращение в течение всего интервала измерения всех точек спектра от 0 до `2^N-1`).

`SM2201` - мессбауэровский спектрометр, построенный на базе интерфейса `CAMAC`, в состав `CAMAC` обязательно входит контролдер крейта и другие модули. Благодаря возможностям `FPGA` можно заменять устаревшие модули на новые, ***сам `CAMAC` активно используется `CERN`, при этом для него производятся дополнительны модули***.

## 1. Лицензия
Хотя код данного решения и является открытым мы (`Wissance`, `https://wissance.com`) оно НЕ ЯВЛЯЕТСЯ БЕСПЛАТНЫМ для использования,условия использовани должны быть согласованы
с нами как с авторами и обладателями прав на это ПО, оставить заявку на согласование условий можно:
1. по электронной почте: `info@wissance.com`
2. в канале `Discord`: `https://discord.com/channels/1022429270276046879/1022429271190409236`

## 2. Состав решения

В состав данного решения входят:

* `CAMAC-контроллер` крейта
* блок накопления


### 2.1 CAMAC контроллер крейта

Контроллер крейта позволяет управлять модулями через `RS-232` с использованием [quick_rs232](https://github.com/Wissance/QuickRS232), для контроллера подготовлено
3 типа команд:
1. Запись в модуль
2. Чтение из модуля
3. Проверка состояния `LAM` (Look at Me, запрос на обслуживание) модулей:

Выполнение команд и ответ на команды через последовательный порт:
![Управление CAMAC-контроллером по RS-232](/docs/design/camac_controller_cmd.png)

Цикл CAMAC при операция записи в модули:
![Запись в модули](/docs/design/camac_w.png)

### 2.2 Блок накопления

будет добавлен позднее ...

### 3. Авторы

<a href="https://github.com/Wissance/Sm2201/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Wissance/Sm2201" />
</a>