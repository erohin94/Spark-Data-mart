## Настройка технической составляющей

**Инструкция по настройке Postgresql, Clickhouse, Jupyter, Spark, Metabase.**

1. Для начала создадим файл `docker-compose.yml`. С необходимыми настройками.

```
services:
  jupyter:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: jupyter
    ports:
      - "8888:8888"   # Jupyter
      - "4040:4040"   # Spark UI
    volumes:
      - ./notebooks:/home/jovyan/work
    environment:
      - PYSPARK_PYTHON=python
    command: start-notebook.sh
    restart: always

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
    image: clickhouse/clickhouse-server:latest
    container_name: clickhouse
    environment:
      CLICKHOUSE_USER: default
      CLICKHOUSE_PASSWORD: mypassword
    ports:
      - "8123:8123"   # HTTP
      - "9000:9000"   # TCP
    volumes:
      - chdata:/var/lib/clickhouse

  metabase:
    image: metabase/metabase:latest
    container_name: metabase
    ports:
      - "3000:3000"
    environment:
      # Metabase использует PostgreSQL для хранения своей мета-информации
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: mydb
      MB_DB_PORT: 5432
      MB_DB_USER: admin
      MB_DB_PASS: admin
      MB_DB_HOST: postgres
    depends_on:
      - postgres
      - clickhouse

volumes:
  pgdata:
  chdata:
```

2. Создадим файл Dockerfile.
   
```
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
```

3. Сохранить `docker-compose.yml` и `Dockerfile` в одной папке.

4. Создай папку `notebooks` для Jupyter ноутбуков.

5. Создать папку jars для `jar` файлов и [скачать](https://github.com/erohin94/Spark-Data-mart/tree/main/jars) в нее джарники.

<img width="643" height="112" alt="image" src="https://github.com/user-attachments/assets/951f4ea5-8f03-4ad0-83b8-0e816b32aa8e" />

Структура папок

<img width="621" height="157" alt="image" src="https://github.com/user-attachments/assets/741a8449-da29-4356-8a1c-ab96ef6bddb0" />

6. Открыть Docker Desktop.

7. Открыть CMD терминал и перейти в папку с проектом где лежит `docker-compose.yml` и `Dockerfile`.

8. Запустить Docker Compose. Для запуска используем команду в терминале CMD:

`docker-compose up -d --build`

<img width="548" height="20" alt="image" src="https://github.com/user-attachments/assets/b88a8128-14a4-4cc4-ab45-386869b83bec" />

Настройка подключений в DBeaver.

<img width="1773" height="617" alt="image" src="https://github.com/user-attachments/assets/d9dbf7fe-e47c-44eb-a50a-43b2a07e89de" />


**Запуск Jupyter**

![image](https://github.com/user-attachments/assets/9442b3d0-d0d4-4d94-8bc0-dc73217b387d)

Заходим по ссылке http://localhost:8888/

Появится следующее окно:

![image](https://github.com/user-attachments/assets/d403d881-660c-4e4e-a810-b3aa710a3813)

Вводим в терминале 

`docker logs jupyter`

![image](https://github.com/user-attachments/assets/d87b2f83-ea6a-402a-9baf-7139a744595f)

![image](https://github.com/user-attachments/assets/ce8e033f-56a1-4742-92ed-09b970ec4291)

И ищем строку вида `http://127.0.0.1:8888/lab?token=cc9b05f96f`, копируем всю строку и вставляем в браузер, после чего открывается ноутбук.

Либо копируем токен и вставляем в поле `Password or token` и так же переходим в ноутбук.

![image](https://github.com/user-attachments/assets/84140b14-f9e2-4c97-ae52-e9c4cefb27c7)

Так же можно сделать запуск без ввода логина или токена. Создав `.yml` файл, добавив в него строку `command: start-notebook.sh --NotebookApp.token=''` следующего вида

```
command: start-notebook.sh --NotebookApp.token=''
```


**Доступные интерфейсы:**

Jupyter: `http://localhost:8888`

Spark UI: `http://localhost:4040 (активен пока работает SparkSession)`

Metabase: `http://localhost:3000`

Postgres: `localhost:5432`

ClickHouse: `localhost:8123`

## Тесты

Запускать из юпитера

```
from pyspark.sql import SparkSession

# Создаём SparkSession
spark = SparkSession.builder \
    .appName("TestApp") \
    .master("local[*]") \
    .config("spark.driver.host", "0.0.0.0") \
    .getOrCreate()

print("Spark UI:", spark.sparkContext.uiWebUrl)

# Простейший тест
df = spark.range(10)
df.show()
input("Spark запущен. Перейди в http://localhost:4040 и нажми Enter, чтобы завершить...")
```

```
spark.stop()
```

```
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("TestApp") \
    .master("local[*]") \
    .config("spark.driver.host", "localhost").getOrCreate()
```

```
print("Spark UI:", spark.sparkContext.uiWebUrl)
````

```
import clickhouse_connect

client = clickhouse_connect.get_client(
    host='localhost',
    port=8123,
    username='default',
    password='mypassword'
)

# Простейшая команда
print(client.command("SELECT 1"))
```

```
import clickhouse_connect

client = clickhouse_connect.get_client(
    host='clickhouse',  # имя сервиса из docker-compose.yml
    port=8123,
    username='default',
    password='mypassword'
)

print(client.command("SELECT 1"))
```

```
import psycopg2

conn = psycopg2.connect(
    host="postgres",
    port=5432,
    database="mydb",
    user="admin",
    password="admin"
)
cur = conn.cursor()
cur.execute("SELECT 1;")
print(cur.fetchone())  # должно вывести (1,)
cur.close()
conn.close()
```
