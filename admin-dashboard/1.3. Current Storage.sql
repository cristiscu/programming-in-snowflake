-- 1.3. Current Storage
-- Scorecard

select avg(storage_bytes + stage_bytes + failsafe_bytes) / power(1024, 4) as billable_tb
from snowflake.account_usage.storage_usage
where usage_date = current_date() - 1;