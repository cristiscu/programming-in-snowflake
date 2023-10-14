-- 6.2. Average Query Execution Time (By User)
-- V Bars: sum(average_execution_time), user_name on X
-- labels X: Username, Y: Execution Time (seconds)

select user_name,
    (avg(execution_time)) / 1000 as average_execution_time
from snowflake.account_usage.query_history
where start_time = :daterange
group by 1
order by 2 desc;