-- create database EMPLOYEES with table EMP from CSV file
create or replace database employees;
create stage mystage;

-- cannot run this from the web UI, upload manually (file in GitHub)
-- put file://C:\data\emp.csv @mystage;

-- inspect uploaded file directly
SELECT METADATA$FILE_ROW_NUMBER as RowId,
  $1, $2, $3, $4, $5
FROM @mystage/emp.csv;

-- create CSV file format, for INFER_SCHEMA (w/ PARSE_HEADER)  
create or replace file format mycsvformat
  TYPE = csv,
  PARSE_HEADER = TRUE;

-- (1) show inferred columns
-- (2) use them to create table DDL
-- (3) use them to create table directly
-- see https://docs.snowflake.com/en/sql-reference/functions/infer_schema
SELECT *
FROM TABLE(INFER_SCHEMA(
  LOCATION => '@mystage',
  FILES => 'emp.csv',
  FILE_FORMAT => 'mycsvformat'));

SELECT GENERATE_COLUMN_DESCRIPTION(
  ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') AS COLUMNS
FROM TABLE(INFER_SCHEMA(
  LOCATION => '@mystage',
  FILES => 'emp.csv',
  FILE_FORMAT => 'mycsvformat'));

/*
"EMPNO" NUMBER(4, 0),
"ENAME" TEXT,
"JOB" TEXT,
"MGR" NUMBER(4, 0),
"HIREDATE" DATE,
"SAL" NUMBER(5, 1),
"COMM" NUMBER(5, 1),
"DEPTNO" NUMBER(2, 0)
*/
        
CREATE OR REPLACE TABLE emp USING TEMPLATE (
  SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
  FROM TABLE(INFER_SCHEMA(
    LOCATION => '@mystage',
    FILES => 'emp.csv',
    FILE_FORMAT => 'mycsvformat')));
select * from emp;
