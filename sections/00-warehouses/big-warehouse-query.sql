-- establish context
USE SCHEMA snowflake_sample_data.tpcds_sf100tcl;

CREATE OR REPLACE WAREHOUSE large_wh
WITH
  WAREHOUSE_SIZE = X4LARGE
  AUTO_SUSPEND = 60
  INITIALLY_SUSPENDED = FALSE;

-- USE WAREHOUSE large_wh;
-- USE WAREHOUSE compute_wh;

select count(*)
from store_sales, household_demographics, time_dim, store
where ss_sold_time_sk = time_dim.t_time_sk
  and ss_hdemo_sk = household_demographics.hd_demo_sk
  and ss_store_sk = s_store_sk
  and time_dim.t_hour = 8
  and time_dim.t_minute >= 30
  and household_demographics.hd_dep_count = 5
  and store.s_store_name = 'ese'
order by count(*)
limit 100;
