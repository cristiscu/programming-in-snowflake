use schema employees.public;
use role accountadmin;
select * from emp;

-- partially mask year of HIREDATE (show 2000 instead) to role RESEARCH
create or replace masking policy research_on_hiredate
  as (hiredate date) returns date ->
    case current_role() when 'RESEARCH'
    then date_from_parts(2000, month(hiredate), day(hiredate))
    else hiredate end;

-- (may need to drop and then recreate a related materialized view!)
alter table emp
  modify column hiredate
  set masking policy research_on_hiredate;

-- check
use role research;
select * from emp;
