# Домашнее задание к занятию «Микросервисы: подходы»

## Задача 1: Обеспечить разработку
В качестве решения предлагается использовать **GitLab.com** для хранения исходного кода и организации CI/CD, а для выполнения сборок — **GitLab Runner**, установленные на собственных серверах.
Для каждого микросервиса создаётся отдельный Git-репозиторий:

    GitLab
    ├── security
    ├── uploader
    └── storage

В каждом репозитории находится `.gitlab-ci.yml`, описывающий процесс сборки и тестирования.

Общая схема:

    Developer
        │
        │ git push
        ▼
     GitLab.com
        │
        ▼
     CI/CD Pipeline
        │
        ├── Tests
        ├── Build
        └── Docker image
               │
               ▼
        GitLab Registry
               │
               ▼
           Deploy

GitLab позволяет:

- автоматически запускать pipeline после `git push`;
- запускать pipeline вручную с параметрами;
- хранить настройки сборки в CI/CD Variables;
- создавать общие шаблоны CI/CD;
- безопасно хранить пароли, токены и ключи;
- иметь несколько конфигураций сборки из одного репозитория;
- выполнять произвольные команды на этапах CI;
- использовать собственные Docker-образы для сборки;
- устанавливать GitLab Runner на собственные серверы;
- выполнять несколько jobs и тестов параллельно.

## Обоснование выбора

GitLab выбран потому, что объединяет **Git, CI/CD, хранение секретов, шаблоны, Container Registry и управление Runner** в одной облачной системе.
Таким образом, решение обеспечивает полный процесс: **Git → тестирование → сборка → Docker Registry → развёртывание**, а выполнение сборок можно осуществлять на собственных серверах с помощью GitLab Runner.




# Как запускать
После написания nginx.conf для запуска выполните команду
```
docker-compose up --build
```

# Как тестировать

## Login
Получить токен
```
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
```
Пример
```
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```

## Test
Использовать полученный токен для загрузки картинки
```
curl -X POST -H 'Authorization: Bearer <TODO: INSERT TOKEN>' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
```
Пример
```
$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
{"filename":"c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg"}
```

 ## Проверить
Загрузить картинку и проверить что она открывается
```
curl localhost/image/<filnename> > <filnename>
```
Example
```
$ curl localhost/images/c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg > c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13027  100 13027    0     0   706k      0 --:--:-- --:--:-- --:--:--  748k

$ ls
c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
```
