# Домашнее задание к занятию "`Репликация и масштабирование. Часть 1`" - `Гайченков Евгений`

## Задание 1

Master‑Slave

1 главный сервер (Master) — принимает все записи (INSERT, UPDATE, DELETE).

1+ подчинённых (Slave) — получают копии данных, обслуживают запросы на чтение (SELECT).

Master‑Master

2+ главных сервера (Masters) — каждый принимает и чтение, и запись.

Серверы синхронизируют изменения друг с другом.

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/compose.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/master_conf.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/slave_conf.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/master.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/slave.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/no_db.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-12-06/img/created_db.png)