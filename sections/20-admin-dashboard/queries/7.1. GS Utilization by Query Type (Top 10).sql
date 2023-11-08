-- 7.1. GS Utilization by Query Type (Top 10)
-- V Bars: sum(cs_credits), query_type on X

select
    query_type,
    sum(credits_used_cloud_services) cs_credits,
    count(1) num_queries
from snowflake.account_usage.query_history
where true and start_time >= timestampadd(day, -1, current_timestamp)
group by 1
order by 2 desc
limit 10;