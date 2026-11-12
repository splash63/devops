# Домашнее задание к занятию "`Хранение в K8s`" - `Гайченков Евгений`

## 1. Обмен данными через emptyDir

[Манифест containers-data-exchange.yaml](manifests/containers-data-exchange.yaml)

![Описание Pod с двумя контейнерами](screenshots/01-describe.png)

![Чтение файла из multitool](screenshots/02-emptydir-tail.png)

## 2. Локальный PV, созданный вручную

[Манифест pv-pvc.yaml](manifests/pv-pvc.yaml)

![Привязка PV и PVC и запуск Pod](screenshots/03-manual-bound.png)

![Чтение с локального PV](screenshots/04-manual-tail.png)

![PV после удаления Deployment и PVC](screenshots/05-released.png)

Удаление PV удаляет объект Kubernetes. Локальная директория и файл остаются на диске, так как том создан вручную и использует `Retain`.

![Файл на узле до и после удаления PV](screenshots/06-file-retained.png)

## 3. PVC на основе StorageClass

[Манифест sc.yaml](manifests/sc.yaml)

Класс `data-exchange-local` использует `kubernetes.io/no-provisioner` и `WaitForFirstConsumer`. Поэтому манифест также содержит заранее подготовленный локальный PV с тем же классом. PVC не указывает имя PV: подходящий том подбирается при планировании Pod.

![StorageClass, привязка PVC и работающий Pod](screenshots/07-sc-bound.png)

![Чтение из тома, подобранного по StorageClass](screenshots/08-sc-tail.png)