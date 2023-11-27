-- select database and schema
use schema employees.public;

-- hierarchical data on IDs
select ename, empno, mgr
from emp
order by ename;

-- hierarchical data on names (with JOIN)
select e.ename as employee, m.ename as manager
from emp e left join emp m on e.mgr = m.empno
order by e.ename;

-- view (with JOIN)
-- (download as data/employee-manager.csv file)
create view employee_manager (employee, manager) as
  (select e.ename as employee, m.ename as manager
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename);

-- company --> departments --> employees hierarchy
create view employee_department (child, parent) as
  select '(company)', null
  union
  select dname as child, '(company)' as parent
  from dept
  union
  select e.ename, d.dname
  from emp e left join dept d on e.deptno = d.deptno;
