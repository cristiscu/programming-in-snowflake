!set variable_substitution=true
!define CRT_DIR=file://C:\Projects\programming-in-snowflake\sections\12-streamlit-in-snowflake\app

CREATE OR REPLACE DATABASE hierarchy_data_viewer;
-- cleanup all with: DROP DATABASE IF EXISTS hierarchy_data_viewer;

CREATE STAGE stage
    directory = (enable=true)
    file_format = (type=CSV field_delimiter=None record_delimiter=None);

-- upload test data file into local EMPLOYEES table
CREATE TABLE employees (EMPLOYEE VARCHAR, MANAGER VARCHAR);
PUT &CRT_DIR\data\employee-manager.csv @stage/data
    overwrite=true auto_compress=false;
COPY INTO employees FROM @stage/data
    FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"'
        NULL_IF='' EMPTY_FIELD_AS_NULL=true);

-- create and configure event table
CREATE OR REPLACE EVENT TABLE myevents;
ALTER ACCOUNT SET EVENT_TABLE = myevents;
SHOW PARAMETERS LIKE 'event_table' IN ACCOUNT;

ALTER DATABASE hierarchy_data_viewer SET LOG_LEVEL = INFO;
ALTER DATABASE hierarchy_data_viewer SET TRACE_LEVEL = ALWAYS;

CREATE TABLE audit_users (start timestamp, user varchar);
CREATE TABLE audit_queries (start timestamp, query varchar);

-- transfer files, create STREAMLIT app
PUT &CRT_DIR\*.py @stage
    overwrite=true auto_compress=false;
PUT &CRT_DIR\environment.yml @stage
    overwrite=true auto_compress=false;

CREATE STREAMLIT hierarchy_data_viewer
    ROOT_LOCATION = '@hierarchy_data_viewer.public.stage'
    MAIN_FILE = '/app.py'
    QUERY_WAREHOUSE = "COMPUTE_WH";
SHOW STREAMLITS;
