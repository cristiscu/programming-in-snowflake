create database snowpark_python;
create stage mystage;

-- could need to reinstall Snowpark (last version was 1.10.0):
-- pip uninstall snowflake-snowpark-python
-- pip install snowflake-snowpark-python==1.9.0
select *
from snowpark_python.information_schema.packages
where package_name = 'snowflake-snowpark-python'
  and runtime_version = '3.9'
order by version desc;

