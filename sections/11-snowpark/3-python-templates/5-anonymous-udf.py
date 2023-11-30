from snowflake.snowpark.functions import udf, col
from snowflake.snowpark.types import IntegerType
import utils

session = utils.getSession();

# anonymous UDF (with lambda)
add_five = udf(lambda x: x+5,
  input_types=[IntegerType()], return_type=IntegerType())

df = session.create_dataframe([[1]]).to_df("a")
ret = df.select(add_five(col("a"))).collect()[0][0]
print(f"add_five: {ret}")

"""
Generated temp UDF:
===================

CREATE TEMPORARY FUNCTION ...(arg1 INT)
  RETURNS INT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('cloudpickle==2.0.0')
  HANDLER='compute'
AS $$
import pickle
func = pickle.loads(bytes.fromhex('800595...2302e'))
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

SELECT ...("A")
FROM (SELECT "_1" AS "A"
  FROM (SELECT $1 AS "_1" FROM VALUES (1::INT)))
"""
