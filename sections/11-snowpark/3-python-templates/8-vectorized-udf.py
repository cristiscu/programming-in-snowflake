from snowflake.snowpark.functions import pandas_udf, col, call_udf
from snowflake.snowpark.types import IntegerType, PandasSeriesType
import pandas as pd
import utils

session = utils.getSession()

# vectorized (named) UDF
@pandas_udf(name="add_eight",
  input_types=[PandasSeriesType(IntegerType()), PandasSeriesType(IntegerType())],
  return_type=PandasSeriesType(IntegerType()))
def add_eight(col1: pd.Series, col2: pd.Series) -> pd.Series:
    return col1 + col2 + 8

df = session.create_dataframe([[1, 2]], schema=["a", "b"])
ret = df.select(call_udf("add_eight", col("a"), col("b"))).collect()[0][0]
print(f"add_eight: {ret}")

"""
Generate temp UDF
=================

CREATE TEMPORARY FUNCTION add_eight(arg1 INT,arg2 INT)
  RETURNS INT
  LANGUAGE PYTHON 
  VOLATILE
  RUNTIME_VERSION=3.9
  PACKAGES=('cloudpickle==2.0.0','pandas')
  HANDLER='compute'
AS $$
import pickle
func = pickle.loads(bytes.fromhex('80059509...652302e'))
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
def compute(df):
    return lock_function_once(func, invoked)(*[df[idx] for idx in range(df.shape[1])])

import pandas
compute._sf_vectorized_input = pandas.DataFrame
$$;

SELECT add_eight("A", "B")
FROM (SELECT $1 AS "A", $2 AS "B" FROM VALUES (1::INT, 2::INT));
"""