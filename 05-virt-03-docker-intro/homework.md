# Домашнее задание к занятию "`Оркестрация группой Docker контейнеров на примере Docker Compose`" - `Гайченков Евгений`

## Задание 1

https://hub.docker.com/repository/docker/splash63/custom-nginx/general

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/1.png)

## Задание 3

2.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/2.png)

3. Контейнер остановился после нажатия Ctrl+C, потому что сигнал SIGINT был передан главному процессу контейнера (nginx). После завершения основного процесса Docker автоматически остановил контейнер, так как контейнер существует только пока работает его PID 1.

4, 5
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/3.png)

6.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/4.png)

7, 8, 9, 10
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/5.png)

Docker пробросил порт так 127.0.0.1:8080 на хосте → 80 порт внутри контейнера. Но внутри контейнера nginx теперь слушает не 80, а 81.
Из-за этого запрос на http://127.0.0.1:8080 попадает в контейнер на порт 80, где уже ничего не слушает. Поэтому страница с хоста недоступна, хотя внутри контейнера nginx работает на 81.

12.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/6.png)

## Задание 4

![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/7.png)

## Задание 5

1. Будет запущен compose.yaml, потому что Docker Compose предпочитает канонический файл compose.yaml; docker-compose.yaml поддерживается для совместимости, но имеет меньший приоритет.

2.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/11.png)

3.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/12.png)

5.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/10.png)

6.
![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/8.png)

![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/9.png)

7. Compose увидит только docker-compose.yaml. Уже созданный ранее сервис portainer станет orphan container, потому что он относится к прежней конфигурации проекта, но теперь отсутствует в compose-файле.
Compose предупреждает: “в проекте есть контейнеры, которые были созданы раньше, но больше не описаны в текущем compose-файле”.

![alt text](https://github.com/splash63/devops/blob/main/05-virt-03-docker-intro/img/13.png)