-- source (table) --> source_s (stream) --> target (table)
CREATE OR REPLACE TABLE source(id INT, name STRING);
CREATE OR REPLACE STREAM source_s ON TABLE source;
CREATE OR REPLACE TABLE target(id INT, name STRING);

-- task on source_s data stream, w/ MERGE statement
CREATE OR REPLACE TASK s2t_task
  WAREHOUSE = compute_wh
  SCHEDULE = '1 minute'
  WHEN SYSTEM$STREAM_HAS_DATA('source_s')
AS 
  MERGE INTO target t USING source_s s ON t.id = s.id
  WHEN MATCHED AND metadata$action = 'DELETE'
    AND metadata$isupdate = 'FALSE' 
    THEN DELETE
  WHEN MATCHED AND metadata$action = 'INSERT'
    AND metadata$isupdate = 'TRUE' 
    THEN UPDATE SET t.name = s.name
  WHEN NOT MATCHED AND metadata$action = 'INSERT'
    THEN INSERT (id, name) VALUES (s.id, s.name);
ALTER TASK s2t_task RESUME;

-- insert 3 rows in the source table
INSERT INTO source VALUES (1, 'John'), (2, 'Mary'), (3, 'George');
SELECT * FROM source;
SELECT SYSTEM$STREAM_HAS_DATA('source_s');

-- could manually execute the task and look at its execution
EXECUTE TASK s2t_task;
SELECT * 
FROM TABLE(information_schema.task_history(task_name=>'s2t_task'))
ORDER BY run_id DESC;
SELECT * FROM target;

-- update+delete existing source rows --> target should make in-place changes
UPDATE source SET name = 'Mark' WHERE id = 1;
DELETE FROM source WHERE id = 2;
SELECT SYSTEM$STREAM_HAS_DATA('source_s');
SELECT * FROM target;