-- 8.2. Total Row Loaded by Day
-- Lines: Total_Row_Count, Last_Load_Time_Date
-- Fill area, Label X: Date, Label Y: # Rows Loaded

select
   to_char(to_date(last_load_time), 'YYYY-MM-DD') as Last_Load_Time_Date,
   coalesce(sum(row_count), 0) as Total_Row_Count
from snowflake.account_usage.load_history
where last_load_time = :daterange
group by to_date(last_load_time)
order by 1 desc;