-- 5.2. Top 25 Longest Queries
-- H Bars: sum(exec_time), Query_text on Y
-- labels X: Execution Time (minutes)

select query_id, query_text,
   (execution_time / 60000) as exec_time
from snowflake.account_usage.query_history
where execution_status = 'SUCCESS'
order by execution_time desc
limit 25;