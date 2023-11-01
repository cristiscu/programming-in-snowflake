-- generates 1M rows with fake data in Snowflake's web UI
select
  randstr(uniform(10, 30, random(1)), uniform(1, 100000, random(1)))::varchar(30) as name,
  randstr(uniform(10, 30, random(2)), uniform(1, 10000, random(2)))::varchar(30) as city,
  randstr(10, uniform(1, 100000, random(3)))::varchar(10) as license_plate,
  randstr(uniform(10, 30, random(4)), uniform(1, 200000, random(4)))::varchar(30) as email
from table(generator(rowcount => 1000000));
