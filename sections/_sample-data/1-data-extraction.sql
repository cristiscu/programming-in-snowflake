-- extract 1M sample rows from 100M rows customers table (~20 sec query duration)
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER
SAMPLE (1000000 ROWS);
