from snowflake.snowpark.functions import sproc
from snowflake.snowpark.types import IntegerType
import utils

session = utils.getSession();

# named SP (with lambda)
add_two = sproc(
  lambda session, x: session.sql(f"select {x} + 2").collect()[0][0],
  input_types=[IntegerType()], return_type=IntegerType(),
  name="add_two_proc", replace=True,
  packages=["snowflake-snowpark-python"])

ret = session.call("add_two_proc", 1)
print(f"add_two: {ret}")

"""
Generated temp stored proc:
===========================

CREATE OR REPLACE TEMPORARY PROCEDURE add_two_proc(arg1 INT)
  RETURNS INT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('snowflake-snowpark-python','cloudpickle==2.0.0')
  HANDLER='compute'
  EXECUTE AS OWNER
AS $$
import pickle
func = pickle.loads(bytes.fromhex('800595...948652302e'))
# ...
def compute(session,arg1):
  return func(session,arg1)
$$

CALL add_two_proc(1::INT)
"""