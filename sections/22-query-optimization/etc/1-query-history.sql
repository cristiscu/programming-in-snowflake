with q1 as (
  select query_text,
    count(*) as times,
    round(sum(total_elapsed_time) / 1000) as tot_secs,
    round(avg(execution_time)) as avg_ms,
    round(avg(bytes_scanned) / 1000000) avg_mb
  from snowflake.account_usage.query_history
  where total_elapsed_time > 0
  and partitions_scanned is not null
  and error_code is null
  and execution_status = 'SUCCESS'
  -- and query_type = 'SELECT'
  -- and warehouse_size = 'X-SMALL'
  -- and database_name = 'EMPLOYEES'
  -- and user_name = 'cscutaru'
  -- and query_tag = '...'
  group by 1
  order by times desc -- by 2/3/4/5
  limit 10000
),
q2 as (
  select *, row_number() over (order by times desc) as rn
  from q1
)
select * from q2
-- where query_text = 'select system$wait(1)';
