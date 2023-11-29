-- show all obj deps in account (can get a lot of data!)
select * 
from snowflake.account_usage.object_dependencies;

-- create new database
create database if not exists obj_deps;
use schema obj_deps.public;

-- simplified view for object_dependencies
create or replace view obj_deps as
  select referencing_object_name as refing_name,
    lower(referencing_object_domain) as refing_type,
    referencing_object_id as refing_id,
    referencing_database as refing_db,
    referencing_schema as refing_sch,
    referenced_object_name as refed_name,
    lower(referenced_object_domain) as refed_type,
    referenced_object_id as refed_id,
    referenced_database as refed_db,
    referenced_schema as refed_sch
  from snowflake.account_usage.object_dependencies;

select * from obj_deps;

-- show object deps from a specific database schema
create or replace procedure show_deps(db string, sch string)
  returns table(
    refing_name string, refing_type string,
    refed_name string, refed_type string)
  language sql
as
declare
  rs resultset default (
    select refing_name, refing_type, refed_name, refed_type
    from obj_deps
    where refing_db = :db and refing_sch = :sch
      and refed_db = :db and refed_sch = :sch);
begin
  return table(rs);
end;

call show_deps('EMPLOYEES', 'PUBLIC');
call show_deps('DEPS_DB', 'PUBLIC');

-- show referenced by a schema object (assume same db/sch)
create or replace procedure show_refed(db string, sch string, name string)
  returns table(
    refing_name string, refing_type string,
    refed_name string, refed_type string)
  language sql
as
declare
  rs resultset default (
    with recursive cte as (
      select * from obj_deps
        where refing_name = :name
          and refing_db = :db and refing_sch = :sch
      union all
      select d.* from obj_deps d
        join cte on d.refing_id = cte.refed_id
          and d.refing_type = cte.refed_type)
    select refing_name, refing_type, refed_name, refed_type
    from cte);
begin
  return table(rs);
end;

call show_refed('EMPLOYEES', 'PUBLIC', 'EMPLOYEE_MANAGER');
call show_refed('DEPS_DB', 'PUBLIC', 'V1');

-- show referencing a schema object (assume same db/sch)
create or replace procedure show_refing(db string, sch string, name string)
  returns table(
    refing_name string, refing_type string,
    refed_name string, refed_type string)
  language sql
as
declare
  rs resultset default (
    with recursive cte as (
      select * from obj_deps
        where refed_name = :name
          and refed_db = :db and refed_sch = :sch
      union all
      select d.* from obj_deps d
        join cte on cte.refing_id = d.refed_id
          and cte.refing_type = d.refed_type)
    select refing_name, refing_type, refed_name, refed_type
    from cte);
begin
  return table(rs);
end;

call show_refing('EMPLOYEES', 'PUBLIC', 'EMPLOYEE_MANAGER');
call show_refing('DEPS_DB', 'PUBLIC', 'V1');