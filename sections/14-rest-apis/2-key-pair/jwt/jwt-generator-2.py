# see https://medium.com/snowflake/invoking-the-snowpipe-rest-api-from-postman-141070a55337

import os, jwt, base64, hashlib
from datetime import timedelta, datetime
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

def get_private_key(asPEM=False):

    # read the private key from file (replace with your own path)
    p_file = "C:/Users/crist/.ssh/id_rsa_demo"
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


p_key, p_key_raw = get_private_key()

sha256hash = hashlib.sha256()
sha256hash.update(p_key_raw)
public_key_fp = 'SHA256:' + base64.b64encode(sha256hash.digest()).decode('utf-8')

payload = { 
    "iss": "BTB76003.CRISTISCU", # + '.' + public_key_fp,
    # "sub": "IKOTKAI.YDB73888.CRISTISCU",
    "iat": int(datetime.utcnow().timestamp()),
    "exp": int(datetime.utcnow().timestamp()) + timedelta(minutes=59).total_seconds()}
encoded_jwt = jwt.encode(
    payload,
    p_key,
    algorithm='RS256')
print(encoded_jwt)