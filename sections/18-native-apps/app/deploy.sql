-- run from current folder with: snowsql -c demo_conn -f deploy.sql
!set variable_substitution=true
!define CRT_DIR=file://C:\Projects\programming-in-snowflake\sections\18-native-apps\app

DROP APPLICATION IF EXISTS hierarchical_data_app CASCADE;
DROP APPLICATION PACKAGE IF EXISTS hierarchical_data_package;

-- create app package
CREATE APPLICATION PACKAGE hierarchical_data_package;
SHOW APPLICATION PACKAGES;
USE APPLICATION PACKAGE hierarchical_data_package;
DROP SCHEMA public;

-- =============================================================
-- create data to share through a view
CREATE SCHEMA shared;
GRANT USAGE ON SCHEMA shared TO SHARE
   IN APPLICATION PACKAGE hierarchical_data_package;

CREATE TABLE employees (EMPLOYEE VARCHAR, MANAGER VARCHAR);
GRANT SELECT ON TABLE employees TO SHARE
   IN APPLICATION PACKAGE hierarchical_data_package;

-- =============================================================
CREATE SCHEMA native;

CREATE STAGE stage
    directory = (enable=true)
    file_format = (type=CSV field_delimiter=None record_delimiter=None);

-- upload test data file into local EMPLOYEES table
PUT &CRT_DIR\data\employee-manager.csv @stage/data
    overwrite=true auto_compress=false;
COPY INTO shared.employees FROM @stage/data
    FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"'
        NULL_IF='' EMPTY_FIELD_AS_NULL=true);

PUT &CRT_DIR\manifest.yml @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\README.md @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\setup.sql @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\app.py @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\modules\*.py @stage/modules overwrite=true auto_compress=false;
LIST @stage;

-- set app version
ALTER APPLICATION PACKAGE hierarchical_data_package
  ADD VERSION v1_0
  USING '@stage'
  LABEL = 'Hierarchical Data App v1.0';
  
ALTER APPLICATION PACKAGE hierarchical_data_package
  SET DEFAULT RELEASE DIRECTIVE
  VERSION = v1_0
  PATCH = 0;

-- create app
CREATE APPLICATION hierarchical_data_app
    FROM APPLICATION PACKAGE hierarchical_data_package
    USING '@stage'
    DEBUG_MODE = true;
SHOW APPLICATIONS;
