// You may run this in Visual Studio
using System;
using Snowflake.Data.Client;

namespace ConsoleApp
{
    internal class Program
    {
        static void Main()
        {
            var user = "cristiscu";
            var pwd = Environment.GetEnvironmentVariable("SNOWSQL_PWD");
            var connStr = $"account=BTB76003;user={user};password={pwd}";
            using (var conn = new SnowflakeDbConnection(connStr))
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "show parameters";
                    using (var reader = cmd.ExecuteReader())
                        while (reader.Read())
                            Console.WriteLine($"{reader[0]}={reader[1]}");
                }
                conn.Close();
            }
            Console.Read();
        }
    }
}
