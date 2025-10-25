FROM jupyter/base-notebook:latest

USER root

# Установка Java
RUN apt-get update && apt-get install -y openjdk-21-jdk wget curl && rm -rf /var/lib/apt/lists/*

# Установка Spark
ENV SPARK_VERSION=4.0.1
ENV HADOOP_VERSION=3

RUN wget https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar xvf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local/ \
    && mv /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

ENV SPARK_HOME=/usr/local/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Установка PySpark и драйверов
RUN pip install --no-cache-dir pyspark psycopg2-binary clickhouse-connect

# Копирование JDBC-драйверов в контейнер
# Предварительно положите JAR-файлы в папку ./jars:
#   - postgresql-42.6.0.jar
#   - clickhouse-jdbc-0.4.6-all.jar
# -----------------------
COPY jars /usr/local/spark/jars

# Переменные среды для Java и Spark
# -----------------------
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

USER jovyan
