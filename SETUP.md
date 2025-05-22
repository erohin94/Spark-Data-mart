#**Настройка техническая составляющей**

**Инструкция по настройке Postgresql, Clickhouse, Superset.**

**Postgresql**

1.Для начала создадим файл docker-compose.yml. С необходимыми настройками.

```
services:
  postgres:
    image: postgres:15
    restart: always
    container_name: postgres
    environment:
      POSTGRES_USER: test
      POSTGRES_PASSWORD: 1
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
      

  clickhouse:
    image: yandex/clickhouse-server:latest
    container_name: clickhouse
    restart: always
    ports:
      - "8123:8123"
      - "9000:9000"
    environment:
      CLICKHOUSE_USER: clickuser
      CLICKHOUSE_PASSWORD: 2
    volumes:
      - ./clickhouse_data:/var/lib/clickhouse


volumes:
  postgres_data:
  clickhouse_data:
```
Этот файл как раз и позволит запустить 2 контейнера: один с PostgreSQL, а другой с ClickHouse.

2. Открыть Docker Desktop.

3. Открыть CMD терминал и перейти в папку с проектом где лежит docker-compose.yml.

4. Запустить Docker Compose
Для запуска используем команду в терминале CMD:

```
docker-compose up -d
```

![image](https://github.com/user-attachments/assets/9a359dbe-0907-4568-89b8-e362ad6139cd)



