-- after Run. Then Query ID - Query Details

with PYTHON_WORKSHEET as procedure ()
  returns Table()
  language python
  runtime_version=3.8
  packages=('faker==18.9.0','snowflake-snowpark-python==*')
  handler='main'
as 'import snowflake.snowpark as snowpark
from faker import Faker # add to Packages (already included in Anaconda)

# generates fake rows but with realistic test synthetic data
def main(session: snowpark.Session):
  f = Faker()
  output = [[f.name(), f.address(), f.city(), f.state(), f.email()]
     for _ in range(1000)]
  df = session.create_dataframe(output,
    schema=["name", "address", "city", "state", "email"])
  df.show()
  return df'

call PYTHON_WORKSHEET();