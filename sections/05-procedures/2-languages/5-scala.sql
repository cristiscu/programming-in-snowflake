-- select context
create database if not exists tests;
use schema tests.public;

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

-- no stored procs w/o Snowpark! no UDTFs in Scala! only UDF
-- HANDLER required (w/ MyClass.fct1)
