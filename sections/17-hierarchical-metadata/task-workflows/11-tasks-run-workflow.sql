-- enable all last child dependants
select SYSTEM$TASK_DEPENDENTS_ENABLE('tasks.public.t8');

-- manual execution of the root task
execute task t1;

-- check results (w/ session variable!)
set runId = (select top 1 run_id
  from table(information_schema.task_history(task_name => 'T1'))
  order by query_start_time desc);

select name, state,
  scheduled_time, query_start_time, completed_time
from table(information_schema.task_history())
where run_id = $runId
order by query_start_time;

/*
-- equivalent, with subquery
select name, state, scheduled_time, query_start_time, completed_time
  from table(information_schema.task_history())
  where run_id = (select top 1 run_id
    from table(information_schema.task_history(task_name => 'T1'))
    order by query_start_time desc)
 order by query_start_time;
*/
