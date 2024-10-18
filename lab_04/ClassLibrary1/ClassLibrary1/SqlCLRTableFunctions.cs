using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace ClassLibrary1
{
    // СПИСОК ИГР С КАТЕГОРИЕЙ
    public class SqlCLRTableFunctions
    {
        [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read, FillRowMethodName = "FillRow", TableDefinition = "GameID INT, Title NVARCHAR(255), Price DECIMAL(10,2)")]
        public static IEnumerable GetGamesByCategory(SqlString category)
        {
            List<object[]> results = new List<object[]>();

            using (var connection = new SqlConnection("context connection=true")) // Используем контекстное подключение
            {
                connection.Open();
                using (var command = new SqlCommand("SELECT GameID, Title, Price FROM Games INNER JOIN Categories ON Games.CategoryID = Categories.CategoryID WHERE Categories.CategoryName = @CategoryName", connection))
                {
                    command.Parameters.AddWithValue("@CategoryName", category);
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            results.Add(new object[] { reader.GetInt32(0), reader.GetString(1), reader.GetDecimal(2) });
                        }
                    }
                }
            }

            return results;
        }

        public static void FillRow(object row, out int gameID, out string title, out decimal price)
        {
            object[] values = (object[])row;
            gameID = (int)values[0];
            title = (string)values[1];
            price = (decimal)values[2];
        }
    }
}
