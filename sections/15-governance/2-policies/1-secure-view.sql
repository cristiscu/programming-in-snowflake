use schema employees.public;

-- create role RESEARCH
use role accountadmin;
create role if not exists research;
grant role research to user cscutaru;

grant usage on warehouse compute_wh to role research;
grant usage on database employees to role research;
grant usage on schema employees.public to role research;
grant select on table employees.public.emp to role research;

-- check
use role research;
select * from emp;

-- =============================================================
-- using restricted (secure) view
use role accountadmin;
create or replace secure view emp_r as
    select empno, ename, job, mgr,
      to_varchar(hiredate,
        case current_role() when 'RESEARCH'
        then '****-MM-DD' else 'YYYY-MM-DD'
        end) as hiredate,
      -- case current_role() when 'RESEARCH'
      -- then null else sal
      -- end as sal,
      comm, deptno
    from emp
    where deptno = 20 or current_role() <> 'RESEARCH';
select * from emp_r;

-- hide emp, allows only restricted view
use role accountadmin;
revoke select on table employees.public.emp from role research;
grant select on view employees.public.emp_r to role research;

-- check
use role research;
select * from emp; -- this must fail!
select * from emp_r;

-- restore access to EMP table
use role accountadmin;
grant select on table employees.public.emp to role research;
