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


-- =========================================================
-- new Scripting stored proc
create or replace procedure get_tree5(tname varchar)
  returns table(name varchar, path varchar)
  language sql
as
declare
    c1 CURSOR FOR
        with recursive cte (level, name, child, parent, path) as (
          select 1, $1, $1, $2, ' -> ' || $1
          from identifier(?) where $2 is null
          union all
          select m.level + 1, repeat('  ', level) || e.$1, e.$1, e.$2, path || ' -> ' || e.$1
          from identifier(?) e join cte m on e.$2 = m.child)
        select name, path from cte order by path;
begin
    OPEN c1 USING (:tname, :tname);
    RETURN TABLE(RESULTSET_FROM_CURSOR(c1));
end;

call get_tree5('employees');
select * from table(result_scan(last_query_id()));


-- ===============================================================

-- view with employee-manager names
create or replace view employees as 
  select e.ename as employee, m.ename as manager 
  from emp e left join emp m on e.empno = m.empno
  order by e.ename;

  -- SQL-based UDF to return query as text
create or replace function get_tree_query()
  returns varchar
  -- language sql
as $$
'with cte as (
  select e.employee as name,
    coalesce(coalesce(coalesce(
      '' -> '' || m3.employee, '''')
      || '' -> '' || m2.employee, '''')
      || '' -> '' || m1.employee, '''')
      || '' -> '' || e.employee as path
  from employees e
    left join employees m1 on e.manager = m1.employee
    left join employees m2 on m1.manager = m2.employee
    left join employees m3 on m2.manager = m3.employee)
    
select repeat(''  '', array_size(split(path, ''->''))-1)
  || name as name, path
  from cte
  order by path'
$$;

select get_tree_query();

create or replace procedure get_tree()
  returns table(name varchar, path varchar)
  language sql
as
declare
    c1 CURSOR FOR
        (with cte as (
            select e.employee as name,
              coalesce(coalesce(coalesce(
                ' -> ' || m3.employee, '')
                || ' -> ' || m2.employee, '')
                || ' -> ' || m1.employee, '')
                || ' -> ' || e.employee as path
            from employees e
              left join employees m1 on e.manager = m1.employee
              left join employees m2 on m1.manager = m2.employee
              left join employees m3 on m2.manager = m3.employee)
        select repeat('  ', array_size(split(path, '->'))-1)
          || name as name, path
          from cte
          order by path);
begin
    OPEN c1;
    RETURN TABLE(RESULTSET_FROM_CURSOR(c1));
end;

CALL get_tree();
