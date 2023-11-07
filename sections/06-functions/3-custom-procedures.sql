-- select database and schema
use schema employees.public;

-- stored proc
create or replace procedure show_hierarchy()
  returns table(name string, path string)
  language sql
as
declare
  sql string;
  res resultset;
begin
  sql := 'select name, path from employee_hierarchy order by path';
  res := (execute immediate :sql);
  return table(res);
end;

call show_hierarchy();

-- =========================================================

-- stored proc with filter (same name!)
create or replace procedure show_hierarchy(employee string)
  returns table()
  language sql
as
declare
  res resultset default (
    select name, path
    from employee_hierarchy
    where path like '% -> ' || :employee || '%'
    order by path);
begin
  return table(res);
end;

call show_hierarchy('BLAKE');

-- =========================================================

-- not working ("Unsupported subquery type cannot be evaluated")
select ee.ename as employee,
  (select m.ename
   from emp e left join emp m on e.mgr = m.empno
   where e.ename = ee.ename) manager
from emp ee;

-- this is working (CTE + JOIN)
with mans as (
  select e.ename employee, m.ename manager
  from emp e left join emp m on e.mgr = m.empno)
select ename as employee, mans.manager
from emp join mans on emp.ename = mans.employee;

-- UDF (with filter)
create or replace function get_manager_name(employee string)
  returns string
as 'select m.ename
  from emp e left join emp m on e.mgr = m.empno
  where e.ename = employee';

select get_manager_name('BLAKE') manager;

-- not working  ("Unsupported subquery type cannot be evaluated")
select ename as employee, get_manager_name(ename) manager
from emp;

-- =========================================================

-- UDTF
create or replace function get_hierarchy()
  returns table(name string, path string)
as 'select name, path from employee_hierarchy order by path';

select * from table(get_hierarchy());

-- UDTF
create or replace function get_managers()
  returns table(employee string, manager string)
as 'select e.ename employee, m.ename manager
  from emp e left join emp m on e.mgr = m.empno';

select ename as employee, man.manager manager
from emp, table(get_managers()) man
where emp.ename = man.employee;

-- UDTF with filter (but returns 1)
create or replace function get_manager(employee string)
  returns table(manager string)
  language sql
as $$
  select m.ename manager
  from emp e left join emp m on e.mgr = m.empno
  where e.ename = employee
$$;

select ename as employee, man.manager manager
from emp, table(get_manager(ename)) man;
