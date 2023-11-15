# Section: Admin Dashboard in Snowsight

From **[Monitoring Snowflake with Snowsight](https://medium.com/snowflake/monitoring-snowflake-with-snowsight-e9990a2898f1)**, written by a Ashish Patel, Data Engineer at Snowflake.

## Setup Instructions

1. In Snowsight, connect with ACCOUNTADMIN role, or role with access to SNOWFLAKE.ACCOUNT_USAGE schema.
2. Create a new "Admin Dashboard" dashboard, with your role and COMPUTE_WH as warehouse.
3. Copy each query in a new dashboard tile, from a new SQL Worksheet.
4. Change the title to the file name, without the .sql extension and number prefix.
5. Run the query. (Filter by more than just the last day, if needed.)
6. Switch to Chart and customize accordingly.
7. Arrange on the dashboard according to the tile number (ex: 7.2. means row 7, column 2).
8. Filter by :daterange (by default last day).

## SQL Files/Queries

1.1. Credits Used <-- **metering_history**

1.2. Total Number of Jobs Executed <-- **query_history**

1.3. Current Storage <-- **storage_usage**

2.1. Credit Usage by Warehouse <-- **warehouse_metering_history**

2.2. Jobs by Warehouse <-- **warehouse_metering_history**

3.1. Credit Usage Overtime <-- **warehouse_metering_history**

4.1. Warehouse Usage Greater than 7 Day Average <-- **warehouse_metering_history**

5.1. Execution Time by Query Type (Avg Seconds) <-- **query_history**

5.2. Top 25 Longest Queries <-- **query_history**

5.3. Total Execution Time by Repeated Queries <-- **query_history**

6.1. Credits Billed by Month <-- **metering_daily_history**

6.2. Average Query Execution Time (By User) <-- **query_history**

7.1. GS Utilization by Query Type (Top 10) <-- **query_history**

7.2. Compute and Cloud Services by Warehouse <-- **warehouse_metering_history**

7.3. Credit Breakdown by Day with Cloud Services Adjustment <-- **metering_daily_history**

8.1. Data Storage used Overtime <-- **storage_usage**

8.2. Total Row Loaded by Day <-- **load_history**

9.1. Logins by User <-- **login_history**

9.2. Logins by Client <-- **login_history**
