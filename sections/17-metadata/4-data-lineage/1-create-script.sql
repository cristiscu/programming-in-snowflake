-- create test database and schema
-- [object_modified_by_ddl]
create or replace database lineage_db;

-- [object_modified_by_ddl]
create schema test_schema;

-- create new table, then populate it with dynamic content
-- [object_modified_by_ddl]
create table T1(content variant);

-- --> T1.content [direct_objects_accessed]
insert into T1(content) select parse_json('{"name": "A", "id":1}');

-- create new table, then populate it with content of the previous table
-- [object_modified_by_ddl]
create table T6(content variant);

-- T1.content --> T6.content [direct_objects_accessed]
insert into T6 select * from T1;

-- create new table, and directly populate it with T1 content
-- T1.name/id --> T2.name/id [direct_objects_accessed]
create table T2 as select content:"name" as name, content:"id" as id from T1;

-- create new user stage, then copy T1's content here
-- [object_modified_by_ddl]
create stage S1;

-- T1 --> S1 [direct_objects_accessed]
copy into @S1 from T1;

-- create new table, then copy from the stage content
-- [object_modified_by_ddl]
create table T3(customer_info variant);

-- S1 --> T3 [direct_objects_accessed]
copy into T3 from @S1;

-- create new table, then add T1's content
-- [object_modified_by_ddl]
create table T4(name string, id string, address string);

-- T1.content --> T4.content [direct_objects_accessed]
insert into T4(name, id) select content:"name", content:"id" from T1;

-- create new table, and directly populate it with T6 content
-- T6.content --> T7.content [direct_objects_accessed]
create table T7 as select * from T6;