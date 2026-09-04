# Домашнее задание к занятию "`Средство визуализации Grafana`" - `Гайченков Евгений`

## Задание 1

![alt text](https://github.com/splash63/devops/blob/main/10-monitoring-03-grafana/img/1.png)

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/10-monitoring-03-grafana/img/2.png)

Утилизация CPU (100 − idle), в процентах: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

Load Average 1/5/15: node_load1 node_load5 node_load15

Свободная оперативная память: node_memory_MemAvailable_bytes

Свободное место на файловой системе: node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"}

## Задание 3

![alt text](https://github.com/splash63/devops/blob/main/10-monitoring-03-grafana/img/3.png)

## Задание 4

[Дашборд](./Netology-1788512057447.json)