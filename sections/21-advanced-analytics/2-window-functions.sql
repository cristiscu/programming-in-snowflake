use schema employees.public;

-- window frame (--> moving average)
select ename, hiredate, sal,
  round(avg(sal) over (order by hiredate
    rows between 2 preceding and current row), 2) as avg
from emp
order by hiredate;

-- rank functions
select deptno, ename,
  row_number() over (order by deptno) row_number,
  rank() over (order by deptno) rank,
  dense_rank() over (order by deptno) dense_rank,
  round(percent_rank() over (order by deptno) * 100) || '%' percent_rank,
  ntile(3) over (order by deptno) ntile
from emp
order by deptno;

-- offset functions
select ename, hiredate,
  lead(sal, 1) over (order by hiredate) lead,
  sal,
  lag(sal, 1) over (order by hiredate) lag,
  case when lag > sal then 'down' else 'up' end var,
  first_value(sal) over (order by hiredate) first,
  last_value(sal) over (order by hiredate) last,
  nth_value(sal, 1) over (order by hiredate) nth
from emp
order by hiredate;
