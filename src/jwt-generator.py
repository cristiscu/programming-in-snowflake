from datetime import timedelta, timezone, datetime
import os, jwt, base64, hashlib
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

p_file = "C:/Users/crist/.ssh/id_rsa_demo"
passphrase = os.environ['SNOWSQL_PRIVATE_KEY_PASSPHRASE'].encode()

with open(p_file, "rb") as key:
    private_key = serialization.load_pem_private_key(
        key.read(),
        password=passphrase,
        backend=default_backend())

public_key_raw = private_key.public_key().public_bytes(
    serialization.Encoding.DER, 
    serialization.PublicFormat.SubjectPublicKeyInfo)

sha256hash = hashlib.sha256()
sha256hash.update(public_key_raw)

public_key_fp = 'SHA256:' + base64.b64encode(sha256hash.digest()).decode('utf-8')

qualified_username = "IKOTKAI.YDB73888.CRISTISCU"
payload = {
    "iss": qualified_username + '.' + public_key_fp,
    "sub": qualified_username,
    "iat": datetime.now(timezone.utc),
    "exp": datetime.now(timezone.utc) + timedelta(minutes=59)
}

encoding_algorithm = "RS256"
token = jwt.encode(payload,
    key=private_key,
    algorithm=encoding_algorithm)
#if isinstance(token, bytes):
#    token = token.decode('utf-8')
print(token)

#decoded_token = jwt.decode(token,
#    key=private_key.public_key(),
#    algorithms=[encoding_algorithm])
#print(decoded_token)
