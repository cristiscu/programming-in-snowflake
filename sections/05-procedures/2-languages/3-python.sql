-- select context
create database if not exists tests;
use schema tests.public;

-- Python UDF
-- https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-designing
create or replace function fctPython(num float)
  returns string
  language python
  runtime_version = '3.8'
  handler = 'proc1'
as $$
def proc1(num: float):
  return '+' + str(num)
$$;

select fctPython(22.5);

-- Python UDTF
-- https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-tabular-functions
create or replace function fcttPython(s string)
  returns table(out varchar)
  language python
  runtime_version = '3.8'
  handler = 'MyClass'
as $$
class MyClass:
  def process(self, s: str):
    yield (s,)
    yield (s,)
$$;

select * from table(fcttPython('abc'));


-- no stored procs w/o Snowpark!
-- HANDLER required everywhere (w/ fct name / MyClass w/o process for UDTFs)
