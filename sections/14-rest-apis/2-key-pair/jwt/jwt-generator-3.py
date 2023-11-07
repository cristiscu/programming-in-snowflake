# see https://github.com/snowflakedb/snowflake-ingest-python/blob/master/snowflake/ingest/utils/tokentools.py

import base64, hashlib, jwt
from datetime import timedelta, timezone, datetime
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.hazmat.primitives.serialization import PublicFormat
from cryptography.hazmat.backends import default_backend

def get_token(self):

    now = datetime.utcnow()
    #self.renew_time = now + self.renewal_delay

    public_key_fp = self.calculate_public_key_fingerprint(self.private_key)

    # Create our payload
    payload = {
        "iss": self.qualified_username + '.' + public_key_fp,
        "sub": self.qualified_username,
        "iat": now,
        "exp": now + timedelta(minutes=59)
    }

    # Regenerate the actual token
    self.token = jwt.encode(payload, self.private_key, algorithm=SecurityManager.ALGORITHM)

    return self.token.decode('utf-8') if isinstance(self.token, bytes) else self.token

def calculate_public_key_fingerprint(self, private_key: Text) -> Text:
    """
    Given a private key in pem format, return the public key fingerprint
    :param private_key: private key string
    :return: public key fingerprint
    """
    private_key = load_pem_private_key(private_key.encode(), None, default_backend())

    # get the raw bytes of public key
    public_key_raw = private_key.public_key().public_bytes(Encoding.DER, PublicFormat.SubjectPublicKeyInfo)

    # take sha256 on raw bytes and then do base64 encode
    sha256hash = hashlib.sha256()
    sha256hash.update(public_key_raw)

    public_key_fp = 'SHA256:' + base64.b64encode(sha256hash.digest()).decode('utf-8')

    return public_key_fp
