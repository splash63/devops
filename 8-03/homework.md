# Домашнее задание к занятию "`GitLab`" - `Гайченков Евгений`

## Задание 1

Что нужно сделать:

1. Разверните GitLab локально, используя Vagrantfile и инструкцию, описанные в этом репозитории.
2. Создайте новый проект и пустой репозиторий в нём.
3. Зарегистрируйте gitlab-runner для этого проекта и запустите его в режиме Docker. Раннер можно регистрировать и запускать на той же виртуальной машине, на которой запущен GitLab.
В качестве ответа в репозиторий шаблона с решением добавьте скриншоты с настройками раннера в проекте.
---

## Решение 1

![alt text](https://github.com/splash63/devops/blob/main/8-03/img/runner.png)

![alt text](https://github.com/splash63/devops/blob/main/8-03/img/runner_settins.png)
---

## Задание 2

Что нужно сделать:

1. Запушьте репозиторий на GitLab, изменив origin. Это изучалось на занятии по Git.
2. Создайте .gitlab-ci.yml, описав в нём все необходимые, на ваш взгляд, этапы.
В качестве ответа в шаблон с решением добавьте:

* файл gitlab-ci.yml для своего проекта или вставьте код в соответствующее поле в шаблоне;
* скриншоты с успешно собранными сборками.
---

## Решение 2

```yml
stages:
  - test
  - build

test:
  stage: test
  image: golang:1.17
  script: 
   - go test .

build:
  stage: build
  image: docker:latest
  script:
   - docker build .
```

![alt text](https://github.com/splash63/devops/blob/main/8-03/img/passed.png)
---

## Задание 3*

Измените CI так, чтобы:

* этап сборки запускался сразу, не дожидаясь результатов тестов;
* тесты запускались только при изменении файлов с расширением *.go.
В качестве ответа добавьте в шаблон с решением файл gitlab-ci.yml своего проекта или вставьте код в соответсвующее поле в шаблоне.
---

## Решение 3*

![alt text](https://github.com/splash63/devops/blob/main/8-03/img/new_pipeline.png)

```yml
stages:
  - test
  - build

test:
  stage: test
  image: golang:1.17
  script:
    - go test ./...
  rules:
    - changes:
        - "*.go"

build:
  stage: build
  image: docker:latest
  script:
    - docker build .
  rules:
    - when: always
```