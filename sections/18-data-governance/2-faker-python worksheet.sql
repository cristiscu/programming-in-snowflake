-- (1) copy&paste into a new "customers fake" Python Worksheet in Snowsight
-- (2) select as context EMPLOYEES.PUBLIC database+schema, and COMPUTE_WH warehouse
-- (3) add Faker in Packages popup
-- (4) Run --> new CUSTOMERS_FAKE table created, w/ 10K rows

import snowflake.snowpark as snowpark
from snowflake.snowpark.types import StructType, StructField, StringType
from faker import Faker # add to Packages (already included in Anaconda)

# generate fake rows but with realistic test synthetic data
def main(session: snowpark.Session):
  f = Faker()
  output = [[f.name(), f.address(), f.city(), f.state(), f.email()]
    for _ in range(10000)]

  schema = StructType([ 
    StructField("NAME", StringType(), False),  
    StructField("ADDRESS", StringType(), False), 
    StructField("CITY", StringType(), False),  
    StructField("STATE", StringType(), False),  
    StructField("EMAIL", StringType(), False)
  ])
  df = session.create_dataframe(output, schema)
  df.write.mode("overwrite").save_as_table("CUSTOMERS_FAKE")
  df.show()
  return df
