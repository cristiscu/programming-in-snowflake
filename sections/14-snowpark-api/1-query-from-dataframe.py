# see https://medium.com/snowflake/how-to-create-a-complex-query-with-snowpark-dataframe-in-python-2d31b9e0961b

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
emps = (session.table("EMP").select("EMPNO", "DEPTNO", "SAL"))
depts = (session.table("DEPT").select("DEPTNO", "DNAME"))
q = emps.join(depts, emps.deptno == depts.deptno)

q = q.filter(q.dname != 'RESEARCH')
(q.select("DNAME", "SAL")
  .group_by("DNAME")
  .agg({"SAL": "sum"})
  .sort("DNAME")
  .show())

"""
# generated SQL query (on SHOW):

SELECT "EMPNO", "DNAME"
FROM (
  SELECT *
  FROM (
    (SELECT "EMPNO" AS "EMPNO", "DEPTNO_E" AS "DEPTNO_E"
    FROM (SELECT "EMPNO", "DEPTNO" AS "DEPTNO_E" FROM EMP)) AS SNOWPARK_LEFT
    INNER JOIN 
      (SELECT "DEPTNO_D" AS "DEPTNO_D", "DNAME" AS "DNAME"
      FROM (SELECT "DEPTNO" AS "DEPTNO_D", "DNAME" FROM DEPT)) AS SNOWPARK_RIGHT
    ON ("DEPTNO_E" = "DEPTNO_D")))
    WHERE ("DNAME" != 'RESEARCH')
    LIMIT 10
"""