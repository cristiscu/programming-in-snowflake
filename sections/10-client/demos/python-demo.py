import snowflake.connector
import pandas as pd
import os

# customize with your own account locator and user name
with snowflake.connector.connect(
    account='XLB86271',
    user='cscutaru',
    password=os.environ['SNOWSQL_PWD'],
    database='EMPLOYEES',
    schema='PUBLIC') as conn:

    with conn.cursor() as cur:

        # typical SELECT statement with cursor
        sql = "select name, path from employee_hierarchy order by path"
        cur.execute(sql)
        for row in cur: print(row)

        # pandas dataframe from the same result
        print("Pandas DataFrame from SELECT =============================")
        df = cur.fetch_pandas_all()
        print(df)

    # pandas dataframe from CALL result
    print("Pandas DataFrame from CALL ===============================")
    sql = "call show_tree_simple('employee_manager')"
    df = pd.read_sql(sql, conn)
    print(df)
