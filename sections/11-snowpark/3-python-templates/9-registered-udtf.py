from snowflake.snowpark.functions import udtf, lit
from snowflake.snowpark.types import IntegerType, StructType, StructField
import utils

session = utils.getSession()

# UDTF implementation class
class GetTwo:
  def process(self, n):
    yield(1, )
    yield(n, )

# registered UDTF
get_two = udtf(GetTwo, 
  output_schema=StructType([StructField("number", IntegerType())]),
  input_types=[IntegerType()])

ret = session.table_function(get_two(lit(3))).collect()
#ret = session.table_function(get_two.name, lit(3)).collect()
print(f"get_two: {ret}")

"""
Generated temp UDTF:
====================

CREATE TEMPORARY FUNCTION ...(arg1 INT)
  RETURNS TABLE (NUMBER INT)
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('cloudpickle==2.0.0')
  HANDLER='compute'
AS $$
import pickle
func = pickle.loads(bytes.fromhex('80059...02e'))

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

init_invoked = InvokedFlag()
process_invoked = InvokedFlag()
end_partition_invoked = InvokedFlag()

class compute(func):
    def __init__(self):
        lock_function_once(super().__init__, init_invoked)()
    def process(self, arg1):
        return lock_function_once(super().process, process_invoked)(arg1)
$$;

SELECT * FROM TABLE(...(3::INT));
"""