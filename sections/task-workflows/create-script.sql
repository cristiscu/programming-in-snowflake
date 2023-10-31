create or replace database tasks;

create task t1 as select SYSTEM$WAIT(1);
create task t2 after t1 as select SYSTEM$WAIT(2);
create task t3 after t1 as select SYSTEM$WAIT(1);
create task t4 after t2, t3 as select SYSTEM$WAIT(1);
create task t5 after t1, t4 as select SYSTEM$WAIT(1);
create task t6 after t5 as select SYSTEM$WAIT(1);
create task t7 after t6 as select SYSTEM$WAIT(1);
create task t8 after t6 as select SYSTEM$WAIT(2);

-- show task-parent pairs
show tasks in schema tasks.public;
select t."name" task,
  replace(p.value::string, t."database_name"
    || '.' || t."schema_name" || '.') parent
from table(result_scan(last_query_id())) t,
lateral flatten(
  input => t."predecessors",
outer => true) p;

