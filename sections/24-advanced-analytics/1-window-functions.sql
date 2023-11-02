-- select database and schema
use schema employees.public;

-- window frame
select ename, hiredate, sal,
  round(avg(sal) over (order by hiredate
    rows between 1 preceding and 1 following), 2) as avg
from emp
order by hiredate;

-- rank functions
select deptno, ename,
  row_number() over (order by deptno) row_number,
  rank() over (order by deptno) rank,
  dense_rank() over (order by deptno) dense_rank,
  round(percent_rank() over (order by deptno) * 100) || '%' percent_rank
from emp
order by deptno;

-- offset functions
select ename,
  lead(sal, 1) over (order by ename) lead,
  sal,
  lag(sal, 1) over (order by ename) lag,
  first_value(sal) over (order by ename) first,
  last_value(sal) over (order by ename) last,
  nth_value(sal, 1) over (order by ename) nth
from emp
order by ename;
