-- 4.1. Warehouse Usage Greater than 7 Day Average
-- V Bars: sum(Variance_To_7_Day_Average), warehouse_name as Series, Date on X
-- order bars by Date DESC ASC

select
   warehouse_name,
   date(start_time) AS Date,
   sum(credits_used) AS Credits_Used,
   avg(sum(credits_used)) over (
      partition by warehouse_name
      order by Date rows 7 preceding) as Credits_Used_7_Day_Avg,
   (to_numeric(sum(Credits_Used) / Credits_Used_7_Day_Avg * 100, 10, 2) - 100)::string
      || '%' as Variance_To_7_Day_Average
from snowflake.account_usage.warehouse_metering_history
where start_time = :daterange
group by Date, warehouse_name
order by Date desc;