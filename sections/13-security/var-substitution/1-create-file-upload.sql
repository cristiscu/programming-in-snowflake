-- snowsql -c demo_conn -f 1-create-file-upload.sql
-- have variable substitution ON
!set variable_substitution=true

CREATE OR REPLACE DATABASE stage_upload;
CREATE STAGE mystage;

-- transfer files
!define CRT_DIR=file://C:\Projects\programming-in-snowflake\sections\13-security\var-substitution
PUT &CRT_DIR\1-create-file-upload.sql @mystage;
PUT &CRT_DIR\2-create-multi-tenant.sql @mystage;
PUT &CRT_DIR\3-cleanup-multi-tenant.sql @mystage;

LIST @mystage;