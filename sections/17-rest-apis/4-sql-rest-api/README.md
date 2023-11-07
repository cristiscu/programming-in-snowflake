# Snowflake SQL REST API

Here are the steps to issue a **SHOW PARAMETERS** SQL statement for the current user through a HTTP request to the Snowflake SQL REST API. We assume you already configured the required key pair authentication to Snowflake. We'll generate here a new JWT token with SnowSQL, and we'll pass it to the CURL command. The CURL command will issue a POST request, with additional configuration data from a **request-body.json** local file. When successful, the command returns a HTTP 200 OK code, followed by JSON results. Look for the "data" object array for the requested data.

1. Configure **key pair authentication** to Snowflake, as described before.

2. Generate a **JWT token** with SnowSQL, as described before. Example: **`snowsql --generate-jwt --private-key-path "C:/Users/crist/.ssh/id_rsa_demo" -a BTB76003 -u cristiscu`**. This will output something like:
```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJCVEI3NjAwMy5DUklTVElTQ1UuU0hBMjU2OjVIYmtsbHRtaGNFNTVObmFFZnJQSmN3eUtJOFlEQWdFRVNMTFdXNHkzbWc9Iiwic3ViIjoiQlRCNzYwMDMuQ1JJU1RJU0NVIiwiaWF0IjoxNjk5MzAxMzk5LCJleHAiOjE2OTkzODc3OTl9.dm0DX7EOzoWCLuZWjhsbfWSO66Qqvg-2FItbctACfRDjBMYrqtQgDGvz0gku4opviHudUBApLtcFkVIxosFrzHRbsGIM6Xv9cKVImQK40CodGViR3L1CrWWXYp_s572JCyd1kqMVbmEI_8xa4TtKWuE41pH44Ea7mXAOPeAoHsJXZpbodFFitUe7ozeKav9eaI4x94hw9NlRX-UJQTLQbk29tf9yoMJ1Pw6klK9wufsvI-0MgMGwNIeJ8pWLwvfVOETNBAeljeDcWlwPX7XwRdXx6Vb9hh3rbsbAXuy_oNew8h0r8U7WysxmVBvKaAdFzbhFEHlRnqSqwbwtJGkE2A
```

3. Create a **request-body.json** file with other connection parameters and your SQL statement:
```
{
    "warehouse": "COMPUTE_WH",
    "role": "ACCOUNTADMIN",
    "statement": "show parameters",
    "timeout": 60
}
```

4. From the same folder, send the POST request with **curl**, from the command line (in Windows here). Before running the command, replace **<jwt>** with the token previously generated:
```
curl -i -X POST `
    -H "Content-Type: application/json" `
    -H "Authorization: Bearer <jwt>" `
    -H "Accept: application/json" `
    -H "User-Agent: myApplicationName/1.0" `
    -H "X-Snowflake-Authorization-Token-Type: KEYPAIR_JWT" `
    -d "@request-body.json" `
    "https://BTB76003.snowflakecomputing.com/api/v2/statements"
```

5. Check the JSON response, which should contain all data if run successfully (in the "data" JSON array), something like:

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
  "data": [
    [
      "ABORT_DETACHED_QUERY",
      "false",
      "false",
      "",
      "If true, Snowflake will automatically abort queries when it detects that the client has disappeared.",
      "BOOLEAN"
    ],
    ...
    [
      "WEEK_OF_YEAR_POLICY",
      "0",
      "0",
      "",
      "Defines the policy of assigning weeks to years:\n0: the week needs to have 4 days in a given year;\n1: a week with January 1st always belongs to a given year.",
      "NUMBER"
    ],
    [
      "WEEK_START",
      "0",
      "0",
      "",
      "Defines the first day of the week:\n0: legacy Snowflake behavior; 1: Monday .. 7: Sunday.",
      "NUMBER"
    ]
  ],
  "code": "090001",
  "statementStatusUrl": "/api/v2/statements/01b027a0-0001-db84-003d-b087000b8daa?requestId=4ccb7432-c62b-4197-9ac3-915fe56547c8",
  "requestId": "4ccb7432-c62b-4197-9ac3-915fe56547c8",
  "sqlState": "00000",
  "statementHandle": "01b027a0-0001-db84-003d-b087000b8daa",
  "message": "Statement executed successfully.",
  "createdOn": 1699301768333
}
```
