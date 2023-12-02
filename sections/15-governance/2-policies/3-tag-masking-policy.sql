use schema employees.public;
use role accountadmin;
select * from emp;

-- hide salary to role RESEARCH if column tagged w/ SECURITY_CLASS=PII (already done!)
create or replace masking policy research_on_salary
  as (salary float) returns float ->
  case when SYSTEM$GET_TAG_ON_CURRENT_COLUMN(
    'EMPLOYEES.PUBLIC.SECURITY_CLASS') <> 'PII'
    and current_role() = 'RESEARCH'
  then salary else null
  end;

ALTER TAG security_class
  SET MASKING POLICY research_on_salary;

-- check
use role research;
select * from emp;
