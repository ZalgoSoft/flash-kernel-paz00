```markdown
# Ubiquiti AirOS: сохранение и восстановление конфигурации через `cfgmtd`

Практическая инструкция по работе с постоянной конфигурацией на устройствах Ubiquiti под управлением AirOS (проверено на `BZ.v3.7.51`, MIPS, madwifi).

## Проблема

При правке `/tmp/system.cfg` и перезагрузке устройства изменения не применяются. Файлы, положенные в `/etc/persistent/`, исчезают или игнорируются.

## Причина

Скрипт `/init` при загрузке **не читает текстовые файлы напрямую**. Он восстанавливает конфигурацию из бинарного образа в MTD-разделе `cfg` через утилиту `cfgmtd`.

Ключевой фрагмент `/init`:

```sh
CFG_SYSTEM="/tmp/system.cfg"
CFG_RUNNING="/tmp/running.cfg"

/sbin/cfgmtd -r -p /etc/ -f $CFG_RUNNING
if [ $? -ne 0 ]; then
        /sbin/cfgmtd -r -p /etc/ -t 2 -f $CFG_RUNNING
        if [ $? -ne 0 ]; then
                cp $CFG_DEFAULT $CFG_RUNNING
        fi
fi

is_default=`grep -c 'mgmt\.is_default=true' $CFG_RUNNING`
[ ${is_default} -lt 1 ] || cp $CFG_DEFAULT $CFG_RUNNING

sort $CFG_RUNNING > $CFG_SYSTEM
rm $CFG_RUNNING
```

### Что это значит

| Шаг | Действие |
|-----|----------|
| `cfgmtd -r -p /etc -f /tmp/running.cfg` | Читает **основную** конфигурацию из persistent-области |
| `cfgmtd -r -p /etc -t 2 -f ...` | Читает **резервную** конфигурацию |
| `cp $CFG_DEFAULT $CFG_RUNNING` | Откат на заводской конфиг |
| `grep mgmt.is_default=true` | Если флаг есть — принудительный сброс на дефолт |
| `sort ... > /tmp/system.cfg` | Сортирует и записывает итоговый конфиг |

### Формат хранения

Persistent-конфигурация — **не текстовый файл**, а бинарный образ:

- **Заголовок (24 байта):** id, CRC32, служебные поля
- **Payload:** сжатые zlib данные (текстовый конфиг + `tar.gz` содержимого `/var/etc/persistent`)

Поэтому просто положить файл в `/etc/persistent/` недостаточно — данные должны быть упакованы в этот формат.

## Решение

### 1. Подготовить конфиг

Привести `/tmp/system.cfg` к нужному виду. Убедиться, что **нет** строки:

```
mgmt.is_default=true
```

Если она есть — система на каждой загрузке будет заменять конфиг на заводской.

### 2. Записать в постоянную память

```sh
cfgmtd -w -p /etc
```

Или короче, через алиас из `/usr/etc/profile`:

```sh
save
```

### 3. Проверить, что записалось

```sh
cfgmtd -r -p /etc -f /tmp/check.cfg
cat /tmp/check.cfg
```

### 4. Перезагрузить

```sh
reboot
```

После загрузки `/init` прочитает конфиг через `cfgmtd -r` и применит его.

## Полезные команды

### `ubntconf`

Парсит `/tmp/system.cfg` и **генерирует** скрипты инициализации (например, `/etc/aaa1.cfg` для hostapd). Сам по себе не применяет настройки.

```sh
/sbin/ubntconf
```

### `cfgmtd`

Работа с бинарным образом конфигурации.

| Команда | Действие |
|---------|----------|
| `cfgmtd -w -p /etc` | Записать текущий `/tmp/system.cfg` в persistent |
| `cfgmtd -r -p /etc -f /tmp/out.cfg` | Прочитать из persistent в текстовый файл |
| `cfgmtd -r -p /etc -t 2 -f /tmp/out.cfg` | Прочитать резервную копию |

### Проверка режима интерфейса

Для madwifi смена режима интерфейса на лету **не работает** — драйвер отклоняет переключение:

```
ieee80211_ioctl_siwmode: new mode=3, valid=0
```

Режим задаётся в `system.cfg` через `radio.X.mode` и `wireless.X.mode` **до** создания интерфейса через `wlanconfig`.

## Типичные ошибки

| Симптом | Причина |
|---------|---------|
| Конфиг слетает после ребута | В конфиге остался `mgmt.is_default=true` |
| Файлы в `/etc/persistent/` исчезают | Не выполнен `cfgmtd -w -p /etc` |
| `/etc/aaa1.cfg` не совпадает с `system.cfg` | Не выполнен `/sbin/ubntconf` после правки |
| `hostapd` циклически перезапускается | Интерфейс в режиме `managed`, а не `master` |
| `iwconfig` показывает `Encryption key:off` | Норма для WPA2 — `iwconfig`/`iwlist` не видят WPA |

## Ссылки

- `/init` — скрипт инициализации
- `/usr/etc/profile` — алиас `save`
- `/etc/inittab` — список респавн-процессов
- `/usr/etc/rc.d/rc` — основной rc-скрипт
```
