Admin Dashboard Queries
=======================

From **[Monitoring Snowflake with Snowsight](https://medium.com/snowflake/monitoring-snowflake-with-snowsight-e9990a2898f1)**, written by a Ashish Patel, Data Engineer at Snowflake.

Setup Instructions
------------------

1. In Snowsight, connect with ACCOUNTADMIN role, or role with access to SNOWFLAKE.ACCOUNT_USAGE schema.
2. Create a new "Admin Dashboard" dashboard, with your role and COMPUTE_WH as warehouse.
3. Copy each query in a new dashboard tile, from a new SQL Worksheet.
4. Change the title to the file name, without the .sql extension and number prefix.
5. Run the query. (Filter by more than just the last day, if needed.)
6. Switch to Chart and customize accordingly.
7. Arrange on the dashboard according to the tile number (ex: 7.2. means row 7, column 2).
8. Filter by :daterange (by default last day).
