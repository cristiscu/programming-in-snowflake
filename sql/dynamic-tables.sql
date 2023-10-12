-- select database and schema
use schema employees.public;

CREATE TABLE raw2(var VARIANT);

CREATE DYNAMIC TABLE names2
  WAREHOUSE = 'COMPUTE_WH'
  TARGET_LAG = '1 minute'
AS
  SELECT var:id::int id, var:name::string name
  FROM raw2;

-- =================================================
INSERT INTO raw2
   SELECT parse_json('{"id": 1, "name": "John"}');
INSERT INTO raw2
   SELECT parse_json('{"id": 2, "name": "Mary"}');
INSERT INTO raw2
   SELECT parse_json('{"id": 3, "name": "George"}');

SELECT * FROM raw2;
SELECT * FROM names2 ORDER BY id;

UPDATE raw2
   SET var = parse_json('{"id": 1, "name": "Mark"}')
   WHERE var:id = 1;

DELETE FROM raw2
   WHERE var:name = 'Mary';

INSERT INTO raw2
   SELECT parse_json('{"id": 4, "name": "Santiago"}');

-- =====================================================
ALTER DYNAMIC TABLE names2 SUSPEND;
