using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace ClassLibrary1
{
    public class SqlCLRProcedures
    {
        [SqlProcedure]
        public static void AddNewUser(SqlString username, SqlString email, SqlDateTime registrationDate, SqlString country, SqlBoolean accountStatus)
        {
            using (var connection = new SqlConnection("context connection=true"))
            {
                connection.Open();
                using (var command = new SqlCommand("INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus) VALUES (@Username, @Email, @RegistrationDate, @Country, @AccountStatus)", connection))
                {
                    command.Parameters.AddWithValue("@Username", username);
                    command.Parameters.AddWithValue("@Email", email);
                    command.Parameters.AddWithValue("@RegistrationDate", registrationDate);
                    command.Parameters.AddWithValue("@Country", country);
                    command.Parameters.AddWithValue("@AccountStatus", accountStatus);
                    command.ExecuteNonQuery();
                }
            }
        }
    }
}
