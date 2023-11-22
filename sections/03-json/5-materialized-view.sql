-- select context
use schema employees.public;

select e.*, d.*
from emp e left join dept d on e.deptno = d.deptno;

select d.dname as department, sum(e.sal) as salaries
from emp e left join dept d on e.deptno = d.deptno
group by department
order by department;

-- (try to) create materialized view
-- (not working with multiple tables!)
create materialized view salaries_per_department as
select d.dname as department, sum(e.sal) as salaries
from emp e left join dept d on e.deptno = d.deptno
group by department
order by department;

-- (try to) create materialized view
-- (not working with ORDER BY!)
create materialized view salaries_per_department as
select deptno as department, sum(sal) as salaries
from emp
group by department
order by department;

-- create materialized view
create materialized view salaries_per_department as
select deptno as department, sum(sal) as salaries
from emp
group by department;

select * from salaries_per_department
order by department;
