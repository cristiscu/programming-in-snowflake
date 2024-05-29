# Pass a JWT token to CURL, to run SELECT CURRENT_ROLE() query
# Run with: .\run-query.ps1
# Look for "data" : [ ["ACCOUNTADMIN"] ] in the long JSON response

$jwt = ((snowsql --generate-jwt `
  --private-key-path "$env:USERPROFILE/.ssh/id_rsa_demo" `
  -a XLB86271 `
  -u cscutaru) | Out-String).TrimEnd()

Invoke-Expression ("curl.exe -i -X POST" +
  " -H 'Content-Type: application/json'" +
  " -H 'Authorization: Bearer $jwt'" +
  " -H 'Accept: application/json'" +
  " -H 'User-Agent: myApplicationName/1.0'" +
  " -H 'X-Snowflake-Authorization-Token-Type: KEYPAIR_JWT'" +
  " -d '{ `"statement`": `"select current_role()`" }' " +
  " 'https://XLB86271.snowflakecomputing.com/api/v2/statements'")

