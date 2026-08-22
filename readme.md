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

## Задача 2. Логи

В качестве решения предлагается использовать связку **Vector + Elasticsearch + Kibana**.

**Vector** устанавливается на каждый хост и собирает логи контейнеров из `stdout`. Затем Vector отправляет их в центральный кластер **Elasticsearch**, где логи хранятся и индексируются. Для поиска и анализа используется **Kibana**.

Общая схема:

    Docker-контейнеры
          │
          │ stdout/stderr
          ▼
        Vector
          │
          │ доставка логов
          ▼
    Elasticsearch
          │
          │ поиск / фильтрация
          ▼
        Kibana
          │
          ▼
      Разработчики

Vector не требует специальной интеграции с приложениями: сервисы продолжают писать логи в `stdout`, а Vector забирает их например с Docker-хоста.
Для обеспечения гарантированной доставки Vector может использовать буферизацию и повторную отправку при временной недоступности Elasticsearch.

Elasticsearch обеспечивает:

- централизованное хранение логов со всех хостов;
- индексацию логов;
- быстрый поиск;
- фильтрацию по полям и значениям;
- работу с большими объёмами логов.

Kibana предоставляет веб-интерфейс для разработчиков, где можно выполнять поиск и фильтрацию логов, строить визуализации и сохранять поисковые запросы.

Сохранённый поиск можно предоставить разработчику в виде ссылки на соответствующий объект Kibana.

## Обоснование выбора

Связка **Vector + Elasticsearch + Kibana** позволяет реализовать полный цикл работы с логами: **stdout → Vector → Elasticsearch → Kibana → поиск и анализ**
При этом приложениям не требуется самостоятельно отправлять логи в Elasticsearch: достаточно писать их в `stdout`. Vector централизованно собирает логи например со всех Docker-хостов, Elasticsearch обеспечивает их хранение и поиск, а Kibana предоставляет удобный интерфейс для разработчиков.

# Задача 3. Мониторинг

В качестве решения предлагается использовать связку **Prometheus + Grafana + exporters**.
**Prometheus** собирает метрики со всех хостов и сервисов, а **Grafana** используется для их поиска, анализа и отображения на dashboard.

Общая схема:

    Хосты
      │
      ├── Node Exporter
      │
      ▼
    Prometheus
      │
      ├── метрики хостов
      ├── метрики контейнеров
      └── метрики сервисов
             │
             ▼
           Grafana
             │
             ├── запросы PromQL
             ├── графики
             ├── таблицы
             └── Dashboard

Сервисы дополнительно предоставляют собственные метрики в формате **Prometheus**. Например:

    /metrics

Prometheus периодически обращается к этим endpoint и сохраняет полученные данные.
Grafana подключается к Prometheus и позволяет выполнять запросы с помощью **PromQL**, агрегировать данные и создавать собственные панели мониторинга.

## Обоснование выбора

Связка **Prometheus + Grafana + exporters** позволяет реализовать полный цикл мониторинга: **Host/Service → Exporter → Prometheus → Grafana → Dashboard**
Prometheus отвечает за сбор и хранение метрик, exporters предоставляют метрики хостов и контейнеров, а Grafana предоставляет удобный интерфейс для запросов, агрегации и создания dashboard.
Решение позволяет централизованно контролировать состояние инфраструктуры и отдельно отслеживать потребление ресурсов каждым сервисом.

## Задача 4-5: Логи и Мониторинг
За основу был предоставлен проект [11-microservices-02-principles ](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles) для последующей его обвязки stack сервисами  **Vector + Elasticsearch + Kibana -> Prometheus + Grafana -> Kong**.

### Описание

Учебный проект по построению микросервисной архитектуры и её инфраструктуры.

В проект входят следующие основные компоненты:

- **Kong** — API Gateway для маршрутизации запросов к микросервисам;
- **Security** — сервис аутентификации и выдачи JWT-токенов;
- **Uploader** — сервис загрузки и получения изображений;
- **MinIO** — объектное хранилище для файлов;
- **Prometheus + Grafana** — сбор, хранение и визуализация метрик сервисов и инфраструктуры;
- **Elasticsearch + Kibana + Vector** — централизованный сбор, хранение и анализ логов;
- **Docker Compose** — оркестрация и запуск всех компонентов проекта.

Основные запросы пользователей проходят через **Kong**, который выполняет маршрутизацию к соответствующим сервисам. Метрики сервисов собираются Prometheus и отображаются в Grafana, а логи контейнеров централизованно собираются и анализируются через стек Elasticsearch/Kibana.
Весь проект разворачивается с помощью Docker Compose.

### Перечень развернутых сервисов и пример выполнения микросервисного приложения.
<img width="1901" height="1308" alt="1" src="https://github.com/user-attachments/assets/5005e73c-2784-4492-98e6-ced6e0a2be92" />

### API Gateway Kong с перечнем сервисов и маршрутов.
<img width="1919" height="1438" alt="2" src="https://github.com/user-attachments/assets/9361f053-0e21-454e-84c5-f97f7aa8598b" />

### Полученные логи в Kibana
<img width="1914" height="949" alt="3" src="https://github.com/user-attachments/assets/c119e541-1e5d-4f4e-b6d1-7ed5077e435a" />

### Prometheus target и PromQL запрос
<img width="1912" height="1319" alt="4" src="https://github.com/user-attachments/assets/af01cfdc-f6d0-4e97-ae82-6711d0eb4986" />

### Grafana dashboard (Kong request по сервисам и метрика по кодам выполнения сервисо)
<img width="1912" height="721" alt="5" src="https://github.com/user-attachments/assets/d12ebbf0-1c76-40ca-8606-16d0a08448af" />

# Как протестировать микросервис

### Как запускать
После написания nginx.conf для запуска выполните команду
```
docker-compose up --build
```


### Как тестировать

## Login
Получить токен
```
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost:8000/token
```
Пример
```
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost:8000/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```

### Test
Использовать полученный токен для загрузки картинки
```
curl -X POST -H 'Authorization: Bearer <TODO: INSERT TOKEN>' -H 'Content-Type: octet/stream' --data-binary @image.jpg http://localhost:8000/upload
```
Пример
```
$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @image.jpg http://localhost:8000/upload
{"filename":"c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg"}
```

### Проверить
Загрузить картинку и проверить что она открывается
```
curl localhost:8000/image/<filnename> > <filnename>
```
Example
```
$ curl localhost:8000/images/c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg > c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13027  100 13027    0     0   706k      0 --:--:-- --:--:-- --:--:--  748k

$ ls
c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
```
