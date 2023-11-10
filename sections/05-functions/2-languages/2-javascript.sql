-- select test database and schema
create database if not exists functions;
use schema functions.public;

-- JavaScript stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-javascript
create or replace procedure procJavaScript(num float)
  returns string not null
  language javascript
  strict
as $$
  return '+' + NUM.toString();
$$;

call procJavaScript(22.5);

-- JavaScript UDF
-- https://docs.snowflake.com/en/developer-guide/udf/javascript/udf-javascript-scalar-functions
create or replace function fctJavaScript(num float)
  returns string not null
  language javascript
  strict
as
  'return \'+\' + NUM.toString()';

select fctJavaScript(22.5);

-- JavaScript UDTF
-- https://docs.snowflake.com/en/developer-guide/udf/javascript/udf-javascript-tabular-functions
create or replace function fcttJavaScript(s string)
  returns table(out varchar)
  language javascript
  strict
as $$
{
  processRow: function f(row, rowWriter, context)
  {
    rowWriter.writeRow({OUT: row.S});
    rowWriter.writeRow({OUT: row.S});
  }
}
$$;

select * from table(fcttJavaScript('abc'));

-- stored procs can return a value (but cannot pass in var in CALL)
-- arg names must be always used upper case in the def block (see num --> NUM)
-- AS $$ .. $$;
-- specific heavy implementation for UDTFs (w. processRow)
-- optional STRICT keyword

