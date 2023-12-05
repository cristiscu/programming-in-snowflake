-- run from current folder with: snowsql -c demo_conn -f deploy.sql
!set variable_substitution=true
!define CRT_DIR=file://C:\Projects\programming-in-snowflake\sections\12-streamlit-in-snowflake\app

CREATE OR REPLACE DATABASE hierarchical_data_viewer;
-- cleanup all with: DROP DATABASE IF EXISTS hierarchical_data_viewer;

CREATE STAGE stage
    directory = (enable=true)
    file_format = (type=CSV field_delimiter=None record_delimiter=None);

-- upload test data file into local EMPLOYEES table
CREATE TABLE employees (EMPLOYEE VARCHAR, MANAGER VARCHAR);
PUT &CRT_DIR\data\employee-manager.csv @stage/data overwrite=true auto_compress=false;
COPY INTO employees FROM @stage/data
    FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"'
        NULL_IF='' EMPTY_FIELD_AS_NULL=true);

create procedure show_tree(tableName varchar)
  returns table(name varchar, path varchar)
  language sql
as $$
declare
  rs resultset default (
    with recursive cte (level, name, path, child) as (
      select 1, $1, $1, $1
      from identifier(:tableName) where $2 is null
      union all
      select m.level + 1, repeat('  ', level) || e.$1,
        path || '.' || e.$1, e.$1
      from identifier(:tableName) e join cte m on e.$2 = m.child)
    select name, path from cte order by path);
begin
  return table(rs);
end
$$;

-- create and configure event table
CREATE OR REPLACE EVENT TABLE myevents;
ALTER ACCOUNT SET EVENT_TABLE = hierarchical_data_viewer.public.myevents;
SHOW PARAMETERS LIKE 'event_table' IN ACCOUNT;

ALTER DATABASE hierarchical_data_viewer SET LOG_LEVEL = INFO;
ALTER DATABASE hierarchical_data_viewer SET TRACE_LEVEL = ALWAYS;

-- CREATE TABLE audit_users (start_ts timestamp, user varchar);
-- CREATE TABLE audit_queries (start_ts timestamp, query varchar);

-- transfer files, create STREAMLIT app
PUT &CRT_DIR\modules\*.py @stage/modules overwrite=true auto_compress=false;
PUT &CRT_DIR\app.py @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\environment.yml @stage overwrite=true auto_compress=false;

CREATE STREAMLIT hierarchical_data_viewer
    ROOT_LOCATION = '@hierarchical_data_viewer.public.stage'
    MAIN_FILE = '/app.py'
    QUERY_WAREHOUSE = "COMPUTE_WH";
SHOW STREAMLITS;
