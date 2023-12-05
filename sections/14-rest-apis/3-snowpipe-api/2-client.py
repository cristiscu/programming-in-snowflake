import time, datetime, os
from datetime import timedelta
from requests import HTTPError
import logging
from logging import getLogger
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from snowflake.ingest import SimpleIngestManager, StagedFile

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

def ingest_files(manager: SimpleIngestManager, files):

    global logger

    try:
        staged_files = [StagedFile(file, None) for file in files]
        resp = manager.ingest_files(staged_files)
    except HTTPError as e:
        logger.error(e)
        exit(1)

    assert(resp['responseCode'] == 'SUCCESS')

def show_reports(manager: SimpleIngestManager):

    # break after both staged file(s) loaded
    while True:
        resp = manager.get_history()
        print('\nIngest Report:', resp)
        if len(resp['files']) >= 2: break
        else: time.sleep(10)    # try again after 10 seconds

    # show history report for the past hour
    date = datetime.datetime.utcnow() - timedelta(hours=1)
    resp = manager.get_history_range(date.isoformat() + 'Z')
    print('\nHistory scan report:', resp)


logging.basicConfig(filename='tmp/ingest.log', level=logging.DEBUG)
logger = getLogger(__name__)

_, p_key_raw = get_private_key(True)
manager = SimpleIngestManager(
    account="XLB86271",
    host='XLB86271.snowflakecomputing.com',
    user="cscutaru",
    pipe='EMPLOYEES.PUBLIC.MYPIPE',
    private_key=p_key_raw.decode('utf-8'))

# after manually loading files in @mystage_pipe!
ingest_files(manager, ['emp11.csv', 'emp12.csv'])

show_reports(manager)
