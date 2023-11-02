# copy and paste into a new Python Worksheet

import snowflake.snowpark as snowpark
from faker import Faker # add to Packages (already included in Anaconda)

# generate fake rows but with realistic test synthetic data
def main(session: snowpark.Session):
  f = Faker()
  output = [[f.name(), f.address(), f.city(), f.state(), f.email()]
    for _ in range(1000)]
  df = session.create_dataframe(output,
    schema=["name", "address", "city", "state", "email"])
  df.show()
  return df