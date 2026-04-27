# Домашнее задание к занятию "`Защита сети`" - `Гайченков Евгений`

## Задание 1

![alt text](https://github.com/splash63/devops/blob/main/sdb-13-03/img/1_1.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-13-03/img/1_2.png)

В логах видно, что идет сканирование на различные порты. Также видно протокол и адрес источника сканирования и адрес назначения.

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/sdb-13-03/img/2_1.png)

![alt text](https://github.com/splash63/devops/blob/main/sdb-13-03/img/2_2.png)

В логах Suricata видно, что идет сканирование на службу SSH 22 порта с источника 192.168.2.74.
В логах Fail2Ban видны попытки доступа через службу sshd c источника 192.168.2.74. После несхольких неудачных попыток автоизации IP попадает в бан.