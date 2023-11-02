-- select database and schema
use schema employees.public;

-- download as employee-manager.csv file
create view employee_manager (employee, manager, employee_id, manager_id) as (
  select e.ename as employee, m.ename as manager,
    e.empno as employee_id, m.empno as manager_id
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename);

-- (4) with recursive view
-- https://docs.snowflake.com/en/sql-reference/sql/create-view#examples
create recursive view employee_hierarchy (level, name, title, empno, mgr, path) as (
  select 1, ename, job, empno, mgr, ' -> ' || ename
  from emp where mgr is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.ename, e.job,
    e.empno, e.mgr, path || ' -> ' || e.ename
  from emp e join employee_hierarchy m on e.mgr = m.empno
);

select name, path, title
from employee_hierarchy
order by path;
