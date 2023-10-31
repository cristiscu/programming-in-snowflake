# https://medium.com/snowflake/how-to-create-a-complex-query-with-snowpark-dataframe-in-python-2d31b9e0961b
import configparser, os
from snowflake.snowpark import Session

# create connection
parser = configparser.ConfigParser()
parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
section = "connections.demo_conn"
pars = {
    "account": parser.get(section, "accountname"),
    "user": parser.get(section, "username"),
    "password": os.environ['SNOWSQL_PWD'],
    "database": 'EMPLOYEES',
    "schema": 'PUBLIC'
}
session = Session.builder.configs(pars).create()

"""
select dname, sum(sal)
  from emp join dept on emp.deptno = dept.deptno
  where dname <> 'RESEARCH'
  group by dname
  order by dname;
"""
emps = (session.table("EMP")
  .select("EMPNO", "DEPTNO", "SAL"))
depts = (session.table("DEPT")
  .select("DEPTNO", "DNAME"))
q = emps.join(depts,
  emps.deptno == depts.deptno)

q = q.filter(q.dname != 'RESEARCH')
(q.select("DNAME", "SAL")
  .group_by("DNAME")
  .agg({"SAL": "sum"})
  .sort("DNAME")
  .show())
