create database if not exists data_pipelines;
create or replace schema data_pipelines.manual_cdc;

-- source (table) --> target (table), w/ MERGE in stored proc
CREATE TABLE source(del BOOLEAN, id INT, name STRING);
CREATE TABLE target(id INT, name STRING);

merge into target t using source s on  t.id = s.id
  when not matched and not del then insert (id, name) values (s.id, s.name)
  when matched and del then delete
  when matched and not del then update set t.name = s.name;

create procedure cdc() returns int
as $$
merge into target t using source s on  t.id = s.id
  when not matched and not del then insert (id, name) values (s.id, s.name)
  when matched and del then delete
  when matched and not del then update set t.name = s.name;
$$;

-- 3 x INSERT
INSERT INTO source VALUES (False, 1, 'John'), (False, 2, 'Mary'), (False, 3, 'George');
CALL cdc();
TRUNCATE TABLE source;
SELECT * FROM target;

-- UPDATE + INSERT
INSERT INTO source VALUES (False, 1, 'Mark'), (True, 2, NULL);
CALL cdc();
TRUNCATE TABLE source;
SELECT * FROM target;
