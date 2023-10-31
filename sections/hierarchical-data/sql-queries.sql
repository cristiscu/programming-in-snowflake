-- ====================================================================
-- Several ways to display hierarchical data with Snowflake SQL queries
-- ====================================================================

-- select database and schema
use schema employees.public;

-- show all related data
select ename, empno, mgr
from emp
order by ename;

select e.ename as employee, m.ename as manager
from emp e left join emp m on e.mgr = m.empno
order by e.ename;

-- with JOINs
select e.ename as name, e.job as title, m.ename as manager
from emp e left join emp m on e.mgr = m.empno
order by e.ename;

-- (1) with 4-level hierarchy
-- https://docs.snowflake.com/en/user-guide/queries-hierarchical
with cte as (
    select e.ename as name,
      coalesce(coalesce(coalesce(
        ' -> ' || m3.ename, '')
        || ' -> ' || m2.ename, '')
        || ' -> ' || m1.ename, '')
        || ' -> ' || e.ename as path,
      e.job as title
    from emp e
      left join emp m1 on e.mgr = m1.empno
      left join emp m2 on m1.mgr = m2.empno
      left join emp m3 on m2.mgr = m3.empno
)
select repeat('  ', array_size(split(path, '->'))-1)
  || name as name, path, title
from cte
order by path;

-- (2) with CONNECT BY (only for self-joins)
-- https://docs.snowflake.com/en/sql-reference/constructs/connect-by
select repeat('  ', level) || ename as name,
   sys_connect_by_path(ename, ' -> ') as path,
   job as title
from emp
start with job = 'PRESIDENT'
connect by prior empno = mgr
order by path;

-- (3) with recursive CTE
-- https://docs.snowflake.com/en/sql-reference/constructs/with#recursive-clause
with recursive cte (level, name, title, empno, mgr, path) as (
  select 1, ename, job, empno, mgr, ' -> ' || ename
  from emp where mgr is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.ename, e.job,
    e.empno, e.mgr, path || ' -> ' || e.ename
  from emp e join cte m on e.mgr = m.empno
)
select name, path, title
from cte
order by path;

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
