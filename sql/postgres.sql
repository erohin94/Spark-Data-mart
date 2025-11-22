/* Проверка подключения к БД */
SELECT 1;


/* Проверка прав на создание таблиц */
SELECT current_database(), current_user;

SELECT nspname AS schema_name,
       nspowner::regrole AS owner,
       nspacl
FROM pg_namespace
WHERE nspname = 'public';


/* Удаляю таблицу если она есть */
DROP TABLE IF EXISTS costs; 
/

/* Создаю таблицу сли ее нет */
CREATE TABLE IF NOT EXISTS costs(
    date date,
    campaign_id int,
    costs float,
    clicks int,
    views int
)

/* Проверка */
SELECT * FROM costs;


--methodology
select
    date,
    campaign_id,
    round(sum(costs)::numeric, 2) as costs,
    sum(clicks) as clicks,
    sum(views) as views
from public.costs
group by date, campaign_id
order by date, campaign_id;


/* Пример создания таблицы и добавления в нее данных из CSV файла, который лежит в папке Windows на моем компьютере */
/* Пример как считать таблицу прямо из файла.
 * Важно, чтобы путь был прописан в докер файле
 * COPY FROM читается на стороне PostgreSQL-сервера, а НЕ клиента.
 * PostgreSQL-сервер работает внутри контейнера.
 * 1) Создай папку на хосте. На Windows: C:\Users\erohi\Desktop\spark_data_mart\notebooks\data 
 * Убедись, что файл находится ТАМ: C:\Users\erohi\Desktop\spark_data_mart\notebooks\data\costs_postgres.csv
 * 2) Добавь volume в docker-compose.yml  
 * - ./notebooks/data:/data # ← ДОБАВЬ ЭТО
 * 3) Пересоберать контейнер PostgreSQL, если ранее не была добалена папка в Volume postgreSQL
 * Так как это volume — пересоздать контейнер:
 * docker compose down
 * docker compose up -d 
 * 4) Проверь, что файл есть внутри контейнера
 * docker exec -it postgres bash
 * ls /data
 * Ожидаемый вывод: costs_postgres.csv */
/*
Чтобы CSV файл был виден PostgreSQL-серверу, нужно:
1.Положить файл в локальную папку проекта.
2.Смонтировать её в контейнер (./notebooks/data:/data).
3.Пересоздать контейнер.
4.Использовать COPY с путём внутри контейнера:
COPY costs_test FROM '/data/costs_postgres.csv' CSV HEADER;
*/

/* Создаю таблицу если ее нет */
CREATE TABLE IF NOT EXISTS costs_test(
    date date,
    campaign_id int,
    costs float,
    clicks int,
    views int
)

/* Загружаем данные в таблицу costs_test */
COPY costs_test
FROM '/data/costs_postgres.csv'
DELIMITER ','
CSV HEADER;

/* Проверяю */
SELECT * FROM costs_test;

