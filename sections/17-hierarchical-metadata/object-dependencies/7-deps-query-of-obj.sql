-- of database object $DB.$SCH.$OBJ
with recursive cte as (
  select *
    from snowflake.account_usage.object_dependencies
    where referencing_object_name = $OBJ
    and referencing_database = $DB
    and referencing_schema = $SCH
  union all
  select deps.*
    from snowflake.account_usage.object_dependencies deps
    join cte
    on deps.referencing_object_id = cte.referenced_object_id
    and deps.referencing_object_domain = cte.referenced_object_domain
)
select * from cte;
