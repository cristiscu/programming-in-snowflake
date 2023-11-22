-- create/alter a very large warehouse, to run a query
-- inspired by Tutorial 4: TPC-DS 100TB Complete Query Test
-- see https://docs.snowflake.com/en/user-guide/warehouses-overview

CREATE WAREHOUSE IF NOT EXISTS LARGE_WH
WITH WAREHOUSE_SIZE = XSMALL
     AUTO_SUSPEND = 60
     INITIALLY_SUSPENDED = TRUE;

ALTER WAREHOUSE LARGE_WH
  RESUME IF SUSPENDED;

ALTER WAREHOUSE LARGE_WH
  SET WAIT_FOR_COMPLETION = TRUE
      WAREHOUSE_SIZE = X4LARGE;
