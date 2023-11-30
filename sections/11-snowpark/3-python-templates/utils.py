import os
from snowflake.snowpark import Session

# connect to Snowflake with Snowpark
def getSession():
  pars = {
      "account": "XLB86271",
      "user": "cscutaru",
      "password": os.environ["SNOWSQL_PWD"],
      "database": "SNOWPARK_PYTHON",
      "schema": "PUBLIC" }
  return Session.builder.configs(pars).create()
