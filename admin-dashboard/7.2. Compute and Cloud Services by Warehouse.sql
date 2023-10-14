-- 7.2. Compute and Cloud Services by Warehouse
-- V Bars: sum(credits_used_cloud_services), sum(credits_used_compute), warehouse_name on X

select
    warehouse_name,
    sum(credits_used_cloud_services) credits_used_cloud_services,
    sum(credits_used_compute) credits_used_compute,
    sum(credits_used) credits_used
from snowflake.account_usage.warehouse_metering_history
where true and start_time = :daterange
group by 1
order by 2 desc
limit 10;