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

    - name: Verify MOTD content
      shell: |
        grep -q "{{ motd_message }}" /etc/motd
      register: motd_check
      failed_when: motd_check.rc != 0
```

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/modt_playbook.png)

![alt text](https://github.com/splash63/devops/blob/main/7-01/img/welcome.png)