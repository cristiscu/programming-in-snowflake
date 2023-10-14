-- 1.1. Credits Used
-- Scorecard

select sum(credits_used)
from snowflake.account_usage.metering_history
where start_time = :daterange;