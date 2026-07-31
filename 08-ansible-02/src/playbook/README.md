# Ansible playbook: Clickhouse + Vector

Playbook разворачивает и настраивает два независимых компонента на разных группах хостов:

1. **Clickhouse** (группа `clickhouse`) — добавляет официальный apt-репозиторий ClickHouse (GPG-ключ +
   sources.list через template) и ставит `clickhouse-common-static`, `clickhouse-client`,
   `clickhouse-server` закреплённой версии через `apt`, запускает сервис и создаёт базу `logs`.
2. **Vector** (группа `vector`) — скачивает архив нужной версии с `packages.timber.io`, распаковывает его
   в `/opt/vector`, разворачивает конфиг `/etc/vector/vector.yaml` и systemd unit из Jinja2-шаблонов,
   включает и запускает сервис. При изменении конфига или unit-файла сервис перезапускается автоматически.

## Структура

```
playbook/
├── site.yml                       # оба play
├── inventory/
│   └── prod.yml                   # инвентарь (группы clickhouse, vector)
├── group_vars/
│   ├── clickhouse/vars.yml
│   └── vector/vars.yml
└── templates/
    ├── vector.yaml.j2             # конфиг vector
    └── vector.service.j2          # systemd unit для vector
```

## Требования

- Ansible >= 2.14
- Целевые хосты — Debian/Ubuntu (для play `clickhouse`, используется модуль `apt`) и любой
  systemd-дистрибутив для play `vector`
- Доступ до `packages.clickhouse.com` и `packages.timber.io` с целевых хостов
- SSH-доступ и права на `become: true` (sudo)

## Параметры (group_vars)

### `group_vars/clickhouse/vars.yml`

| Переменная            | Описание                                   | По умолчанию   |
|------------------------|---------------------------------------------|----------------|
| `clickhouse_version`   | Версия устанавливаемого Clickhouse          | `22.3.3.44`    |
| `clickhouse_arch`      | Архитектура пакетов (`amd64`/`arm64`)       | `amd64`        |
| `clickhouse_packages`  | Список пакетов, устанавливаемых с закреплённой версией | common-static/client/server |

### `group_vars/vector/vars.yml`

| Переменная            | Описание                                             | По умолчанию                       |
|------------------------|--------------------------------------------------------|-------------------------------------|
| `vector_version`       | Версия Vector                                          | `0.46.0`                            |
| `vector_arch`          | Платформа дистрибутива                                 | `x86_64-unknown-linux-gnu`          |
| `vector_download_url`  | URL архива (собирается из версии и архитектуры)        | вычисляемое значение                |
| `vector_install_dir`   | Куда распаковывается бинарник                          | `/opt/vector`                       |
| `vector_bin_path`      | Симлинк на бинарник в PATH                             | `/usr/local/bin/vector`             |
| `vector_config_dir`    | Каталог конфигурации                                   | `/etc/vector`                       |
| `vector_data_dir`      | Каталог данных vector (`data_dir`)                      | `/var/lib/vector`                   |
| `vector_source`        | Тип источника в конфиге                                | `journald`                          |
| `vector_sink_type`     | Тип sink в конфиге                                     | `console`                           |

Переопределить любую переменную можно как обычно — через `host_vars`, `-e` в командной строке или
собственный `group_vars`.

## Теги

Отдельные теги на задачи не заведены — плеи разделены по группам хостов (`hosts: clickhouse` /
`hosts: vector`), поэтому для точечного запуска используется ограничение по хостам/группам:

```bash
# Только clickhouse
ansible-playbook site.yml -i inventory/prod.yml --limit clickhouse

# Только vector
ansible-playbook site.yml -i inventory/prod.yml --limit vector
```
