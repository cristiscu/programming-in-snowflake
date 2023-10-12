-- select database and schema
use schema employees.public;

CREATE TABLE raw(var VARIANT);
CREATE STREAM raws ON TABLE raw;
CREATE TABLE names(id INT, name STRING);

CREATE TASK raw_to_names
  WAREHOUSE = 'COMPUTE_WH'
  SCHEDULE = '1 minute'
  WHEN SYSTEM$STREAM_HAS_DATA('raws')
AS 
  MERGE INTO names n
    USING (SELECT var:id id, var:name name FROM raws) r
    ON n.id = TO_NUMBER(r.id)
  WHEN MATCHED AND metadata$action = 'DELETE' THEN
    DELETE
  WHEN MATCHED AND metadata$action = 'INSERT' THEN
    UPDATE SET n.name = r.name
  WHEN NOT MATCHED AND metadata$action = 'INSERT' THEN
    INSERT (id, name) VALUES (r.id, r.name);


ALTER TASK raw_to_names RESUME;
ALTER TASK raw_to_names SUSPEND;

INSERT INTO raw SELECT parse_json('{"id": 1, "name": "John"}');
INSERT INTO raw SELECT parse_json('{"id": 2, "name": "Mary"}');
INSERT INTO raw SELECT parse_json('{"id": 3, "name": "George"}');

SELECT * FROM raw;
SELECT * FROM names;
