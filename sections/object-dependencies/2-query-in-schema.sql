select dependency_type type,
  referencing_object_name
  || ' (' || referencing_object_domain || ')'
  || ' -> ' || referenced_object_name
  || ' (' || referenced_object_domain || ')' ref
from snowflake.account_usage.object_dependencies
where referenced_database = 'DEPS_DB'
  and referencing_database = 'DEPS_DB'
  and referenced_schema = 'PUBLIC'
  and referencing_schema = 'PUBLIC';
