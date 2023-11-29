select qh.query_text,
   trim(ifnull(src.value:objectName::string, '')
      || '.' || ifnull(src.value:columnName::string, ''), '.') as source,
   trim(ifnull(om.value:objectName::string, '')
      || '.' || ifnull(col.value:columnName::string, ''), '.') as target,
   ah.objects_modified
from snowflake.account_usage.access_history ah
   left join snowflake.account_usage.query_history qh
   on ah.query_id = qh.query_id,
   lateral flatten(input => objects_modified) om,
   lateral flatten(input => om.value:"columns", outer => true) col,
   lateral flatten(input => col.value:directSources, outer => true) src
where ifnull(src.value:objectName::string, '') like 'LINEAGE_DB%'
   or ifnull(om.value:objectName::string, '') like 'LINEAGE_DB%'
order by ah.query_start_time;


-- create new database
create database if not exists data_deps;
use schema data_deps.public;

create or replace function get_lineage(sch varchar)
   returns table(source varchar, target varchar)
as $$
   select distinct
      substr(directSources.value:objectName, len(sch)+2) as source,
      substr(objects_modified.value:objectName, len(sch)+2) as target
   from snowflake.account_usage.access_history,
      lateral flatten(input => objects_modified) objects_modified,
      lateral flatten(input => objects_modified.value:"columns", outer => true) cols,
      lateral flatten(input => cols.value:directSources, outer => true) directSources
   where directSources.value:objectName like sch || '%'
      or objects_modified.value:objectName like sch || '%'
$$;

select * from table(get_lineage('LINEAGE_DB.TEST_SCHEMA'));
select * from table(get_lineage('EMPLOYEES.PUBLIC'));