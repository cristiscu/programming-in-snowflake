-- 2.2. Jobs by Warehouse
-- H Bars: sum(total_jobs), warehouse_name on Y

select
   warehouse_name,
   count(*) as total_jobs
from snowflake.account_usage.warehouse_metering_history
where start_time = :daterange
group by 1
order by 2 desc;