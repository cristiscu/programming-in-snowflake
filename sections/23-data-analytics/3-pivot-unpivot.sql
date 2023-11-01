-- select database and schema
use schema employees.public;

-- GROUP BY query
select dname,
  to_char(year(hiredate)) as year,
  sum(sal) as sals
  from emp
  join dept on emp.deptno = dept.deptno
  where year >= '1982'
  group by dname, year
  order by dname, year;

-- PIVOT query
with q as 
  (select dname,
   year(hiredate) as year,
   sum(sal) as sals
   from emp
   join dept on emp.deptno = dept.deptno
   where year >= 1982
   group by dname, year
   order by dname, year)

select * from q
pivot (sum(sals)
  for year in (1982, 1983)) as p;

-- UNPIVOT query --> back to GROUP BY
with q as 
  (select dname,
   year(hiredate) as year,
   sum(sal) as sals
   from emp
   join dept on emp.deptno = dept.deptno
   where year >= 1982
   group by dname, year
   order by dname, year),

p as
  (select * from q
   pivot (sum(sals)
     for year in (1982, 1983)) as p)

select * from p
unpivot (sals
  for year in ("1982", "1983"));
