-- select test database and schema
use schema employees.public;

-- SQL Scripting UDTF
create function fcttSQL(num float, …)
  returns table(s varchar)
  language sql
as $$
BEGIN
  SELECT 'abc' UNION SELECT 'def'
END;
$$;

-- Python UDTF
create function fcttPython(num float, …)
  returns table(s varchar)
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'proc1'
as $$
import snowflake.snowpark
def proc1(session, var1):
  return v1 + 1
$$;

-- JavaScript UDTF
create function fctJavaScript(num float, …)
  returns table(s varchar)
  language javascript
  strict
  execute as owner
as $$
{  processRow: function f(row, w, ctx)
   { writer.writeRow( {...} ); ... }
}
$$;

-- Java UDTF
create function fcttJava(num float, …)
  returns table(s varchar)
  language java
  runtime_version = 11
  handler = 'MyClass.fct1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
class MyClass {
  public String fct1(Session session) {
    return v1 + 1;
}}
$$;

-- Scala UDTF
create function fcttScala(num float, …)
  returns table(s varchar)
  language scala
  runtime_version = 2.12
  handler = 'MyClass.fct1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
object MyClass {
  def fct1(session: Session, ...): String {
    return v1 + 1
}}
$$;

-- call previous UDTFs
select * from table(fcttSQL(22.5));
select * from table(select fcttPython(22.5));
select * from table(select fcttJavaScript(22.5));
select * from table(select fcttJava(22.5));
select * from table(select fcttScala(22.5));
