-- 5.1. Execution Time by Query Type (Avg Seconds)
-- H Bars: sum(average_execution_time), query_type on Y

select
    query_type,
    warehouse_size,
    avg(execution_time) / 1000 as average_execution_time
from snowflake.account_usage.query_history
where start_time = :daterange
group by 1, 2
order by 3 desc;