-- create test database and schema
create or replace database lineage_db;
create schema test_schema;

-- create new table, then populate it with dynamic content
create table T1(content variant);
insert into T1(content) select parse_json('{"name": "A", "id":1}');

-- create new table, then populate it with content of the previous table
create table T6(content variant);
insert into T6 select * from T1;

-- create new table, and directly populate it with T1 content
create table T2 as select content:"name" as name, content:"id" as id from T1;

-- create new user stage, then copy T1's content here
create stage S1;
copy into @S1 from T1;

-- create new table, then copy from the stage content
create table T3(customer_info variant);
copy into T3 from @S1;

-- create new table, then add T1's content
create table T4(name string, id string, address string);
insert into T4(name, id) select content:"name", content:"id" from T1;

-- create new table, and directly populate it with T6 content
create table T7 as select * from T6;