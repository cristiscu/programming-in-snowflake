-- select test database and schema
use schema employees.public;

-- sampling
select * from emp;
select * from emp sample row (5 rows);

-- simple query
select ename from emp
   where job <> 'SALESMAN'
   order by ename;

-- limit/offset (should return clark, ford, james)
select ename from emp
   where job <> 'SALESMAN'
   order by ename
   limit 3 offset 2;

-- distinct values
select distinct job from emp;

-- joined tables
select ename, job, dname, sal
   from emp inner join dept
   on emp.deptno = dept.deptno;

-- group query
select job, dname, sum(sal) as tot_sal
   from emp inner join dept
   on emp.deptno = dept.deptno
   group by job, dname
   order by job, dname;

-- query plan (go also to Query Profile)
explain
  select job, dname, sum(sal) as tot_sal
   from emp inner join dept
   on emp.deptno = dept.deptno
   group by job, dname
   order by job, dname;

-- group query w/ WHERE/HAVING
select job, dname, sum(sal) as tot_sal
   from emp inner join dept
   on emp.deptno = dept.deptno
   where dname <> 'RESEARCH'
   group by job, dname
   having tot_sal >= 1000
   order by job, dname;
