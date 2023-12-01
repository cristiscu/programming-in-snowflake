-- run from current folder with: snowsql -c demo_conn -f deploy.sql
!set variable_substitution=true
!define CRT_DIR=file://C:\Projects\programming-in-snowflake\sections\17-metadata\app-multi-page

CREATE OR REPLACE DATABASE hierarchical_metadata_viewer;
-- cleanup all with: DROP DATABASE IF EXISTS hierarchical_metadata_viewer;

CREATE STAGE stage
    directory = (enable=true)
    file_format = (type=CSV field_delimiter=None record_delimiter=None);

-- transfer files
PUT &CRT_DIR\*.py @stage overwrite=true auto_compress=false;
PUT &CRT_DIR\modules\*.py @stage/modules overwrite=true auto_compress=false;
PUT &CRT_DIR\pages\*.py @stage/pages overwrite=true auto_compress=false;

-- create STREAMLIT app
CREATE STREAMLIT hierarchical_metadata_viewer
    ROOT_LOCATION = '@hierarchical_metadata_viewer.public.stage'
    MAIN_FILE = '/Main.py'
    QUERY_WAREHOUSE = "COMPUTE_WH";
SHOW STREAMLITS;
