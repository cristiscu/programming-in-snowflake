-- select test database and schema
create database if not exists snowpark;
use schema snowpark.public;

-- Scala stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-scala
create or replace procedure procScalaS(num float)
  returns string
  language scala
  runtime_version = 2.12
  packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.proc1'
as $$
  import com.snowflake.snowpark.Session;
  object MyClass {
    def proc1(session: Session, num: Float): String = {
      var query = "select '+' || to_char(" + num + ")"
      return session.sql(query).collect()(0).getString(0)
  }}
$$;

call procScalaS(22.5);

-- Scala UDF
-- https://docs.snowflake.com/en/developer-guide/udf/scala/udf-scala-scalar
create or replace function fctScalaS(num float)
  returns string
  language scala
  runtime_version = 2.12
  packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.fct1'
as $$
  // import com.snowflake.snowpark.Session;
  object MyClass {
    def fct1(num: Float): String = {
      return "+" + num.toString
  }}
$$;

select fctScalaS(22.5);


-- no UDTFs in Scala! stored procs always w/ Snowpark
-- HANDLER required everywhere (w/ MyClass.fct1)
-- packages and import will add Snowpark
-- no session param on UDF with Snowpark
