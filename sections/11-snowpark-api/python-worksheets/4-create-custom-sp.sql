-- see https://cristian-70480.medium.com/how-to-generate-snowflake-stored-procs-via-python-worksheets-01d49b5b3cb2

create or replace procedure gen_fake_rows(r int)
    returns Table()
    language python
    runtime_version = 3.8
    packages =('faker==18.9.0', 'snowflake-snowpark-python==*')
    handler = 'main'
as $$
import snowflake.snowpark as snowpark
from faker import Faker # add to Packages (already included in Anaconda)

# generate fake rows but with realistic test synthetic data
def main(session: snowpark.Session, r: int):
  f = Faker()
  output = [[f.name(), f.address(), f.city(), f.state(), f.email()]
    for _ in range(r)]
  df = session.create_dataframe(output,
    schema=["name", "address", "city", "state", "email"])
  df.show()
  return df
$$;

call gen_fake_rows(2000);