-- 3.1. Credit Usage Overtime
-- V Bars: sum(total_credits_used), warehouse_name as Series, usage_date on X
-- order bars by usage ASC ASC, label X: Date, label Y: Credits

select
   start_time::date as usage_date,
   warehouse_name,
   sum(credits_used) as total_credits_used
from snowflake.account_usage.warehouse_metering_history
where start_time = :daterange
group by 1, 2
order by 2, 1;