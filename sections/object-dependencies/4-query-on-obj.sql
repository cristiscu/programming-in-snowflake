-- on database object $DB.$SCH.$OBJ
with recursive cte as (
  select *
    from snowflake.account_usage.object_dependencies
    where referenced_object_name = $OBJ
    and referenced_database = $DB
    and referenced_schema = $SCH
  union all
  select deps.*
    from snowflake.account_usage.object_dependencies deps
    join cte
    on cte.referencing_object_id = deps.referenced_object_id
    and cte.referencing_object_domain = deps.referenced_object_domain
)
select * from cte;
