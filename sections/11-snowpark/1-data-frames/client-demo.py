import snowflake.connector
import os, pandas as pd

# connect to Snowflake with Python Client
conn = snowflake.connector.connect(
    account="XLB86271",
    user="cscutaru",
    password=os.environ["SNOWSQL_PWD"],
    database="EMPLOYEES",
    schema="PUBLIC")

sql = """
select dname, sum(sal)
  from emp join dept on emp.deptno = dept.deptno
  where dname <> 'RESEARCH'
  group by dname
  order by dname;
"""
df = pd.read_sql(sql, conn)
print(df)