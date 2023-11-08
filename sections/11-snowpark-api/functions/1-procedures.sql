-- select test database and schema
use schema employees.public;

-- Python stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-python
create or replace procedure procPython(num float)
  returns string
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python')
  handler = 'proc1'
as $$
def proc1(session, num: float):
  return '+' + str(num)
$$;

call procPython(22.5);

-- Java stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-java
create or replace procedure procJava(num float)
  returns string
  language java
  runtime_version = 11
  packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.proc1'
as $$
import com.snowflake.snowpark_java.*;
class MyClass {
  public String proc1(Session session, float num) {
    return "+" + Float.toString(num);
}}
$$;

call procJava(22.5);

-- Scala stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-scala
create or replace procedure procScala(num float)
  returns string
  language scala
  runtime_version = 2.12
  packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.proc1'
as $$
import com.snowflake.snowpark.Session;
object MyClass {
  def proc1(sess: Session, num: Float): String = {
    return "+" + num.toString
}}
$$;

call procScala(22.5);
