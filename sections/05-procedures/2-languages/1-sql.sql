-- select context
create database if not exists tests;
use schema tests.public;

-- SQL Scripting stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-snowflake-scripting
create or replace procedure procSQL(num float)
  returns string not null
  language sql
as $$
  return '+' || to_varchar(num);
$$;

call procSQL(22.5);
-- select * from table(result_scan(last_query_id()));

-- SQL Scripting UDF
-- https://docs.snowflake.com/en/developer-guide/udf/sql/udf-sql-scalar-functions
create or replace function fctSQL(num float)
  returns string
as
  'select ''+'' || to_varchar(num)';

select fctSQL(22.5);

-- SQL Scripting UDTF
-- https://docs.snowflake.com/en/developer-guide/udf/sql/udf-sql-tabular-functions
create or replace function fcttSQL(s string)
  returns table(out varchar)
as
begin
  select s
  union all
  select s
end;

select * from table(fcttSQL('abc'));

-- stored procs can return a value (but cannot pass in var in CALL)
-- language sql is optional
-- returns TABLE(...) for UDTF
-- the block can be:
--    1. AS 'SELECT ...';
--    2. AS BEGIN .. END;
--    3. AS $$ SELECT ... $$;

