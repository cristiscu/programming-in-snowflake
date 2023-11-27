var snowflake = require('snowflake-sdk');

var conn = snowflake.createConnection({
    account: "XLB86271",
    username: "cscutaru",
    password: process.env.SNOWSQL_PWD,
    database: "EMPLOYEES",
    schema: "PUBLIC"
});

conn.connect(
    function(err) {
        if (err) console.error('Unable to connect: ' + err.message);
        else console.log('Successfully connected to Snowflake.');
    }
);

conn.execute({
    sqlText: "select name, path from employee_hierarchy order by path",
    streamResult: true,
    complete: function (err, stmt) {
      var stream = stmt.streamRows();
      stream.on('readable', function (row) {
        while ((row = this.read()) !== null)
          console.log(row);
      })
      .on('end', () => console.log('Done.'))
      .on('error', (err) => console.log(err));
    }
});