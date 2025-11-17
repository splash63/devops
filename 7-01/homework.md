# Домашнее задание к занятию "`Ansible.Часть 2`" - `Гайченков Евгений`

## Задание 1

Выполните действия, приложите файлы с плейбуками и вывод выполнения.

Напишите три плейбука. При написании рекомендуем использовать текстовый редактор с подсветкой синтаксиса YAML.

Плейбуки должны:

1. Скачать какой-либо архив, создать папку для распаковки и распаковать скаченный архив. Например, можете использовать официальный сайт и зеркало Apache Kafka. При этом можно скачать как исходный код, так и бинарные файлы, запакованные в архив — в нашем задании не принципиально.
2. Установить пакет tuned из стандартного репозитория вашей ОС. Запустить его, как демон — конфигурационный файл systemd появится автоматически при установке. Добавить tuned в автозагрузку.
3. Изменить приветствие системы (motd) при входе на любое другое. Пожалуйста, в этом задании используйте переменную для задания приветствия. Переменную можно задавать любым удобным способом.

## Решение 1

```yml
---
- name: Apache Kafka
  hosts: all
  become: yes
  vars:
    kafka_version: "4.1.0"
    kafka_download_url: "https://dlcdn.apache.org/kafka/{{ kafka_version }}/kafka-{{ kafka_version }}-src.tgz"
    kafka_home: "/opt/kafka"
    kafka_user: "splash"
    kafka_group: "splash"

  tasks:
    - name: Creating a directory for Kafka
      file:
        path: "{{ kafka_home }}"
        state: directory
        owner: "{{ kafka_user }}"
        group: "{{ kafka_group }}"
        mode: 0755

    - name: Downloading Kafka
      get_url:
        url: "{{ kafka_download_url }}"
        dest: "/tmp/kafka_{{ kafka_version }}.tgz"
        mode: 0644

    - name: Unpacking Kafka
      unarchive:
        src: "/tmp/kafka_{{ kafka_version }}.tgz"
        dest: "{{ kafka_home }}"
        remote_src: yes
        owner: "{{ kafka_user }}"
        group: "{{ kafka_group }}"

    - name: Cleaning temporary files
      file:
        path: "/tmp/kafka_{{ kafka_version }}.tgz"
        state: absent

```

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/apache.png)

```yml
---
- name: Installation and configuration of system tuning service
  hosts: all
  become: yes

  tasks:
    - name: Install tuned package from system repository
      package:
        name: tuned
        state: present

    - name: Start tuned service and enable it on boot
      service:
        name: tuned
        state: started
        enabled: yes

    - name: Verify tuned service status and configuration
      service:
        name: tuned
        state: started

    - name: Check tuned service status
      shell: systemctl status tuned
      register: service_status
      failed_when: "'active (running)' not in service_status.stdout"
```

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/tuned_playbook.png)

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/status.png)

```yml
---
- name: Configure MOTD message
  hosts: all
  become: yes

  vars:
    motd_message: |
      ########################################################
      #                      Welcome!                        #
      ########################################################

  tasks:
    - name: Write new MOTD message
      copy:
        content: "{{ motd_message }}"
        dest: /etc/motd
        owner: root
        group: root
        mode: 0644
```

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/modt_playbook.png)

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/welcome.png)

## Задание 2

Выполните действия, приложите файлы с модифицированным плейбуком и вывод выполнения.

Модифицируйте плейбук из пункта 3, задания 1. В качестве приветствия он должен установить IP-адрес и hostname управляемого хоста, пожелание хорошего дня системному администратору.

## Решение 2

```yml
---
- name: Configure MOTD message
  hosts: all
  become: yes

  vars:
    motd_message: |
      ================================================================
      Welcome to {{ ansible_facts.fqdn }}!
      System IP: {{ ansible_facts.all_ipv4_addresses[0] }}

      Have a great day, System Administrator!
      ================================================================

  tasks:
    - name: Write new MOTD message
      copy:
        content: "{{ motd_message }}"
        dest: /etc/motd
        owner: root
        group: root
        mode: 0644
```
![alt text](https://github.com/splash63/devops/blob/main/7-01/img/modt_playbook_ip.png)

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/ip.png)

## Задание 3

Выполните действия, приложите архив с ролью и вывод выполнения.

Ознакомьтесь со статьёй «Ansible - это вам не bash», сделайте соответствующие выводы и не используйте модули shell или command при выполнении задания.

Создайте плейбук, который будет включать в себя одну, созданную вами роль. Роль должна:

1. Установить веб-сервер Apache на управляемые хосты.
2. Сконфигурировать файл index.html c выводом характеристик каждого компьютера как веб-страницу по умолчанию для Apache. Необходимо включить CPU, RAM, величину первого HDD, IP-адрес. Используйте Ansible facts и jinja2-template. Необходимо реализовать handler: перезапуск Apache только в случае изменения файла конфигурации Apache.
3. Открыть порт 80, если необходимо, запустить сервер и добавить его в автозагрузку.
4. Сделать проверку доступности веб-сайта (ответ 200, модуль uri).

В качестве решения:

* предоставьте плейбук, использующий роль;
* разместите архив созданной роли у себя на Google диске и приложите ссылку на роль в своём решении;
* предоставьте скриншоты выполнения плейбука;
* предоставьте скриншот браузера, отображающего сконфигурированный index.html в качестве сайта.

## Решение 3
```yml
---
- name: Deploy Apache server with system info
  hosts: webservers
  become: yes

  roles:
    - apache_setup
```
Весь проект роли в папке apache_server
![alt text](https://github.com/splash63/devops/blob/main/7-01/img/apache_role.png)
![alt text](https://github.com/splash63/devops/blob/main/7-01/img/web.png)