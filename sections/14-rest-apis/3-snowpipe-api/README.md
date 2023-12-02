# Snowpipe REST API

1. We assume you already generated and tested connecting to Snowflake with a key pair at the previous steps.

2. From a terminal window in VSCode, switch to the *snowpipe-api/* folder.

3. Run **`pip install requirements.txt`** to install the *Snowflake Connector Python* and [*Snowflake Ingest*](https://github.com/snowflakedb/snowflake-ingest-python) packages.

4. Run **`snowsql -c demo_conn -f 1-create-script.sql`**`, which should create:
    * a new *emp_pipe* target table
    * a new *@mystage_pipe* intenal named stage
    * a new *mypipe* Snowpipe with no auto-ingest
    * *emp11.csv* and *emp12.csv* files from the local *data/* subfolder uploaded into the stage

5. Customize the hard-coded values from **2-client.py** ([inspired by](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-load#sample-program-for-the-python-sdk)) with your own private key file location and Snowflake connection parameters. Then run **`python 2-client.py`**.

6. Check the response comparing to the **3-client-results.md** file (the JSON response content has been rendered better in this file with [this online tool](https://jsonformatter.curiousconcept.com/#)).

7. If you got errors, check the **tmp/ingest.log** logger file (it may likely contain data from my previous running sessions as well).

***Remark***: Do not try to re-execute the last steps as they are, because Snowpipe prevents reloading the same files. To repeat the whole experiment properly, recreate all database objects starting with step 4.
