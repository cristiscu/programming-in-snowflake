from snowflake.snowpark import Session
from snowflake.snowpark.functions import sproc
import utils

session = utils.getSession()

# registered SP
@sproc(name="add_three", replace=True,
  is_permanent=True, stage_location="@mystage",
  packages=["snowflake-snowpark-python"])
def add_three(session: Session, x: int) -> int:
  return session.sql(f"select {x} + 3").collect()[0][0]

ret = session.sql("call add_three(1)").collect()[0][0]
print(f"add_three: {ret}")

"""
Generated stored proc:
======================

CREATE OR REPLACE PROCEDURE add_three(arg1 BIGINT)
  RETURNS BIGINT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('snowflake-snowpark-python','cloudpickle==2.0.0')
  HANDLER='compute'
  EXECUTE AS OWNER
AS $$
import pickle
func = pickle.loads(bytes.fromhex('8005953d...48652302e'))
# ...
def compute(session,arg1):
  return func(session,arg1)
$$

call add_three(1)
"""