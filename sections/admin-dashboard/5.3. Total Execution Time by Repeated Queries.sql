-- 5.3. Total Execution Time by Repeated Queries
-- H Bars: sum(exec_time), query_text on Y
-- label X: Execution Time (Sum)

select query_text,
   (sum(execution_time) / 60000) as exec_time
from snowflake.account_usage.query_history
where execution_status = 'SUCCESS'
group by query_text
order by exec_time desc
limit 25;