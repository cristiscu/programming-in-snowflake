// You may run this in Visual Studio
using System;
using Snowflake.Data.Client;

namespace ConsoleApp
{
    internal class Program
    {
        static void Main()
        {
            // Snowflake Connector for .NET:
            // https://github.com/snowflakedb/snowflake-connector-net
            var pwd = Environment.GetEnvironmentVariable("SNOWSQL_PWD");
            var connStr = $"account=XLB86271;user=cscutaru;password={pwd};db=EMPLOYEES;schema=PUBLIC;";
            using (var conn = new SnowflakeDbConnection(connStr))
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "select name, path from employee_hierarchy order by path";
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                            Console.WriteLine($"{reader[0]}\t{reader[1]}");
                }
                conn.Close();
            }
            Console.Read();
        }
    }
}
