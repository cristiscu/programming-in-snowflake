import os
import snowflake.connector

# customize with your own account locator and user name
with snowflake.connector.connect(
    account='BTB76003',
    user='cristiscu',
    password=os.environ['SNOWSQL_PWD']) as conn:
    with conn.cursor() as cur:
        cur.execute("show parameters")
        for row in cur:
            print(f'{str(row[0])}={str(row[1])}')
