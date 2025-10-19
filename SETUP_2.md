Установка для работы всех сервисов вместе

**Как запускать**

Сохранить `docker-compose.yml` и `Dockerfile` в одной папке.

Создай папку `notebooks` для Jupyter ноутбуков.

Запустить:

`docker-compose up -d --build`


**Доступные интерфейсы:**

Jupyter: `http://localhost:8888`

Spark UI: `http://localhost:4040 (активен пока работает SparkSession)`

Metabase: `http://localhost:3000`

Postgres: `localhost:5432`

ClickHouse: `localhost:8123`


docker-compose.yml
```
services:
  postgres:
    image: postgres:15
    container_name: postgres
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  clickhouse:
    image: clickhouse/clickhouse-server
    container_name: clickhouse
    ports:
      - "8123:8123"   # HTTP интерфейс
      - "9000:9000"   # TCP интерфейс
    volumes:
      - chdata:/var/lib/clickhouse

  jupyter:
    image: jupyter/base-notebook
    container_name: jupyter
    ports:
      - "8888:8888"
      - "4040:4040"   # Spark UI
    volumes:
      - ./notebooks:/home/jovyan/work
    restart: always
    environment:
      - PYSPARK_PYTHON=python
    command: start-notebook.sh
    # Установка PySpark, psycopg2 и clickhouse-driver при старте
    build:
      context: .
      dockerfile: Dockerfile

  metabase:
    image: metabase/metabase
    container_name: metabase
    ports:
      - "3000:3000"
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: mydb
      MB_DB_PORT: 5432
      MB_DB_USER: admin
      MB_DB_PASS: admin
      MB_DB_HOST: postgres
    depends_on:
      - postgres

volumes:
  pgdata:
  chdata:
```

Dockerfile
```
FROM jupyter/base-notebook

USER root

# Установка Java для Spark
RUN apt-get update && apt-get install -y openjdk-21-jdk && rm -rf /var/lib/apt/lists/*

# Установка PySpark и драйверов для Postgres и ClickHouse
RUN pip install pyspark psycopg2-binary clickhouse-connect

USER jovyan
```

