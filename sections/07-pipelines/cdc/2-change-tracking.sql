create database if not exists data_pipelines;
create or replace schema data_pipelines.change_tracking;

-- source (table) --> target (table), w/ CHANGE_TRACKING
CREATE OR REPLACE TABLE source(id INT, name STRING);
ALTER TABLE source SET CHANGE_TRACKING = TRUE;

-- set initial point in time
SET ts1 = (SELECT CURRENT_TIMESTAMP());

-- 3 x INSERT
INSERT INTO source VALUES (1, 'John'), (2, 'Mary'), (3, 'George');

-- UPDATE + INSERT
UPDATE source SET name = 'Mark' WHERE id = 1;
DELETE FROM source WHERE id = 2;

-- see all INSERTs
SELECT * FROM source
CHANGES (INFORMATION => APPEND_ONLY) AT (TIMESTAMP => $ts1);

SELECT * FROM source
CHANGES (INFORMATION => DEFAULT) AT (TIMESTAMP => $ts1);

-- create target with all changes
CREATE OR REPLACE TABLE target AS
  SELECT id, name FROM source
  CHANGES (INFORMATION => DEFAULT) AT (TIMESTAMP => $ts1);
SELECT * FROM target;
