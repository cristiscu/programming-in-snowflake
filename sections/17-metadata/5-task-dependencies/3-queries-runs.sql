use schema tasks_db.public;

-- task workflow execution
select *
from table(information_schema.task_history())
where database_name = 'TASKS_DB'
  and graph_version = 1
order by query_start_time desc;

-- enable all dependents + manual execute root task
alter task task1 resume;
alter task task1 suspend;
select system$task_dependents_enable('tasks_db.public.task1');
execute task task1;

-- show all task runs in the database
select *
from table(information_schema.task_history())
where database_name = 'TASKS_DB'
  and graph_version = 1
order by query_start_time desc;

-- get last task run
select top 1 run_id
from table(information_schema.task_history())
where database_name = 'TASKS_DB'
  and graph_version = 1
order by query_start_time desc

-- check execution results of last task run
with q as (
  select top 1 run_id
  from table(information_schema.task_history())
  where database_name = 'TASKS_DB'
    and graph_version = 1
  order by query_start_time desc
)
select *
from table(information_schema.task_history()) t
join q on t.run_id = q.run_id
order by t.query_start_time desc;

-- cleanup (this will also stop all tasks!)
drop database tasks_db;
