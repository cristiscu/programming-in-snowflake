-- select database and schema
use schema employees.public;

-- GROUP BY with GROUPING SETS
select deptno,
  to_char(year(hiredate)) as year,
  grouping(deptno) deptno_g,
  grouping(year) year_g,
  grouping(deptno, year) deptno_year_g,
  sum(sal) sals
from emp where year > '1980'
group by grouping sets (deptno, year)
having sum(sal) > 5000
order by deptno, year;

-- GROUP BY with ROLLUP
select deptno,
  to_char(year(hiredate)) as year,
  grouping(deptno) deptno_g,
  grouping(year) year_g,
  grouping(deptno, year) deptno_year_g,
  sum(sal) sals
from emp where year > '1980'
group by rollup (deptno, year)
having sum(sal) > 5000
order by deptno, year;

-- GROUP BY with CUBE
select deptno,
  to_char(year(hiredate)) as year,
  grouping(deptno) deptno_g,
  grouping(year) year_g,
  grouping(deptno, year) deptno_year_g,
  sum(sal) sals
from emp where year > '1980'
group by cube (deptno, year)
having sum(sal) > 5000
order by deptno, year;
