# Generates JWT token, passed to the CURL command to run the SQL statement from request-body.json
# Run with: .\run-query.ps1

$jwt = (snowsql --generate-jwt --private-key-path "C:/Users/crist/.ssh/id_rsa_demo" -a BTB76003 -u cristiscu) | Out-String
$jwt = $jwt.TrimEnd()
Invoke-Expression "curl -i -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer $jwt' -H 'Accept: application/json' -H 'User-Agent: myApplicationName/1.0' -H 'X-Snowflake-Authorization-Token-Type: KEYPAIR_JWT' -d '@request-body.json' 'https://BTB76003.snowflakecomputing.com/api/v2/statements'"

<# 
Example output (partial result)
===============================

HTTP/1.1 200 OK
Content-Type: application/json
Date: Wed, 08 Nov 2023 18:45:06 GMT
Expect-CT: enforce, max-age=3600
Link: </api/v2/statements/01b03285-0001-dea1-003d-b087000ca9be?requestId=25cf7f70-52ae-42e2-891f-70881ff904fb&partition=0>; rel="first",</api/v2/statements/01b03285-0001-dea1-003d-b087000ca9be?requestId=a96c7645-2577-4a8d-a49f-e821eeab7829&partition=0>; rel="last"
Strict-Transport-Security: max-age=31536000
Vary: Accept-Encoding, User-Agent
X-Content-Type-Options: nosniff
X-Country: Canada
X-Frame-Options: deny
X-XSS-Protection: 1; mode=block
transfer-encoding: chunked
Connection: keep-alive

{
  "resultSetMetaData" : {
    "numRows" : 91,
    "format" : "jsonv2",
    "partitionInfo" : [ {
      "rowCount" : 91,
      "uncompressedSize" : 14425
    } ],
    "rowType" : [ {
      "name" : "key",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    }, {
      "name" : "value",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    }, {
      "name" : "default",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    }, {
      "name" : "level",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    }, {
      "name" : "description",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    }, {
      "name" : "type",
      "database" : "",
      "schema" : "",
      "table" : "",
      "nullable" : true,
      "scale" : null,
      "collation" : null,
      "precision" : null,
      "byteLength" : 16777216,
      "length" : 16777216,
      "type" : "text"
    } ]
  },
  "data" : [
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
  "code" : "090001",
  "statementStatusUrl" : "/api/v2/statements/01b03285-0001-dea1-003d-b087000ca9be?requestId=43d57b3e-82ba-43a0-8053-13cdbbf16b76",
  "requestId" : "43d57b3e-82ba-43a0-8053-13cdbbf16b76",
  "sqlState" : "00000",
  "statementHandle" : "01b03285-0001-dea1-003d-b087000ca9be",
  "message" : "Statement executed successfully.",
  "createdOn" : 1699469106095
#>