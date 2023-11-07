import os, jwt, base64, hashlib
from datetime import timedelta, timezone, datetime
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

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

qualified_username = "IKOTKAI.YDB73888.CRISTISCU"
payload = {
    "iss": qualified_username + '.' + public_key_fp,
    "sub": qualified_username,
    "iat": datetime.now(timezone.utc),
    "exp": datetime.now(timezone.utc) + timedelta(minutes=59)}

encoding_algorithm = "RS256"
token = jwt.encode(
    payload,
    key=p_key,
    algorithm=encoding_algorithm)
#if isinstance(token, bytes):
#    token = token.decode('utf-8')
print(token)

#decoded_token = jwt.decode(token,
#    key=private_key.public_key(),
#    algorithms=[encoding_algorithm])
#print(decoded_token)
