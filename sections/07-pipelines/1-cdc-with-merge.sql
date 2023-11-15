-- in data_pipelines.cdc schema
create if not exists database data_pipelines;
create or replace schema data_pipelines.cdc;

-- source (table) --> target (table), w/ MERGE in stored proc
CREATE OR REPLACE TABLE source(del BOOLEAN, id INT, name STRING);
CREATE OR REPLACE TABLE target(id INT, name STRING);

CREATE OR REPLACE PROCEDURE cdc() RETURNS int
AS $$
  MERGE INTO target t USING source s ON t.id = s.id
  WHEN MATCHED AND del THEN DELETE
  WHEN MATCHED AND NOT del THEN UPDATE SET t.name = s.name
  WHEN NOT MATCHED AND NOT del THEN INSERT (id, name) VALUES (s.id, s.name)
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
