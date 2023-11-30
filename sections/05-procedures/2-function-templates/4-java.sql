-- select context
create database if not exists tests;
use schema tests.public;

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

-- Java UDTF
-- https://docs.snowflake.com/en/developer-guide/udf/java/udf-java-tabular-functions
create or replace function fcttJava(s string)
  returns table(out varchar)
  language java
  runtime_version = 11
  handler = 'MyClass'
as $$
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

select * from table(fcttJava('abc'));


-- no stored procs w/o Snowpark!
-- HANDLER required everywhere (w/ fct name / MyClass w/o process for UDTFs)
