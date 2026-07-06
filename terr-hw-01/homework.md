# Домашнее задание к занятию "`Введение в Terraform`" - `Гайченков Евгений`

## Задание 1

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/1.png)

2 В файле personal.auto.tfvars

3

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/3.png)

4

Не объявлен провайдер random. Неверное имя ресурса в ссылке random_password.random_string_FAKE.resulT нужно исправить на random_password.random_string.result и регистр важен у слова result.

5

```bash
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
    random = {
    source = "hashicorp/random"
  }
  }
  required_version = "~>1.15.0" /*Многострочный комментарий.
 Требуемая версия terraform */
}
provider "docker" {}

#однострочный комментарий

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}
```

6
Главная опасность ключа -auto-approve в том, что он пропускает этап ручной проверки и подтверждения изменений перед их применением. Из-за этого повышается риск случайно внести нежелательные или даже деструктивные изменения в инфраструктуру

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/6.png)

7

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/7.png)

8

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/8.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-01/img/8.1.png)