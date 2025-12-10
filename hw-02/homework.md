# Домашнее задание к занятию "`Система мониторинга Zabbix`" - `Гайченков Евгений`

## Задание 1

Установите Zabbix Server с веб-интерфейсом.

Процесс выполнения
1. Выполняя ДЗ, сверяйтесь с процессом отражённым в записи лекции.
2. Установите PostgreSQL. Для установки достаточна та версия, что есть в системном репозитороии Debian 11.
3. Пользуясь конфигуратором команд с официального сайта, составьте набор команд для установки последней версии Zabbix с поддержкой PostgreSQL и Apache.
4. Выполните все необходимые команды для установки Zabbix Server и Zabbix Web Server.
Требования к результатам
1. Прикрепите в файл README.md скриншот авторизации в админке.
2. Приложите в файл README.md текст использованных команд в GitHub.
---

## Решение 1

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/login.png)

```bash
sudo apt install postgresql
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update
apt install zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agen
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
systemctl restart zabbix-server zabbix-agent nginx php8.3-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.3-fpm
```
---

## Задание 2

Установите Zabbix Agent на два хоста.

Процесс выполнения
1. Выполняя ДЗ, сверяйтесь с процессом отражённым в записи лекции.
2. Установите Zabbix Agent на 2 вирт.машины, одной из них может быть ваш Zabbix Server.
3. Добавьте Zabbix Server в список разрешенных серверов ваших Zabbix Agentов.
4. Добавьте Zabbix Agentов в раздел Configuration > Hosts вашего Zabbix Servera.
5. Проверьте, что в разделе Latest Data начали появляться данные с добавленных агентов.
Требования к результатам
1. Приложите в файл README.md скриншот раздела Configuration > Hosts, где видно, что агенты подключены к серверу
2. Приложите в файл README.md скриншот лога zabbix agent, где видно, что он работает с сервером
3. Приложите в файл README.md скриншот раздела Monitoring > Latest data для обоих хостов, где видны поступающие от агентов данные.
4. Приложите в файл README.md текст использованных команд в GitHub
---

## Решение 2

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/hosts.png)

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/agent.png)

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/host.png)

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/server.png)

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/host_data.png)

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update
apt install zabbix-agent
systemctl restart zabbix-agent
systemctl enable zabbix-agent
```
---

## Задание 3

Установите Zabbix Agent на Windows (компьютер) и подключите его к серверу Zabbix.

Требования к результатам
Приложите в файл README.md скриншот раздела Latest Data, где видно свободное место на диске C:
---

## Решение 3

![alt text](https://github.com/splash63/devops/blob/main/hw-02/img/disk_c.png)