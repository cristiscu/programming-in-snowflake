-- select test database and schema
use schema employees.public;

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
