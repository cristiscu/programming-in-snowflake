-- 9.1. Logins by User
-- H Bars: sum(Failed), sum(Success), user_name on Y

select
    user_name,
    sum(iff(is_success = 'NO', 1, 0)) as Failed,
    count(*) as Success,
    sum(iff(is_success = 'NO', 1, 0)) / nullif(count(*), 0) as login_failure_rate
from snowflake.account_usage.login_history
where event_timestamp = :daterange
group by 1
order by 4 desc;