import os
import snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

def get_private_key(asPEM=False):

    # read the private key from file (replace with your own path)
    p_file = os.path.join(os.path.expanduser('~'), ".ssh/id_rsa_demo")
    with open(p_file, "rb") as fkey:
        # decrypt with passphrase (set before as env var)
        passphrase = os.environ['SNOWSQL_PRIVATE_KEY_PASSPHRASE'].encode()

        p_key = serialization.load_pem_private_key(
            fkey.read(),
            password=passphrase,
            backend=default_backend())

    p_key_raw = p_key.private_bytes(
        encoding=serialization.Encoding.PEM if asPEM else serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption())
    
    return p_key, p_key_raw


# customize with your own user name and account locator
current_user = "cscutaru"
_, p_key_raw = get_private_key()
ctx = snowflake.connector.connect(
    user=current_user,
    account="XLB86271",
    role="ACCOUNTADMIN",
    private_key=p_key_raw)

# display all RSA_ user parameters
query = f"describe user {current_user}"
rows = ctx.cursor().execute(query).fetchall()
for row in rows:
    if str(row[0]).startswith('RSA_'):
        print(str(row[0]), str(row[1]))
