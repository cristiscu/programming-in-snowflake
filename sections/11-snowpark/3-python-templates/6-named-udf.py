from snowflake.snowpark.functions import udf
from snowflake.snowpark.types import IntegerType
import utils

session = utils.getSession();

# named UDF (with lambda)
add_six = udf(lambda x: x+6,
  input_types=[IntegerType()], return_type=IntegerType(),
  name="add_six_proc", replace=True)

ret = session.sql("select add_six_proc(1)").collect()[0][0]
print(f"add_six: {ret}")

"""
Generated temp UDF:
===================

CREATE OR REPLACE TEMPORARY FUNCTION add_six_proc(arg1 INT)
  RETURNS INT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('snowflake-snowpark-python','cloudpickle==2.0.0')
  HANDLER='compute'
AS $$
import pickle
func = pickle.loads(bytes.fromhex('800595...8652302e'))
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
$$

select add_six_proc(1)
"""