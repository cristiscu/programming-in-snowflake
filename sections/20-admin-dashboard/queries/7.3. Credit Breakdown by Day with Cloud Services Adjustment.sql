-- 7.3. Credit Breakdown by Day with Cloud Services Adjustment
-- V Bars: sum(credits_used_cloud_services), sum(credits_used_compute),
-- sum(credits_adjustment_cloud_services), usage_date on X

select
    credits_used_cloud_services,
    credits_used_compute,
    credits_adjustment_cloud_services,
    usage_date
from snowflake.account_usage.metering_daily_history
where usage_date = :daterange;