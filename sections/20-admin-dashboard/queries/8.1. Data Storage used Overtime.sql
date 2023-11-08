-- 8.1. Data Storage used Overtime
-- Stacked V Bars: sum(storage_tb), sum(stage_tb), sum(faildafe_tb), usage_month on X

select
    date_trunc(month, usage_date) as usage_month,
    avg(storage_bytes + stage_bytes + failsafe_bytes) / power(1024, 4) as billable_tb,
    avg(storage_bytes) / power(1024, 4) as Storage_TB,
    avg(stage_bytes) / power(1024, 4) as Stage_TB,
    avg(failsafe_bytes) / power(1024, 4) as Failsafe_TB
from snowflake.account_usage.storage_usage
group by 1
order by 1;