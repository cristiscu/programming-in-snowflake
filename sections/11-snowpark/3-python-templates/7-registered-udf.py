from snowflake.snowpark import Session
from snowflake.snowpark.functions import udf, call_udf, col
import utils

session = utils.getSession()

# registered UDF
@udf(name="add_seven", replace=True,
  is_permanent=True, stage_location="@mystage")
def add_seven(x: int) -> int:
  return x+7

df = session.create_dataframe([[1]], schema=["a"])
ret = df.select(call_udf("add_seven", col("a"))).collect()[0][0]
print(f"add_seven: {ret}")

"""
Generated UDF:
==============

CREATE OR REPLACE FUNCTION add_seven(arg1 BIGINT)
  RETURNS BIGINT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('snowflake-snowpark-python','cloudpickle==2.0.0')
  HANDLER='compute'
AS $$
import pickle
func = pickle.loads(bytes.fromhex('800595...652302e'))
# ...
from threading import RLock
lock = RLock()
class InvokedFlag:
    def __init__(self):
        self.invoked = False

def lock_function_once(f, flag):
    def wrapper(*args, **kwargs):
        if not flag.invoked:
            with lock:
                if not flag.invoked:
                    result = f(*args, **kwargs)
                    flag.invoked = True
                    return result
                return f(*args, **kwargs)
        return f(*args, **kwargs)
    return wrapper

invoked = InvokedFlag()
def compute(arg1):
  return lock_function_once(func, invoked)(arg1)
$$;

select add_seven(1);
"""