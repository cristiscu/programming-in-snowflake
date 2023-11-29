-- show task-parent pairs
use schema tasks_db.public;

show tasks in schema tasks.public;

select t."name" as task,
  split_part(p.value::string, '.', -1) as parent
from table(result_scan(last_query_id())) t,
lateral flatten(input => t."predecessors", outer => true) p;
