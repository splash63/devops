# Домашнее задание к занятию "`Микросервисы: масштабирование`" - `Гайченков Евгений`

## Задание 1

### 1. Выбор

Основа решения — **Kubernetes** (K8s) вместе с небольшим набором сопутствующих компонентов:

| Компонент | Роль |
|---|---|
| **containerd** (или CRI-O) | Container runtime: запуск OCI-контейнеров |
| **Kubernetes** | Оркестрация, планирование, service discovery, масштабирование, конфигурация |
| **CoreDNS** | Внутренний DNS, обнаружение сервисов (входит в K8s) |
| **kube-proxy / CNI (Cilium или Calico)** | Сетевая связность, балансировка, сетевые политики |
| **Ingress-контроллер (NGINX Ingress или Traefik)** | Маршрутизация внешних HTTP(S)-запросов |
| **metrics-server** | Источник метрик для автомасштабирования |
| **Cluster Autoscaler** | Добавление/удаление узлов кластера |
| **Secrets + External Secrets Operator + HashiCorp Vault** (опционально) | Безопасное хранение чувствительных данных |

---

### 2. Архитектура и взаимодействие компонентов

```
                    Интернет
                       │
               ┌───────▼────────┐
               │ Load Balancer  │  (облачный LB / MetalLB)
               └───────┬────────┘
                       │
        ┌──────────────▼───────────────┐
        │  Ingress Controller          │  ← единственная внешняя точка входа
        │  (TLS, маршрутизация по      │
        │   host / path)               │
        └──────────────┬───────────────┘
                       │
        ┌──────────────▼───────────────┐
        │  Service (ClusterIP)         │  ← внутренний VIP + DNS-имя
        │  балансировка между подами   │
        └──────┬───────────────┬───────┘
               │               │
         ┌─────▼────┐    ┌─────▼────┐
         │   Pod    │    │   Pod    │  ← реплики Deployment
         │(контейнер)│   │(контейнер)│
         └─────┬────┘    └─────┬────┘
               │               │
        ┌──────▼───────────────▼───────┐
        │ Внутренние сервисы           │
        │ (БД, кэш, очереди) —         │
        │ только ClusterIP/Headless,   │
        │ закрыты NetworkPolicy        │
        └──────────────────────────────┘
```

**Control plane** (API Server, etcd, Scheduler, Controller Manager) принимает декларативное описание желаемого состояния (YAML-манифесты) и непрерывно приводит к нему реальное состояние кластера. На каждом **worker-узле** работают kubelet, container runtime и сетевой агент.

---

### 3. Как решение выполняет каждое требование

#### 3.1. Поддержка контейнеров

Kubernetes оперирует контейнерами через стандартный интерфейс CRI. Любой OCI-образ (собранный Docker, Buildah, Kaniko) запускается внутри **Pod**. Образы хранятся в реестре (Harbor, GitLab Registry, Docker Hub), а kubelet скачивает их при запуске.

#### 3.2. Обнаружение сервисов и маршрутизация запросов

