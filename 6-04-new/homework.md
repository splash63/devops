# Домашнее задание к занятию "`Docker. Часть 2`" - `Гайченков Евгений`

## Задание 1
Напишите ответ в свободной форме, не больше одного абзаца текста.

Установите Docker Compose и опишите, для чего он нужен и как может улучшить лично вашу жизнь.

## Решение 1

Docker Compose упрощает и ускорят запуск контейнеров путем описания инструкций в yml файлах.
Файлы можно клонировать и запустить в пару  кликов.

## Задание 2
Выполните действия и приложите текст конфига на этом этапе.

Создайте файл docker-compose.yml и внесите туда первичные настройки:

version;
services;
volumes;
networks.
При выполнении задания используйте подсеть 10.5.0.0/16. Ваша подсеть должна называться: <ваши фамилия и инициалы>-my-netology-hw. Все приложения из последующих заданий должны находиться в этой конфигурации.

## Решение 2
```yml
networks:
  gaychenkoves-my-netology-hw:
  name: gaychenkoves-my-netology-hw
  driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
services:
  app
volumes:
  test
```

## Задание 3
Выполните действия:

1. Создайте конфигурацию docker-compose для Prometheus с именем контейнера <ваши фамилия и инициалы>-netology-prometheus.
2. Добавьте необходимые тома с данными и конфигурацией (конфигурация лежит в репозитории в директории 6-04/prometheus ).
3. Обеспечьте внешний доступ к порту 9090 c докер-сервера.

## Решение 3

```yml
networks:
  gaychenkoves-my-netology-hw:
    name: gaychenkoves-my-netology-hw
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
services:
    prometheus:
        image: prom/prometheus
        container_name: gaychenkoves-netology-prometheus
        volumes:
            - ./prometheus/:/etc/prometheus/
            - prometheus-data:/prometheus
        command:
            - '--config.file=/etc/prometheus/prometheus.yml'
        ports:
          - 9090:9090
        networks:
          - gaychenkoves-my-netology-hw
        restart: always
volumes:
  prometheus-data:
```
## Задание 4
Выполните действия:

Создайте конфигурацию docker-compose для Pushgateway с именем контейнера <ваши фамилия и инициалы>-netology-pushgateway.
Обеспечьте внешний доступ к порту 9091 c докер-сервера.

## Решение 4
```yml
pushgateway:
      image: prom/pushgateway
      container_name: gaychenkoves-netology-pushgateway
      restart: always
      ports:
      - 9091:9091
      networks:
        - gaychenkoves-my-netology-hw
      depends_on:
        - prometheus
      restart: always
```

## Задание 5
Выполните действия:

1. Создайте конфигурацию docker-compose для Grafana с именем контейнера <ваши фамилия и инициалы>-netology-grafana.
2. Добавьте необходимые тома с данными и конфигурацией конфигурация лежит в репозитории в директории 6-04/grafana.
3. Добавьте переменную окружения с путем до файла с кастомными настройками (должен быть в томе), в самом файле пропишите логин=<ваши фамилия и инициалы> пароль=netology.
4. Обеспечьте внешний доступ к порту 3000 c порта 80 докер-сервера.

## Решение 5
```yml
volumes:
  grafana_data
grafana:
  image: grafana/grafana
  container_name: gaychenkoves-netology-grafana
  depends_on:
    - prometheus
  ports:
    - 80:3000
  volumes:
    - grafana_data:/var/lib/grafana
    - ./grafana/provisioning/:/etc/grafana/provisioning/
  env_file:
    - ./grafana/config.monitoring
  networks:
    - gaychenkoves-my-netology-hw
    restart: always
```
## Задание 6
Выполните действия.

1. Настройте поочередность запуска контейнеров.
2. Настройте режимы перезапуска для контейнеров.
3. Настройте использование контейнерами одной сети.
4. Запустите сценарий в detached режиме.

