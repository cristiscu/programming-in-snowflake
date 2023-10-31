-- select test database and schema
use schema employees.public;

-- subqueries
select ee.deptno,
  sum(ee.sal) as sum_sal,
  (select max(sal)
   from emp
   where deptno = ee.deptno) as max_sal
from emp ee
where ee.empno in
  (select empno
   from emp e
   join dept d on e.deptno = d.deptno
   where d.dname <> 'RESEARCH')
group by ee.deptno
order by ee.deptno;

-- equivalent CTEs
with q1 as 
  (select empno
   from emp e
   join dept d on e.deptno = d.deptno
   where d.dname <> 'RESEARCH'),

q2 as 
  (select deptno, max(sal) max_sal
   from emp
   group by deptno)

select ee.deptno,
  sum(ee.sal) as sum_sal,
  max(q2.max_sal) as max_sal
from emp ee
  join q2 on q2.deptno = ee.deptno
  join q1 on q1.empno = ee.empno
group by ee.deptno
order by ee.deptno;
