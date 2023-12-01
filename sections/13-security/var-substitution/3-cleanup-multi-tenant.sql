-- snowsql -c demo_conn -f 3-cleanup-multi-tenant.sql -D tenant=HP -D env=PROD
-- have variable substitution ON
!SET VARIABLE_SUBSTITUTION=true;

-- drop created database objects
USE ROLE ACCOUNTADMIN;
DROP DATABASE &{tenant}_DB_&{env};
DROP WAREHOUSE &{tenant}_ELT_&{env};
DROP WAREHOUSE &{tenant}_APP_&{env};

-- drop roles
USE ROLE SECURITYADMIN;
DROP ROLE &{tenant}_ADM_&{env};
DROP ROLE &{tenant}_ELT_&{env};
DROP ROLE &{tenant}_APP_&{env};
DROP ROLE &{tenant}_RW_&{env};
DROP ROLE &{tenant}_RO_&{env};