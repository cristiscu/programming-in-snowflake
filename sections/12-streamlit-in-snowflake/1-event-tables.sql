-- creates context
use schema employees.public;

-- =======================================================
-- (1) create and configure event table
CREATE OR REPLACE EVENT TABLE myevents2;
ALTER ACCOUNT SET EVENT_TABLE = employees.public.myevents2;
SHOW EVENT TABLES;
SHOW PARAMETERS LIKE 'event_table' IN ACCOUNT;

ALTER DATABASE employees SET LOG_LEVEL = INFO;
ALTER DATABASE employees SET TRACE_LEVEL = ALWAYS;

-- =======================================================
-- (2) test w/ SQL Scripting stored proc
CREATE OR REPLACE PROCEDURE log_sql_demo(message VARCHAR)
  RETURNS VARCHAR NOT NULL
  LANGUAGE SQL
AS
BEGIN
  select * from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CALL_CENTER limit 10;
  
  SYSTEM$LOG_INFO('Processed ' || :message);
  SYSTEM$LOG_ERROR('Failed ' || :message);
  SYSTEM$LOG_WARN('Warning  ' || :message);
END;

call log_sql_demo('This is a test message from SQL');
select * from myevents2;

-- =======================================================
-- (3) test w/ Python stored proc
create or replace procedure log_python_demo()
  returns int
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python', 'snowflake-telemetry-python')
  handler = 'demo'
as $$
import logging
from snowflake import telemetry

def demo(session):
    # log message
    logger = logging.getLogger("mylog")
    logger.info("This is an INFO test message from Pyhton.")
    
    # trace events
    telemetry.add_event("FunctionEmptyEvent")
    telemetry.add_event("FunctionEventWithAttributes", {"key1": "value1"})
$$;

call log_python_demo();
select * from myevents2 where record['severity_text'] = 'INFO';
select * from myevents2 where record_type = 'SPAN_EVENT';
