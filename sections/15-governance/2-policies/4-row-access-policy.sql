use schema employees.public;
use role accountadmin;
select * from emp;

-- show only rows from the RESEARCH dept if role RESEARCH
create or replace row access policy research_on_deptno
  as (deptno int) returns boolean ->
  deptno = 20 or current_role() <> 'RESEARCH';

-- (could have problems recreating the materialized view!)
alter table emp
  add row access policy research_on_deptno on (deptno);

-- check
use role research;
select * from emp;
