# Домашнее задание к занятию "`Использование Terraform в команде`" - `Гайченков Евгений`

## Задание 1

1. terraform_module_pinned_source

Источник модуля закреплён на ветке по умолчанию (ref=main) вместо конкретного тега/коммита — это ненадёжно, т.к. содержимое ветки может измениться.

source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
2. terraform_required_providers

Отсутствует ограничение версии (version constraint) для провайдера в блоке required_providers:

провайдер template (main.tf)
провайдер yandex (providers.tf)
3. terraform_unused_declarations

Объявленные переменные, которые нигде не используются в коде:

public_key
vms_ssh_root_key
vm_web_name
vm_db_name

4. CKV_TF_1 — "Ensure Terraform module sources use a commit hash"
Источник модуля должен быть закреплён на конкретном commit hash, а не на branch/tag:

ресурс test-vm (main.tf:22-43)
ресурс example-vm (main.tf:45-61)

25. CKV_TF_2 — "Ensure Terraform module sources use a tag with a version number"
Источник модуля должен использовать версионный тег:

ресурс test-vm (main.tf:22-43)
ресурс example-vm (main.tf:45-61)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-05/img/1.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-05/img/2.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-05/img/3.png)

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-04/img/4.png)

## Задание 3

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-04/img/5.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-04/img/6.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-04/img/7.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-04/img/8.png)