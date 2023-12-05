-- run from current folder: snowsql -c demo_conn -f 1-create-script.sql
use schema employees.public;

-- create test target table, stage and pipe
create or replace table emp_pipe like emp;

create or replace stage mystage_pipe;

create or replace pipe mypipe
  auto_ingest = false
as
  copy into emp_pipe from @mystage_pipe;

-- upload both CSV files from the local data folder into the internal stage
-- put file://C:\Projects\programming-in-snowflake\sections\14-rest-apis\3-snowpipe-api\data\*.csv @mystage_pipe
--   overwrite=true auto_compress=false;

list @mystage_pipe;

-- after the transfer, check again if properly populated
select * from emp_pipe;
