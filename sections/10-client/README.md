# Section: Client Programming with Snowflake

## SnowCD (Connectivity Diagnostic Tool)

1. In Snowsight, run **`select system$allowlist();`** (former *system$whitelist()*), and save the result into a **allowlist.json** file.

2. From a terminal in VSCode, run **`snowcd allowlist.json`**. You could get on screen something like *"Performing M checks for N hosts. All checks passed"*, if everything went well.

3. For private links, run **`select system$allowlist_privatelink();`** in Snowsight instead, save the result into a **allowlist_privatelink.json** file, then run from a terminal in VSCode **`snowcd allowlist_privatelink.json`**.

## SnowSQL (Snowflake's CLI Tool)

You may use the SnowSQL configuration file in code, to connect to Snowflake without passing connection parameters (such as account name, or user name) in the command like. You may also use rather environment variables for sensitive parameters (such as the passwork, or the encrypted private key passcode).

1. Save your Snowflake password into a local **SNOWSQL_PWD** environment variable.

2. In your local SnowSQL config file (**~/.snowsql/config** on Windows, in your user folder), enter a section with your specific connection to Snowflake (account name and user name, no password!), like the following:
```
[connections.demo_conn]
accountname = BTB76003
username = cristiscu
```

3. To connect and run a SQL script, call from the command line something like **`snowsql -c demo_conn -f my-script.sql`**