## Решение 6
```yml
volumes:
  prometheus-data:
  grafana_data:
networks:
  gaychenkoves-my-netology-hw:
    name: gaychenkoves-my-netology-hw
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
services:
    prometheus:
      image: prom/prometheus
      container_name: gaychenkoves-netology-prometheus
      volumes:
        - ./prometheus/:/etc/prometheus/
        - prometheus-data:/prometheus
      command:
        - '--config.file=/etc/prometheus/prometheus.yml'
      ports:
        - 9090:9090
      networks:
        - gaychenkoves-my-netology-hw
      restart: always
    pushgateway:
      image: prom/pushgateway
      container_name: gaychenkoves-netology-pushgateway
      ports:
      - 9091:9091
      depends_on:
        - prometheus
      restart: always
      networks:
        - gaychenkoves-my-netology-hw
    grafana:
      image: grafana/grafana
      container_name: gaychenkoves-netology-grafana
      depends_on:
        - prometheus
      ports:
        - 80:3000
      volumes:
        - grafana_data:/var/lib/grafana
        - ./grafana/provisioning/:/etc/grafana/provisioning/
      env_file:
        - ./grafana/config.monitoring
      networks:
        - gaychenkoves-my-netology-hw
      restart: always
```
Команда для запуска в detached режиме:
```bash
docker compose up -d
```
## Задание 7
Выполните действия.

1. Выполните запрос в Pushgateway для помещения метрики <ваши фамилия и инициалы> со значением 5 в Prometheus: echo "<ваши фамилия и инициалы> 5" | curl --data-binary @- http://localhost:9091/metrics/job/netology.
2. Залогиньтесь в Grafana с помощью логина и пароля из предыдущего задания.
3. Cоздайте Data Source Prometheus (Home -> Connections -> Data sources -> Add data source -> Prometheus -> указать "Prometheus server URL = http://prometheus:9090" -> Save & Test).
4. Создайте график на основе добавленной в пункте 5 метрики Build a dashboard -> Add visualization -> Prometheus -> Select metric -> Metric explorer -> <ваши фамилия и инициалы -> Apply.
В качестве решения приложите:

* docker-compose.yml целиком;
* скриншот команды docker ps после запуске docker-compose.yml;
* скриншот графика, постоенного на основе вашей метрики.

## Решение 7
```yml
volumes:
  prometheus-data:
  grafana-data:
networks:
  gaychenkoves-my-netology-hw:
    name: gaychenkoves-my-netology-hw
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
services:
    prometheus:
      image: prom/prometheus
      container_name: gaychenkoves-netology-prometheus
      volumes:
        - ./prometheus/:/etc/prometheus/
        - prometheus-data:/prometheus
      command:
        - '--config.file=/etc/prometheus/prometheus.yml'
      ports:
        - 9090:9090
      networks:
        - gaychenkoves-my-netology-hw
      restart: always
    pushgateway:
      image: prom/pushgateway
      container_name: gaychenkoves-netology-pushgateway
      ports:
      - 9091:9091
      depends_on:
        - prometheus
      restart: always
      networks:
        - gaychenkoves-my-netology-hw

    grafana:
      image: grafana/grafana
      container_name: gaychenkoves-netology-grafana
      depends_on:
        - prometheus
      ports:
        - 80:3000
      volumes:
        - grafana-data:/var/lib/grafana
        - ./grafana/provisioning/:/etc/grafana/provisioning/
      env_file:
        - ./grafana/config.monitoring
      networks:
        - gaychenkoves-my-netology-hw
      restart: always
```
![alt text](https://github.com/splash63/devops/blob/main/6-04-new/img/docker_ps.png)
![alt text](https://github.com/splash63/devops/blob/main/6-04-new/img/my_metric.png)

## Задание 8
Выполните действия:

Остановите и удалите все контейнеры одной командой.
В качестве решения приложите скриншот консоли с проделанными действиями.

## Решение 8

![alt text](https://github.com/splash63/devops/blob/main/6-04-new/img/dcd.png)

## Задание 9*
Выполните действия:

1. Создайте конфигурацию docker-compose для Alertmanager с именем контейнера <ваши фамилия и инициалы>-netology-alertmanager.
2. Добавьте необходимые тома с данными и конфигурацией, сеть, режим и очередность запуска.
3. Обновите конфигурацию Prometheus (необходимые изменения ищите в презентации или документации) и перезапустите его.
4. Обеспечьте внешний доступ к порту 9093 c докер-сервера.
5. В качестве решения приложите скриншот с событием из Alertmanager.

## Решение 9

![alt text](https://github.com/splash63/devops/blob/main/6-04-new/img/alert.png)