- **Внутри кластера:** объект **Service** получает постоянный виртуальный IP и DNS-имя (`my-app.namespace.svc.cluster.local`), которое обслуживает CoreDNS. Поды могут умирать и появляться, а адрес сервиса остаётся неизменным. Список актуальных эндпоинтов поддерживается автоматически через readiness-пробы.
- **Снаружи:** объект **Ingress** описывает правила маршрутизации (по домену, пути, заголовкам), а Ingress-контроллер их исполняет, терминирует TLS (с автоматическими сертификатами через cert-manager + Let's Encrypt) и проксирует трафик на нужные Service.

#### 3.3. Горизонтальное масштабирование

Поле `replicas` в **Deployment** задаёт число экземпляров приложения. Изменение значения (`kubectl scale` или правка манифеста) приводит к добавлению или удалению подов, Scheduler распределяет их по узлам (с учётом `affinity`/`anti-affinity` и `topologySpreadConstraints` для отказоустойчивости). Service автоматически балансирует нагрузку между всеми репликами. Для stateful-нагрузок используется **StatefulSet**.

#### 3.4. Автоматическое масштабирование

Три уровня, которые дополняют друг друга:

1. **HPA (Horizontal Pod Autoscaler)** — меняет число реплик по метрикам CPU/памяти (из metrics-server) или по пользовательским метрикам (Prometheus Adapter).
2. **KEDA** (опционально) — масштабирование по событиям: длина очереди Kafka/RabbitMQ, число HTTP-запросов, в том числе до нуля.
3. **Cluster Autoscaler** — когда подам не хватает ресурсов, добавляет новые узлы в кластер (в облаке или через Cluster API), а при простое удаляет лишние.

Дополнительно **VPA** может подбирать `requests/limits` для контейнеров.

#### 3.5. Явное разделение внешних и внутренних ресурсов

Граница задаётся несколькими механизмами:

- **Тип Service:** по умолчанию `ClusterIP` (доступен только внутри). Наружу публикуется лишь то, что явно описано в **Ingress** (или Service типа `LoadBalancer`/`NodePort`). Базы данных, кэши и внутренние API не имеют внешних маршрутов.
- **Namespaces:** логическое разделение окружений и команд (например, `public`, `backend`, `data`), к которым применяются `ResourceQuota` и RBAC.
- **NetworkPolicy** (через Calico/Cilium): политика *default deny*, а затем явное разрешение только нужных связей (например, `frontend → api → db`). Это гарантирует, что внутренний сервис недоступен, пока это не разрешено.
- **Отдельный Ingress-класс или отдельные узлы** (taints/tolerations) для публичных и приватных нагрузок при повышенных требованиях к изоляции.

#### 3.6. Конфигурация через переменные среды и безопасное хранение секретов

- **ConfigMap** хранит нечувствительные параметры (URL, флаги, режимы) и подключается к контейнеру как переменные среды (`envFrom`, `valueFrom.configMapKeyRef`) или как файлы.
- **Secret** хранит пароли, токены, ключи доступа и шифрования и подключается так же — через `env.valueFrom.secretKeyRef` или как смонтированный том. Код приложения не меняется, а конфигурация зависит от окружения.
- **Меры защиты секретов:**
  - включить шифрование Secrets в etcd (`EncryptionConfiguration`, KMS-провайдер);
  - ограничить доступ через RBAC (разные Secrets доступны разным ServiceAccount);
  - не хранить секреты в Git в открытом виде: использовать **Sealed Secrets** или **SOPS**, либо **External Secrets Operator**, который подтягивает значения из **HashiCorp Vault** / облачного менеджера секретов и создаёт Kubernetes Secret автоматически;
  - Vault позволяет выдавать динамические, короткоживущие учётные данные и вести аудит доступа.

---

### 4. Пример манифеста

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: backend
spec:
  replicas: 3
  selector:
    matchLabels: { app: api }
  template:
    metadata:
      labels: { app: api }
    spec:
      containers:
        - name: api
          image: registry.example.com/api:1.4.2
          ports: [{ containerPort: 8080 }]
          resources:
            requests: { cpu: 200m, memory: 256Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          readinessProbe:
            httpGet: { path: /healthz, port: 8080 }
          envFrom:
            - configMapRef: { name: api-config }
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef: { name: api-secrets, key: db-password }
---
apiVersion: v1
kind: Service
metadata: { name: api, namespace: backend }
spec:
  type: ClusterIP
  selector: { app: api }
  ports: [{ port: 80, targetPort: 8080 }]
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: { name: api, namespace: backend }
spec:
  ingressClassName: nginx
  tls: [{ hosts: [api.example.com], secretName: api-tls }]
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend: { service: { name: api, port: { number: 80 } } }
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: { name: api, namespace: backend }
spec:
  scaleTargetRef: { apiVersion: apps/v1, kind: Deployment, name: api }
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target: { type: Utilization, averageUtilization: 70 }
```

---

### 5. Обоснование выбора

**Почему Kubernetes, а не альтернативы:**

| Критерий | Kubernetes | Docker Swarm | HashiCorp Nomad |
|---|---|---|---|
| Контейнеры | Да | Да | Да (и не только) |
| Service discovery + маршрутизация | Встроено (CoreDNS, Service, Ingress) | Встроено, но проще | Через Consul + Traefik/Fabio |
| Горизонтальное масштабирование | Да | Да | Да |
| Автомасштабирование | HPA, VPA, KEDA, Cluster Autoscaler (зрелое, из коробки) | Нет встроенного | Есть autoscaler, но как отдельный компонент |
| Изоляция внешнего/внутреннего | Service types, Ingress, Namespaces, NetworkPolicy | Overlay-сети, ограниченно | Через Consul Connect/сетевые настройки |
| Env + секреты | ConfigMap, Secret, интеграция с Vault/KMS | Docker Secrets/Configs (базово) | Интеграция с Vault |
| Экосистема и кадры | Стандарт индустрии, огромное сообщество | Практически заморожен | Меньше экосистема |

Ключевые аргументы:

1. **Все шесть требований закрываются штатными средствами** платформы, без самописной «склейки».
2. **Автомасштабирование на двух уровнях** (поды и узлы) встроено в экосистему и хорошо документировано. В Swarm этого нет.
3. **Декларативная модель и самовосстановление:** система сама возвращается к заданному состоянию (перезапуск упавших подов, перепланирование при отказе узла, rolling update и откат).
4. **Переносимость:** один и тот же набор манифестов работает в любом облаке, на bare-metal и в managed-сервисах (Yandex Managed Kubernetes, GKE, EKS, AKS), что снижает зависимость от вендора.
5. **Зрелая экосистема:** Helm и Kustomize для шаблонизации, Argo CD/Flux для GitOps, Prometheus и Grafana для мониторинга, cert-manager для сертификатов.
6. **Безопасность по умолчанию можно довести до высокого уровня:** RBAC, NetworkPolicy, Pod Security Standards, шифрование секретов, интеграция с Vault.

**Ограничения и компромиссы:** Kubernetes сложнее в эксплуатации, чем Swarm. Для снижения нагрузки на сопровождение рекомендуется использовать управляемый кластер (managed Kubernetes), где control plane обслуживает провайдер. Для очень малых проектов (один-два сервиса) такое решение может быть избыточным, но при заданных требованиях (автомасштабирование, изоляция, управление секретами) оно оптимально.

---

### 6. Итог

Решение: **Kubernetes** (containerd + CoreDNS + CNI с NetworkPolicy + Ingress-контроллер) с **HPA/Cluster Autoscaler** для автоматического масштабирования и **Secrets + Vault/External Secrets** для безопасной передачи чувствительных данных через переменные среды. Компоненты взаимодействуют через единый API-сервер и декларативные манифесты: Ingress принимает внешний трафик и передаёт его Service, Service по DNS-имени балансирует запросы между подами, а внутренние сервисы остаются недоступными извне благодаря ClusterIP и сетевым политикам.