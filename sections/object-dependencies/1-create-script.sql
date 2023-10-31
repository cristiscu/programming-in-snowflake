create or replace database deps_db;

create table T1(id int, json variant);
create table T2(id int, id_t1 int, name string);

create view T12 as (
  select json, name
  from T1 join T2 on T1.id = T2.id_t1);
create materialized view T2M
  as select id, id_t1 from T2;

create function F1()
  returns int
as 'select top 1 id from T1';
