show imported keys
  in schema "Chinook".PUBLIC;

select distinct "pk_table_name", "fk_table_name"
from table(result_scan(last_query_id()));