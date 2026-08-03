# Ansible playbook: Clickhouse + Vector + LightHouse

Playbook разворачивает и настраивает три независимых компонента на разных группах хостов:

1. **Clickhouse** (группа `clickhouse`) — добавляет официальный apt-репозиторий ClickHouse (GPG-ключ +
   sources.list через template) и ставит `clickhouse-common-static`, `clickhouse-client`,
   `clickhouse-server` закреплённой версии через `apt`, запускает сервис и создаёт базу `logs`.
2. **Vector** (группа `vector`) — скачивает архив нужной версии с `packages.timber.io`, распаковывает его
   в `/opt/vector`, разворачивает конфиг `/etc/vector/vector.yaml` и systemd unit из Jinja2-шаблонов,
   включает и запускает сервис. При изменении конфига или unit-файла сервис перезапускается автоматически.
3. **LightHouse** (группа `lighthouse`) — скачивает статику [LightHouse](https://github.com/VKCOM/lighthouse)
   (лёгкий веб-интерфейс для ClickHouse) с GitHub, распаковывает в `/var/www/lighthouse`, ставит nginx
   (`yum` на RedHat-семействе / `apt` на Debian-семействе — определяется автоматически по `os_family`),
   разворачивает конфиг виртуального хоста из template и запускает nginx. Целевое окружение для этого
   play — отдельный хост на Rocky Linux 9.

## Структура

```
playbook/
├── site.yml                       # три play
├── inventory/
│   └── prod.yml                   # инвентарь (группы clickhouse, vector, lighthouse)
├── group_vars/
│   ├── clickhouse/vars.yml
│   ├── vector/vars.yml
│   └── lighthouse/vars.yml
└── templates/
    ├── clickhouse.list.j2         # apt source list для clickhouse
    ├── vector.yaml.j2             # конфиг vector
    ├── vector.service.j2          # systemd unit для vector
    └── lighthouse.conf.j2         # конфиг виртуального хоста nginx для LightHouse
```

## Требования

- Ansible >= 2.14
- Целевые хосты:
  - `clickhouse` — Debian/Ubuntu (используется модуль `apt`)
  - `vector` — любой systemd-дистрибутив
  - `lighthouse` — Rocky Linux 9 (используется `yum`); play также поддерживает Debian/Ubuntu через `apt`,
    если понадобится запустить его на другом хосте
- Доступ до `packages.clickhouse.com`, `packages.timber.io` и `codeload.github.com` с целевых хостов
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

### `group_vars/lighthouse/vars.yml`

| Переменная               | Описание                                          | По умолчанию                                                             |
|----------------------------|------------------------------------------------------|-----------------------------------------------------------------------------|
| `lighthouse_repo_branch`   | Ветка репозитория LightHouse для скачивания          | `master`                                                                     |
| `lighthouse_download_url`  | URL архива с исходниками (собирается из ветки)       | вычисляемое значение (`codeload.github.com/VKCOM/lighthouse/tar.gz/...`)   |
| `lighthouse_install_dir`   | Каталог, куда распаковывается статика                | `/var/www/lighthouse`                                                       |
| `lighthouse_http_port`     | Порт, на котором nginx отдаёт LightHouse             | `8080`                                                                       |

Переопределить любую переменную можно как обычно — через `host_vars`, `-e` в командной строке или
собственный `group_vars`.

## Теги

Отдельные теги на задачи не заведены — плеи разделены по группам хостов (`hosts: clickhouse` /
`hosts: vector` / `hosts: lighthouse`), поэтому для точечного запуска используется ограничение по
хостам/группам:

```bash
# Только clickhouse
ansible-playbook site.yml -i inventory/prod.yml --limit clickhouse

# Только vector
ansible-playbook site.yml -i inventory/prod.yml --limit vector

# Только lighthouse
ansible-playbook site.yml -i inventory/prod.yml --limit lighthouse
```

## Запуск

```bash
# Проверка линтером
ansible-lint site.yml

# Сухой прогон (без применения изменений)
ansible-playbook site.yml -i inventory/prod.yml --check --diff

# Реальный прогон с выводом diff
ansible-playbook site.yml -i inventory/prod.yml --diff

# Повторный запуск для проверки идемпотентности
ansible-playbook site.yml -i inventory/prod.yml --diff
```

При повторном запуске все задачи должны быть в состоянии `ok`, без `changed` (кроме, возможно,
`Flush handlers`, который сам по себе изменений не производит).