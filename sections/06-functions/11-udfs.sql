-- select test database and schema
use schema employees.public;

-- SQL Scripting UDF
-- https://docs.snowflake.com/en/developer-guide/udf/sql/udf-sql-scalar-functions
create or replace function fctSQL(num float)
  returns string
as 'select ''+'' || to_varchar(num)';

select fctSQL(22.5);

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

-- JavaScript UDF
-- https://docs.snowflake.com/en/developer-guide/udf/javascript/udf-javascript-scalar-functions
create or replace function fctJavaScript(num float)
  returns string not null
  language javascript
  strict
as $$
  return '+' + NUM.toString();
$$;

select fctJavaScript(22.5);

-- Java UDF
-- https://docs.snowflake.com/en/developer-guide/udf/java/udf-java-designing
create or replace function fctJava(num float)
  returns string
  language java
  runtime_version = 11
  handler = 'MyClass.fct1'
as $$
class MyClass {
  public String fct1(float num) {
    return "+" + Float.toString(num);
}}
$$;

select fctJava(22.5);

-- Scala UDF
-- https://docs.snowflake.com/en/developer-guide/udf/scala/udf-scala-scalar
create or replace function fctScala(num float)
  returns string
  language scala
  runtime_version = 2.12
  handler = 'MyClass.fct1'
as $$
object MyClass {
  def fct1(num: Float): String = {
    return "+" + num.toString
}}
$$;

select fctScala(22.5);
