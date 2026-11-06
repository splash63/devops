# Домашнее задание к занятию "`Запуск приложений в K8S`" - `Гайченков Евгений`

## Задание 1

[Манифест для воспроизведения ошибки](manifests/01-conflict.yaml)

![Конфликт порта](screenshots/01-conflict.png)

### Исправление и масштабирование

[Исправленный Deployment](manifests/02-deployment.yaml)

![Одна реплика](screenshots/02-one-replica.png)

![Две реплики](screenshots/03-two-replicas.png)

### Доступ из другого Pod

[Service](manifests/03-service.yaml) · [Pod multitool-client](manifests/04-client.yaml)

![Service, адреса реплик и ответы curl](screenshots/04-service-curl.png)

## Задание 2

[Deployment с Init-контейнером](manifests/05-init-deployment.yaml) · [Service для nginx](manifests/06-init-service.yaml)

![Pod до создания Service](screenshots/05-before-service.png)

### После создания Service

![Pod после создания Service](screenshots/06-after-service.png)