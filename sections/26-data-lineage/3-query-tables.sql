create or replace function get_data_lineage(sch varchar)
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

select * from table(get_data_lineage('LINEAGE_DB.TEST_SCHEMA'));
