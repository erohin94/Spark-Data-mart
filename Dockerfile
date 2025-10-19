FROM jupyter/base-notebook

USER root

# Установка Java для Spark
RUN apt-get update && apt-get install -y openjdk-21-jdk && rm -rf /var/lib/apt/lists/*

# Установка PySpark и драйверов для Postgres и ClickHouse
RUN pip install pyspark psycopg2-binary clickhouse-connect

USER jovyan