import os, configparser
import snowflake.connector

# customize with your own connection
parser = configparser.ConfigParser()
parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
section = "connections.demo_conn"
con = snowflake.connector.connect(
    account=parser.get(section, "accountname"),
    user=parser.get(section, "username"),
    password=os.environ['SNOWSQL_PWD'],
    database='EMPLOYEES',
    schema='PUBLIC'
)

print("\nemployee-manager2:")
with con.cursor() as cur:
    cur.execute("select * from employee_manager2")
    for row in cur:
        print(str(row[0]), str(row[1]))

print("\nemployee-hierarchy2:")
with con.cursor() as cur:
    cur.execute("select * from employee_hierarchy2")
    for row in cur:
        print(str(row[1]), str(row[4]))
