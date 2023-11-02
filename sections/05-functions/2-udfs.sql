-- select test database and schema
use schema employees.public;

-- SQL Scripting UDF
create or replace function fctSQL(num float, …)
  returns string
  language sql
as $$
BEGIN
  SELECT TO_VARCHAR(num)
END;
$$;

-- Python UDF
create or replace function fctPython(num float, …)
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'proc1'
as $$
import snowflake.snowpark
def proc1(session, num):
  return str(num)
$$;

-- JavaScript UDF
create or replace function fctJavaScript(num float, …)
  returns string
  language javascript
  strict
  execute as owner
as $$
  return num.toString();
$$;

-- Java UDF
create or replace function fctJava(num float, …)
  returns string
  language java
  runtime_version = 11
  handler = 'MyClass.fct1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
class MyClass {
  public String fct1(Session sess, …) {
    return Float.toString(num);
}}
$$;

-- Scala UDF
create or replace function fctScala(num float, …)
  returns string
  language scala
  runtime_version = 2.12
  handler = 'MyClass.fct1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
object MyClass {
  def fct1(sess: Session, ...): String {
    return num.toString
}}
$$;

-- call previous UDFs
select fctSQL(22.5);
select fctPython(22.5);
select fctJavaScript(22.5);
select fctJava(22.5);
select fctScala(22.5);
