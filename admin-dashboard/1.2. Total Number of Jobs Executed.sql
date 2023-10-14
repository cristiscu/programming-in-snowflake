-- 1.2. Total Number of Jobs Executed
-- Scorecard

select count(*) as number_of_jobs
from snowflake.account_usage.query_history
where start_time >= date_trunc(month, current_date);