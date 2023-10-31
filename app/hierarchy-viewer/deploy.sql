CREATE OR REPLACE DATABASE hierarchy_viewer;

CREATE STAGE stage
    directory = (enable=true)
    file_format = (type=CSV field_delimiter=None record_delimiter=None);

CREATE TABLE emp (
   empno int PRIMARY KEY,
   ename varchar(20) NOT NULL UNIQUE,
   job varchar(20) NOT NULL,
   mgr int,
   hiredate date NOT NULL,
   sal float NOT NULL,
   comm float,
   deptno int NOT NULL);

PUT file://C:\Projects\programming-in-snowflake\data\emp.csv @stage
    overwrite=true auto_compress=false;

COPY INTO emp FROM @stage
    FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"'
        NULL_IF='' EMPTY_FIELD_AS_NULL=true);

PUT file://C:\Projects\programming-in-snowflake\streamlit\hierarchy-viewer\app4.py @stage
    overwrite=true auto_compress=false;

-- PUT file://C:\Projects\programming-in-snowflake\streamlit\hierarchy-viewer\environment.yml @stage
--    overwrite=true auto_compress=false;

-- CREATE FUNCTION import_graphviz()
--    RETURNS VARIANT
--    LANGUAGE PYTHON
--    RUNTIME_VERSION = '3.8'
--    PACKAGES = ('graphviz')
--    HANDLER = 'udf'
-- AS $$
-- import graphviz
-- def udf():
--     return [graphviz.__version__]
-- $$;

CREATE STREAMLIT hierarchy_viewer
    ROOT_LOCATION = '@hierarchy_viewer.public.stage'
    MAIN_FILE = '/app4.py'
    QUERY_WAREHOUSE = "COMPUTE_WH";

SHOW STREAMLITS;
