# Snowflake SQL REST API

Here are the steps to issue a **SELECT CURRENT_ROLE()** SQL statement through a HTTP request to the Snowflake SQL REST API. We assume you already configured the required key pair authentication to Snowflake. We'll generate here a new JWT token with SnowSQL, and we'll pass it to the CURL command. The CURL command will issue a POST request. When successful, the command returns a HTTP 200 OK code, followed by JSON results. Look for the "data" object array for the requested data.

1. Configure **key pair authentication** to Snowflake, as described before. Then generate a **JWT token** with SnowSQL. Save it into a PowerShell variable.

2. Send a POST request with **curl**, from the command line (in Windows here). Before running the command, replace **<jwt>** with the JWT token previously generated:
```
curl -i -X POST `
    -H "Content-Type: application/json" `
    -H "Authorization: Bearer <jwt>" `
    -H "Accept: application/json" `
    -H "User-Agent: myApplicationName/1.0" `
    -H "X-Snowflake-Authorization-Token-Type: KEYPAIR_JWT" `
    -d '{ "statement": "select current_role()" }' `
    "https://XLB86271.snowflakecomputing.com/api/v2/statements"
```

3. Check the JSON response, which should contain all data if run successfully (in the "data" JSON array), something like:

```
HTTP/1.1 200 OK
Content-Type: application/json
Date: Mon, 06 Nov 2023 20:16:08 GMT
Expect-CT: enforce, max-age=3600
Link: </api/v2/statements/01b027a0-0001-db84-003d-b087000b8daa?requestId=bbc56b6b-1708-4a59-b424-66126896ce9e&partition=0>; rel="first",</api/v2/statements/01b027a0-0001-db84-003d-b087000b8daa?requestId=3f9830f4-84dd-4df5-940f-f4c8102d2023&partition=0>; rel="last"
Strict-Transport-Security: max-age=31536000
Vary: Accept-Encoding, User-Agent
X-Content-Type-Options: nosniff
X-Country: Canada
X-Frame-Options: deny
X-XSS-Protection: 1; mode=block
Content-Length: 16666
Connection: keep-alive

{
  "resultSetMetaData": {
    "numRows": 91,
    "format": "jsonv2",
    "partitionInfo": [
      {
        "rowCount": 91,
        "uncompressedSize": 14425
      }
    ],
    "rowType": [
      {
        "name": "key",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      },
      {
        "name": "value",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      },
      {
        "name": "default",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      },
      {
        "name": "level",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      },
      {
        "name": "description",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      },
      {
        "name": "type",
        "database": "",
        "schema": "",
        "table": "",
        "nullable": true,
        "scale": null,
        "collation": null,
        "precision": null,
        "byteLength": 16777216,
        "length": 16777216,
        "type": "text"
      }
    ]
  },
  "data" : [ ["ACCOUNTADMIN"] ],
  "code": "090001",
  "statementStatusUrl": "/api/v2/statements/01b027a0-0001-db84-003d-b087000b8daa?requestId=4ccb7432-c62b-4197-9ac3-915fe56547c8",
  "requestId": "4ccb7432-c62b-4197-9ac3-915fe56547c8",
  "sqlState": "00000",
  "statementHandle": "01b027a0-0001-db84-003d-b087000b8daa",
  "message": "Statement executed successfully.",
  "createdOn": 1699301768333
}
```
