-- 2.1. Credit Usage by Warehouse
-- H Bars: sum(total_credits_used), warehouse_name on Y

select
   warehouse_name,
   sum(credits_used) as total_credits_used
from snowflake.account_usage.warehouse_metering_history
where start_time = :daterange
group by 1
order by 2 desc;