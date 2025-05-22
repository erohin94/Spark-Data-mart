# **Настройка технической составляющей**

**Инструкция по настройке Postgresql, Clickhouse, Jupyter, Superset.**

**Postgresql, Clickhouse**

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

Переходим в DBeaver и создаем подключения.

![image](https://github.com/user-attachments/assets/2fa79591-860f-455c-b821-30645910277d)

**Jupyter**

1.Создадим файл docker-compose.yml. С необходимыми настройками.

```
version: '3'

services:
  jupyter:
    image: jupyter/base-notebook
    container_name: jupyter
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work
    restart: always
```

```
docker-compose up -d
```

![image](https://github.com/user-attachments/assets/9442b3d0-d0d4-4d94-8bc0-dc73217b387d)

Заходим по ссылке http://localhost:8888/

Появится следующее окно:

![image](https://github.com/user-attachments/assets/d403d881-660c-4e4e-a810-b3aa710a3813)

Вводим в терминале 

`docker logs jupyter`

![image](https://github.com/user-attachments/assets/d87b2f83-ea6a-402a-9baf-7139a744595f)

И ищем строку вида `http://127.0.0.1:8888/lab?token=cc9b05f96f`, копируем всю строку и вставляем в браузер, после чего открывается ноутбук.

Либо копируем токен и вставляем в поле 

![image](https://github.com/user-attachments/assets/84140b14-f9e2-4c97-ae52-e9c4cefb27c7)

Так же можно сделать запуск без ввода логина или токена. Создав `.yml` файл, добавив в него строку `command: start-notebook.sh --NotebookApp.token=''` следующего вида

```
services:
  jupyter:
    image: jupyter/base-notebook
    container_name: jupyter
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work
    restart: always
    command: start-notebook.sh --NotebookApp.token=''
```

