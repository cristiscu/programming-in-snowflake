import pandas as pd
from snowflake.snowpark import Session
from snowflake.snowpark.functions import sproc
import utils

session = utils.getSession();

session.add_packages("snowflake-snowpark-python", "pandas")
# session.add_import(...)
# session.add_requirements(...)

# registered SP with external packages
@sproc(name="showVersion", replace=True,
  is_permanent=True, stage_location="@mystage")
def showVersion(session: Session) -> str:
   return pd.__version__

ret = session.call("showVersion")
print(f"showVersion: {ret}")

"""
Generated stored proc:
======================

CREATE OR REPLACE PROCEDURE showVersion()
  RETURNS STRING
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('snowflake-snowpark-python','pandas','cloudpickle==2.0.0')
  HANDLER='compute'
  EXECUTE AS OWNER
AS $$
import pickle
func = pickle.loads(bytes.fromhex('800595...2302e'))
# ...
def compute(session):
  return func(session)
$$

CALL showVersion()
"""