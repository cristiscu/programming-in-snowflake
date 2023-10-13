import os, snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

# replace with your path
p_file = "C:/Users/crist/.ssh/id_rsa_demo"

# set before as env var
passphrase = os.environ['SNOWSQL_PRIVATE_KEY_PASSPHRASE'].encode()

# read the private key from file (and decrypt with passphrase)
with open(p_file, "rb") as key:
    p_key = serialization.load_pem_private_key(
        key.read(),
        password=passphrase,
        backend=default_backend())

pkb = p_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption())

# customize with your own user name and account locator
current_user = "cristiscu"
account_locator = "BTB76003"
ctx = snowflake.connector.connect(
    user=current_user,
    account=account_locator,
    role="ACCOUNTADMIN",
    private_key=pkb)

# display all RSA_ user parameters
query = f"describe user {current_user}"
rows = ctx.cursor().execute(query).fetchall()
for row in rows:
    if str(row[0]).startswith('RSA_'):
        print(str(row[0]), str(row[1]))
