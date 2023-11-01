-- (1) partially mask year of HIREDATE to new role RESEARCH
use role accountadmin;

create masking policy research_on_year
  as (hiredate date) returns date ->
  case when current_role() <> 'RESEARCH' then hiredate
  else date_from_parts(2000, month(hiredate), day(hiredate)) end;

alter table emp
  modify column hiredate
  set masking policy research_on_year;

-- create new restricted role RESEARCH
create role research;
grant role research to user cristiscu;

grant usage on warehouse compute_wh to role research;
grant usage on database employees to role research;
grant usage on schema employees.public to role research;
grant select on table employees.public.emp to role research;

use role research;
select * from emp;

-- (2) create restricted view EMP_R
use role accountadmin;

create view emp_r as (
  select * from emp
  where deptno = 20 or current_role() <> 'RESEARCH'
);
select * from emp_r;

revoke select on table employees.public.emp from role research;
grant select on view employees.public.emp_r to role research;

-- check the role is restricted indeed
use role research;
select * from emp;
select * from emp_r;

-- (3) restrict role RESEARCH through row access policy
use role accountadmin;
grant select on table employees.public.emp to role research;

create row access policy research_on_emp
  as (deptno int) returns boolean ->
  deptno = 20 or current_role() <> 'RESEARCH';

alter table emp
  add row access policy research_on_emp
  on (deptno);
select * from emp;

-- check the role is restricted indeed
use role research;
select * from emp;

