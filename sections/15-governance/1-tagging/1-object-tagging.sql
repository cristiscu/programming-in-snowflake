-- select database and schema
use schema employees.public;

-- (1) create tags
create tag department
  allowed_values 'sales', 'finance', 'engineering';
alter tag department
  drop allowed_values 'engineering';

select get_ddl('tag', 'DEPARTMENT');
-- --> create or replace tag DEPARTMENT  allowed_values  'finance' , 'sales' ;

select system$get_tag_allowed_values('DEPARTMENT');
-- --> ["finance","sales"]

create tag region
  allowed_values 'APAC', 'EMEA', 'NA';

create tag security_class -- for tag-based masking policies
  allowed_values 'PII', 'PCI', 'PHI';

-- (2) assign tags
alter warehouse compute_wh
  set tag department = 'sales',
          region = 'APAC',
          security_class = 'PCI';
alter warehouse compute_wh
    unset tag security_class;

create temp table table1(v variant)
  with tag (department = 'finance');

alter table emp
  alter column sal
  set tag security_class = 'PII';

-- (3) track tags
show tags;

-- information_schema --> security_class = 'PII'
select * from table(
  information_schema.tag_references(
    'EMPLOYEES.PUBLIC.EMP.SAL', 'column'));

select * from table(
  information_schema.tag_references_all_columns(
    'EMPLOYEES.PUBLIC.EMP', 'table'));

-- latency in ACCOUNT_USAGE!
select * from snowflake.account_usage.tags;
select * from snowflake.account_usage.tag_references;

select * from table(
  snowflake.account_usage.tag_references_with_lineage(
    'EMPLOYEES.PUBLIC.DEPARTMENT'));
