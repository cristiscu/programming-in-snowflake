-- ====================================================
-- (1) create objects

-- create roles
use role securityadmin;
create or replace role producer;
grant role producer to role sysadmin;
create or replace role consumer;
grant role consumer TO role sysadmin;

-- create database
use role sysadmin;
create or replace database data_clean_room;
create schema producer;
create schema consumer;

-- create database schemas
use role securityadmin;
grant usage on warehouse compute_wh to role producer;
grant usage on warehouse compute_wh to role consumer;
grant usage on database data_clean_room to role consumer;
grant usage on database data_clean_room to role producer;
grant ownership on schema data_clean_room.producer to role producer;
grant ownership on schema data_clean_room.consumer to role consumer;

-- ====================================================
-- (2) create producer tables
use role producer;
use schema data_clean_room.producer;
create or replace table customers (name string, sales float);

insert into customers values
  ('Mark Dole', 12000),
  ('Mike Smith', 4400),
  ('Cheryl Lee', 2000),
  ('John Doe', 2300),
  ('Emma Brown', 1300),
  ('Whoopy Mae', 2300);

-- ====================================================
-- (3) create consumer tables
use role consumer;
use schema data_clean_room.consumer;
create or replace table associates (fullname string, profession string);

insert into associates values
  ('John Doe', 'Teacher'),
  ('Emma Brown', 'Dentist'),
  ('Cheryl Lee', 'Clerk'),
  ('Whoopy Mae', 'Clerk'),
  ('George Lou', 'Teacher');

-- ====================================================
-- (4) producer creates data clean room for consumer
use role producer;
use schema data_clean_room.producer;
create table allowed_statements(statement string);

insert into allowed_statements (statement) values 
('select count(*)
from data_clean_room.producer.customers c join associates a
on c.name = a.fullname;'),
('select a.profession, avg(c.sales)
from data_clean_room.producer.customers c join associates a
on c.name = a.fullname
group by a.profession;');

-- producer allows consumer to run two statements on his customers
create row access policy customer_access_policy
  as (sales float) returns boolean ->
  current_role() in ('ACCOUNTADMIN', 'PRODUCER')
    or exists (
      select statement
      from allowed_statements
      where statement = current_statement());
alter table customers
  add row access policy customer_access_policy on (sales);

grant usage on schema producer to role consumer;
grant select on table customers to role consumer;

-- ====================================================
--(3) consumer runs queries
use role consumer;
use schema data_clean_room.consumer;

-- consumer first tries illegal access to producer's table
select * from data_clean_room.producer.customers;

-- consumer runs allowed statements on producer's table
select count(*)
from data_clean_room.producer.customers c join associates a
on c.name = a.fullname;

select a.profession, avg(c.sales)
from data_clean_room.producer.customers c join associates a
on c.name = a.fullname
group by a.profession;
