-- snowsql -c demo_conn -f 2-create-multi-tenant.sql -D tenant=HP -D env=PROD
-- have variable substitution ON
!SET VARIABLE_SUBSTITUTION=true;

-- create roles
USE ROLE SECURITYADMIN;
CREATE OR REPLACE ROLE &{tenant}_ADM_&{env};
CREATE OR REPLACE ROLE &{tenant}_ELT_&{env};
CREATE OR REPLACE ROLE &{tenant}_APP_&{env};
CREATE OR REPLACE ROLE &{tenant}_RW_&{env};
CREATE OR REPLACE ROLE &{tenant}_RO_&{env};
 
-- create the hierarchy of roles
GRANT ROLE &{tenant}_RO_&{env} TO ROLE &{tenant}_RW_&{env};
GRANT ROLE &{tenant}_RW_&{env} TO ROLE &{tenant}_ELT_&{env};
GRANT ROLE &{tenant}_RO_&{env} TO ROLE &{tenant}_APP_&{env};
GRANT ROLE &{tenant}_ELT_&{env} TO ROLE &{tenant}_ADM_&{env};
GRANT ROLE &{tenant}_APP_&{env} TO ROLE &{tenant}_ADM_&{env};
GRANT ROLE &{tenant}_ADM_&{env} TO ROLE SYSADMIN;
 
USE ROLE ACCOUNTADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE &{tenant}_ADM_&{env};
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE &{tenant}_ADM_&{env};
 
-- create databases and objects, and grant access rights
USE ROLE &{tenant}_ADM_&{env};
CREATE DATABASE &{tenant}_DB_&{env};
GRANT USAGE ON DATABASE &{tenant}_DB_&{env} TO ROLE &{tenant}_RW_&{env};
GRANT USAGE ON DATABASE &{tenant}_DB_&{env} TO ROLE &{tenant}_RO_&{env};
 
CREATE SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RO_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RW_&{env};
 
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.PUBLIC TO ROLE &{tenant}_RO_&{env};
GRANT USAGE ON SCHEMA &{tenant}_DB_&{env}.PUBLIC TO ROLE &{tenant}_RW_&{env};
 
-- create warehouses, and grant access rights
CREATE WAREHOUSE &{tenant}_ELT_&{env} WAREHOUSE_SIZE = XSMALL;
GRANT OPERATE, USAGE ON WAREHOUSE &{tenant}_ELT_&{env} TO ROLE &{tenant}_ELT_&{env};
 
CREATE WAREHOUSE &{tenant}_APP_&{env} WAREHOUSE_SIZE = SMALL;
GRANT OPERATE, USAGE ON WAREHOUSE &{tenant}_APP_&{env} TO ROLE &{tenant}_APP_&{env};
 
-- grant rights on future tables
USE ROLE SECURITYADMIN;
GRANT SELECT ON FUTURE TABLES
  IN SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RO_&{env};
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES
  IN SCHEMA &{tenant}_DB_&{env}.&{tenant}_SCH_&{env} TO ROLE &{tenant}_RW_&{env};

-- revoke rights of the tenant _ADM_
USE ROLE ACCOUNTADMIN;
REVOKE CREATE DATABASE ON ACCOUNT FROM ROLE &{tenant}_ADM_&{env};
REVOKE CREATE WAREHOUSE ON ACCOUNT FROM ROLE &{tenant}_ADM_&{env};