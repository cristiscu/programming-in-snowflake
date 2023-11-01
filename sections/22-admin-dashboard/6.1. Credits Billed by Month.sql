-- 6.1. Credits Billed by Month
-- V Bars: sum(Credits_Billed), usage_month on X

select
   date_trunc('MONTH', usage_date) as Usage_Month,
   sum(credits_billed) as Credits_Billed
from snowflake.account_usage.metering_daily_history
group by Usage_Month;