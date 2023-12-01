# Section: Access Control in Snowflake

## SnowSQL with Variable Substitution

1. Make sure your SQL script file using variable substitution starts with **`!SET VARIABLE_SUBSTITUTION=true;`**.

2. Call from a command line something like **`snowsql -c demo_conn -f var-substitution.sql -D tenant=HP -D env=PROD`**:
    * *-c demo_conn* is using this connection from the config file (and password from env var)
    * *-f var-substitution.sql* will run this SQL script file
    * *-D tenant=HP -D env=PROD* will litearlly replace everywhere in the file the *\${tenant}* and *\${env}* occurances by *HP* and *PROD*.

