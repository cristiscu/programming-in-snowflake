-- select database and schema
use schema employees.public;

-- download as employee-manager.csv file
create or replace view employee_manager (
  employee, manager, employee_id, manager_id) as (
  select e.ename as employee, m.ename as manager,
    e.empno as employee_id, m.empno as manager_id
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename);

-- generic
create or replace view employee_manager2 (
  employee, manager) as (
  select e.ename as employee, m.ename as manager
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename);

-- (4) with recursive view
-- https://docs.snowflake.com/en/sql-reference/sql/create-view#examples
create or replace recursive view employee_hierarchy (
  level, name, title, empno, mgr, path) as (
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

-- generic recursive view
create or replace recursive view employee_hierarchy2 (
  level, name, employee, manager, path) as (
  select 1, employee, employee, manager, ' -> ' || employee
  from employee_manager2 where manager is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.employee,
    e.employee, e.manager, path || ' -> ' || e.employee
  from employee_manager2 e join employee_hierarchy2 m on e.manager = m.employee
);

select name, path
from employee_hierarchy2
order by path;

-- generic recursive CTE
with recursive cte (level, name, employee, manager, path) as (
  select 1, employee, employee, manager, ' -> ' || employee
  from employee_manager2 where manager is null
  union all
  select m.level + 1, repeat('  ', level) || e.employee,
    e.employee, e.manager, path || ' -> ' || e.employee
  from employee_manager2 e join cte m on e.manager = m.employee)
select name, path
from cte
order by path;

-- very generic recursive CTE
with recursive cte (
  level, name, child, parent, path) as (
  select 1, $1, $1, $2, ' -> ' || $1
  from employee_manager2 where $2 is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.$1,
    e.$1, e.$2, path || ' -> ' || e.$1
  from employee_manager2 e join cte m on e.$2 = m.child)
select name, path
from cte
order by path;
