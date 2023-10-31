-- select test database and schema
use schema employees.public;

-- SQL Scripting stored procedure
create or replace procedure procSQL(num float, …)
  returns string
  language sql
as $$
BEGIN
  …
END;
$$;

-- Python stored procedure
create or replace procedure procPython(num float, …)
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'proc1'
as $$
import snowflake.snowpark
def proc1(session, num):
  …
$$;

-- JavaScript stored procedure
create or replace procedure procJavaScript(num float)
  returns string
  language javascript
  strict
  execute as owner
as $$
  …
$$;

-- Java stored procedure
create or replace procedure procJava(num float, …)
  returns string
  language java
  runtime_version = 11
  handler = 'MyClass.proc1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
class MyClass {
  public String proc1(Session sess, …) {
    …
}}
$$;

-- Scala stored procedure
create or replace procedure procScala(num float, …)
  returns string
  language scala
  runtime_version = 2.12
  handler = 'MyClass.proc1'
  packages = ('com.snowflake:snowpark')
as $$
import com.snowflake.snowpark.Session;
object MyClass {
  def proc1(sess: Session, ...): String {
    …
}}
$$;

-- call previous stored procedures
call procSQL(22.5);
call procPython(22.5);
call procJavaScript(22.5);
call procJava(22.5);
call procScala(22.5);
