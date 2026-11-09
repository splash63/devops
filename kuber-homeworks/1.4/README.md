# Домашнее задание к занятию "`Сетевое взаимодействие в Kubernetes`" - `Гайченков Евгений`

## 1. ClusterIP и NodePort

- [deployment-multi-container.yaml](manifests/deployment-multi-container.yaml)
- [service-clusterip.yaml](manifests/service-clusterip.yaml)
- [service-nodeport.yaml](manifests/service-nodeport.yaml)

![Deployment, Pod и Service](screenshots/01-services.png)

### ClusterIP: запросы из отдельного Pod

![Ответы ClusterIP](screenshots/02-clusterip.png)

### NodePort: запрос из Windows

![Ответ NodePort из Windows](screenshots/03-nodeport.png)

## 2. Маршрутизация через Ingress

- [deployment-frontend.yaml](manifests/deployment-frontend.yaml)
- [deployment-backend.yaml](manifests/deployment-backend.yaml)
- [service-frontend.yaml](manifests/service-frontend.yaml)
- [service-backend.yaml](manifests/service-backend.yaml)
- [ingress.yaml](manifests/ingress.yaml)

![Ресурсы для Ingress](screenshots/04-ingress.png)

![Ответы frontend и backend через Ingress](screenshots/05-ingress-curl.png)
