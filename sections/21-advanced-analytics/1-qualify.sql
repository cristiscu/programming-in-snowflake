use schema employees.public;

-- top earners (with max salaries) per dept: KING, FORD, BLAKE
select ename, dname, sal
from emp join dept on emp.deptno = dept.deptno
order by dname, sal desc, ename;

-- with WHERE (--> error!)
select ename, dname, sal,
  row_number() over (partition by emp.deptno order by sal desc, ename) as rn
from emp join dept on emp.deptno = dept.deptno
where rn = 1
order by dname, sal desc, ename;

-- without QUALIFY
with q as (
  select ename, dname, sal,
    row_number() over (partition by emp.deptno order by sal desc, ename) as rn
  from emp join dept on emp.deptno = dept.deptno
  order by dname
)
select ename, dname, sal
from q
where rn = 1;

-- with QUALIFY
select ename, dname, sal
from emp join dept on emp.deptno = dept.deptno
qualify row_number() over (partition by emp.deptno order by sal desc, ename) = 1
order by dname; --, sal desc, ename;
