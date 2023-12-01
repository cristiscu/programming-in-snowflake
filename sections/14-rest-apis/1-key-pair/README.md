# Configure Key Pair Authentication

1. In Windows, open PowerShell in your user folder, and run **`ssh-keygen -t rsa -b 2048 -m pkcs8 -f .\.ssh\id_rsa_demo`**

2. Save the pass phrase for your encrypted private key into an environment variable: **`set SNOWSQL_PRIVATE_KEY_PASSPHRASE="..."`**

3. Convert the public key to PKCS8 format with **`ssh-keygen -e -f .\.ssh\id_rsa_demo.pub -m pkcs8`**. Copy the returned value on screen, between BEGIN and END (must start with "MII"). 

4. Connect to Snowsight with basic authentication (username and password). Run the following command, after replacing <val> with the previously copied value: **`alter user cscutaru set rsa_public_key='<val>'`**

5. Run **`describe user cscutaru`** (replace with your own user name) and check that *RSA_PUBLIC_KEY*  - and *RSA_PUBLIC_KEY_FP* (fingerprint version) user parameters have both values now.

# Test Key Pair Authentication

Test first the new authentication with key pair using SnowSQL. Connect with **`snowsql -a XLB86271 -u cscutaru --private-key-path ./.ssh/id_rsa_demo`**. Then run the command **`describe user cscutaru`** (replace with your user name).

Run **`python key-pair-connect.py`** to check the same functionality from client Python code.

   * The code is using the Snowflake Python Connector (install with **`pip install snowflake-python-connector`**).
   * The get_private_key() function returns the private key, including its raw data.
   * The asPEM function argument can be set to True when you want to connect to Snowpipe REST API (later in this section).
   * An encrypted private key must read the SNOWSQL_PRIVATE_KEY_PASSPHRASE environment variable previously set.
   * Customize the file with your own path, user name, and account locator.

# Generate JWTs (JSON Web Tokens)

Most Snowflake REST APIs require key pair authentication, with the additional generation of a temporary JWT token. 

You may generate a JWT token with SnowSQL, running **`snowsql --generate-jwt --private-key-path ./.ssh/id_rsa_demo -a XLB86271 -u cscutaru`**
