# Домашнее задание к занятию "`Основы Terraform. Yandex Cloud`" - `Гайченков Евгений`

## Задание 1

4 В variable "cloud_id" и variable "folder_id"  не указана строка default, не указана зона по умолчанию при создании машины, platform_id = "standard-v4a" с приписнок а только есть можно создать с 20% лимитом минимум 5 % нету, ${file(var.vms_ssh_root_key)} должны передавать сам файл а не строку

5
![alt text](https://github.com/splash63/devops/blob/main/terr-hw-02/img/1.png)

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-02/img/2.png)

6 preemptible = true это прерываемая машина котора будет выключена в течении 24ч автоматически, экономит финансовые средства, core_fraction=5 это лимит использования ядра в 5%, так же удешевляет стоимость ВМ

## Задание 4

![alt text](https://github.com/splash63/devops/blob/main/terr-hw-02/img/4.png)

[src](https://github.com/splash63/devops/tree/main/terr-hw-02/src)