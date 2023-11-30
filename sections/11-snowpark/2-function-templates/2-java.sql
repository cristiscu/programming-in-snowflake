-- select test database and schema
create database if not exists snowpark;
use schema snowpark.public;

-- Java stored procedure
-- https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-java
create or replace procedure procJavaS(num float)
  returns string
  language java
  runtime_version = 11
  packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.proc1'
as $$
  import com.snowflake.snowpark_java.*;
  class MyClass {
    public String proc1(Session session, float num) {
      String query = "select '+' || to_char(" + num + ")";
      return session.sql(query).collect()[0].getString(0);
  }}
$$;

call procJavaS(22.5);

-- Java UDF
-- https://docs.snowflake.com/en/developer-guide/udf/java/udf-java-designing
create or replace function fctJavaS(num float)
  returns string
  language java
  runtime_version = 11
  -- packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass.fct1'
as $$
  // import com.snowflake.snowpark_java.*;
  class MyClass {
    public String fct1(float num) {
      return "+" + Float.toString(num);
  }}
$$;

select fctJavaS(22.5);

-- Java UDTF
-- https://docs.snowflake.com/en/developer-guide/udf/java/udf-java-tabular-functions
create or replace function fcttJavaS(s string)
  returns table(out varchar)
  language java
  runtime_version = 11
  -- packages = ('com.snowflake:snowpark:latest')
  handler = 'MyClass'
as $$
  // import com.snowflake.snowpark_java.*;
  import java.util.stream.Stream;
  class OutputRow {
    public String out;
    public OutputRow(String outVal) { this.out = outVal; }
  }
  class MyClass {
    public static Class getOutputClass() { return OutputRow.class; } 
    public Stream<OutputRow> process(String inVal)
    { return Stream.of(new OutputRow(inVal), new OutputRow(inVal)); }
  }
$$;

select * from table(fcttJavaS('abc'));


-- HANDLER required everywhere (w/ MyClass w/o fct for UDTF)
-- stored procs always w/ Snowpark
-- packages and import will add Snowpark
-- no session param on UDF/UDTF with Snowpark
