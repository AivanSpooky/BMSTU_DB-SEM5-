using System.Data;
using System.Data.SqlClient;

namespace ConsoleAppWithDB
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Database.Instance.ConnectionString = @"Data Source=LAPTOP-7106M2BU;Initial Catalog=GamingPlatform;Integrated Security=True";

            while (true)
            {
                Console.Clear();
                Console.WriteLine("=== GamingPlatform ===");
                Console.WriteLine("1. Выполнить скалярный запрос");
                Console.WriteLine("2. Выполнить запрос с несколькими соединениями (JOIN)");
                Console.WriteLine("3. Выполнить запрос с CTE и оконными функциями");
                Console.WriteLine("4. Выполнить запрос к метаданным");
                Console.WriteLine("5. Вызвать скалярную функцию");
                Console.WriteLine("6. Вызвать табличную функцию");
                Console.WriteLine("7. Вызвать хранимую процедуру");
                Console.WriteLine("8. Вызвать системную функцию или процедуру");
                Console.WriteLine("9. Создать новую таблицу");
                Console.WriteLine("10. Вставить данные в таблицу");
                Console.WriteLine("0. Выход");
                Console.Write("Выберите опцию: ");

                string input = Console.ReadLine();

                if (input == "0")
                    break;

                switch (input)
                {
                    case "1":
                        ExecuteScalarQuery();
                        break;
                    case "2":
                        ExecuteJoinQuery();
                        break;
                    case "3":
                        ExecuteCteWindowFunctionQuery();
                        break;
                    case "4":
                        ExecuteMetadataQuery();
                        break;
                    case "5":
                        CallScalarFunction();
                        break;
                    case "6":
                        CallTableValuedFunction();
                        break;
                    case "7":
                        CallStoredProcedure();
                        break;
                    case "8":
                        CallSystemFunction();
                        break;
                    case "9":
                        CreateNewTable();
                        break;
                    case "del":
                        DeleteDiscountsTable();
                        break;
                    case "10":
                        InsertDataIntoTable();
                        break;
                    default:
                        Console.WriteLine("Неверная опция. Нажмите любую клавишу для продолжения...");
                        Console.ReadKey();
                        break;
                }
            }
        }

        // 1. Выполнить скалярный запрос
        static void ExecuteScalarQuery()
        {
            Console.Clear();
            Console.WriteLine("Выполнение скалярного запроса...");
            try
            {
                string query = "SELECT COUNT(*) FROM Users";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    int count = (int)cmd.ExecuteScalar();
                    Console.WriteLine($"Общее количество пользователей: {count}");
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 2. Выполнить запрос с несколькими соединениями (JOIN)
        static void ExecuteJoinQuery()
        {
            Console.Clear();
            Console.WriteLine("Выполнение запроса с несколькими JOIN...");
            try
            {
                string query = @"
                SELECT u.Username, g.Title, o.OrderDate
                FROM Orders o
                INNER JOIN Users u ON o.UserID = u.UserID
                INNER JOIN Games g ON o.GameID = g.GameID
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine($"{"Пользователь",-30}\t{"Игра",-20}\t{"Дата заказа",-10}");
                        Console.WriteLine($"{"============",-30}\t{"====",-20}\t{"===========",-10}");
                        while (reader.Read())
                        {
                            Console.WriteLine($"{reader["Username"],-30}\t{reader["Title"],-20}\t{reader["OrderDate"],-10}");
                        }
                    }
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 3. Выполнить запрос с CTE и оконными функциями
        static void ExecuteCteWindowFunctionQuery()
        {
            Console.Clear();
            Console.WriteLine("Выполнение запроса с CTE и оконными функциями...");
            try
            {
                string query = @"
                WITH UserOrderTotals AS (
                    SELECT UserID, SUM(Price * Quantity) AS TotalSpent
                    FROM Orders
                    GROUP BY UserID
                )
                SELECT UserID, TotalSpent, RANK() OVER (ORDER BY TotalSpent DESC) AS SpendingRank
                FROM UserOrderTotals
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine($"{"UserID",-15}\t{"TotalSpent",-15}\t{"SpendingRank",-15}");
                        Console.WriteLine($"{"======",-15}\t{"==========",-15}\t{"============",-15}");
                        while (reader.Read())
                        {
                            Console.WriteLine($"{reader["UserID"],-15}\t{reader["TotalSpent"],-15}\t{reader["SpendingRank"],-15}");
                        }
                    }
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 4. Выполнить запрос к метаданным
        static void ExecuteMetadataQuery()
        {
            Console.Clear();
            Console.WriteLine("Выполнение запроса к метаданным...");
            try
            {
                string query = @"
                SELECT TABLE_NAME
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = 'GamingPlatform'
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine("Таблицы в базе данных:");
                        while (reader.Read())
                        {
                            Console.WriteLine($"{reader["TABLE_NAME"]}");
                        }
                    }
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 5. Вызвать скалярную функцию
        static void CallScalarFunction()
        {
            Console.Clear();
            Console.WriteLine("Вызов скалярной функции dbo.GetUserRegistrationDays...");
            try
            {
                Console.Write("Введите UserID: ");
                int userId = int.Parse(Console.ReadLine());

                string query = "SELECT dbo.GetUserRegistrationDays(@UserID) AS RegistrationDays";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    Database.Instance.OpenConnection();
                    var result = cmd.ExecuteScalar();
                    Console.WriteLine($"Количество дней с регистрации пользователя {userId}: {result}");
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 6. Вызвать табличную функцию
        static void CallTableValuedFunction()
        {
            Console.Clear();
            Console.WriteLine("Вызов табличной функции dbo.GetGamesByCategory...");
            try
            {
                Console.Write("Введите название категории: ");
                string categoryName = Console.ReadLine();

                string query = "SELECT * FROM dbo.GetGamesByCategory(@CategoryName)";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    cmd.Parameters.AddWithValue("@CategoryName", categoryName);
                    Database.Instance.OpenConnection();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        Console.WriteLine($"{"GameID",-10}\t{"Title",-10}\t{"ReleaseDate",-20}\t{"Price",-10}");
                        Console.WriteLine($"{"======",-10}\t{"=====",-10}\t{"===========",-20}\t{"=====",-10}");
                        while (reader.Read())
                        {
                            Console.WriteLine($"{reader["GameID"],-10}\t{reader["Title"],-10}\t{reader["ReleaseDate"],-20}\t{reader["Price"],-10}");
                        }
                    }
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 7. Вызвать хранимую процедуру
        static void CallStoredProcedure()
        {
            Console.Clear();
            Console.WriteLine("Вызов хранимой процедуры dbo.AddNewUser...");
            try
            {
                Console.Write("Введите Username: ");
                string username = Console.ReadLine();

                Console.Write("Введите Email: ");
                string email = Console.ReadLine();

                Console.Write("Введите RegistrationDate (yyyy-mm-dd): ");
                DateTime registrationDate = DateTime.Parse(Console.ReadLine());

                Console.Write("Введите Country: ");
                string country = Console.ReadLine();

                Console.Write("Введите AccountStatus (0 или 1): ");
                bool accountStatus = Console.ReadLine() == "1";

                using (SqlCommand cmd = new SqlCommand("dbo.AddNewUser", Database.Instance.Connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@RegistrationDate", registrationDate);
                    cmd.Parameters.AddWithValue("@Country", country);
                    cmd.Parameters.AddWithValue("@AccountStatus", accountStatus);

                    Database.Instance.OpenConnection();
                    cmd.ExecuteNonQuery();
                    Database.Instance.CloseConnection();

                    Console.WriteLine("Пользователь успешно добавлен.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
                Database.Instance.CloseConnection();
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 8. Вызвать системную функцию или процедуру
        static void CallSystemFunction()
        {
            Console.Clear();
            Console.WriteLine("Вызов системной функции @@VERSION...");
            try
            {
                string query = "SELECT @@VERSION";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    string version = (string)cmd.ExecuteScalar();
                    Console.WriteLine($"Версия SQL Server:\n{version}");
                    Database.Instance.CloseConnection();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 9. Создать новую таблицу
        static void CreateNewTable()
        {
            Console.Clear();
            Console.WriteLine("Создание новой таблицы...");
            try
            {
                string query = @"
                DROP TABLE IF EXISTS Discounts;
                CREATE TABLE Discounts (
                    DiscountID INT IDENTITY(1,1) PRIMARY KEY,
                    DiscountName NVARCHAR(100) NOT NULL,
                    DiscountPercent DECIMAL(5, 2) NOT NULL,
                    StartDate DATE NOT NULL,
                    EndDate DATE NOT NULL,
                    CONSTRAINT CK_Discounts_EndDate CHECK (EndDate > StartDate),
                    CONSTRAINT CK_Discounts_Percentage CHECK (DiscountPercent < 100 AND DiscountPercent > 0)
                )
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    cmd.ExecuteNonQuery();
                    Database.Instance.CloseConnection();
                    Console.WriteLine("Таблица Discounts успешно создана.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }
        // del. Удалить новую таблицу
        static void DeleteDiscountsTable()
        {
            Console.Clear();
            Console.WriteLine("Удаление таблицы Discounts...");
            try
            {
                string query = @"
                DROP TABLE IF EXISTS Discounts;
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    Database.Instance.OpenConnection();
                    cmd.ExecuteNonQuery();
                    Database.Instance.CloseConnection();
                    Console.WriteLine("Таблица Discounts успешно удалена.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при удалении таблицы: {ex.Message}");
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }

        // 10. Вставить данные в таблицу
        static void InsertDataIntoTable()
        {
            Console.Clear();
            Console.WriteLine("Вставка данных в таблицу Discounts...");
            try
            {
                Console.Write("Введите название скидки: ");
                string discountName = Console.ReadLine();

                Console.Write("Введите процент скидки: ");
                decimal discountPercent = decimal.Parse(Console.ReadLine());

                Console.Write("Введите дату начала (yyyy-mm-dd): ");
                DateTime startDate = DateTime.Parse(Console.ReadLine());

                Console.Write("Введите дату окончания (yyyy-mm-dd): ");
                DateTime endDate = DateTime.Parse(Console.ReadLine());

                string query = @"
                INSERT INTO Discounts (DiscountName, DiscountPercent, StartDate, EndDate)
                VALUES (@DiscountName, @DiscountPercent, @StartDate, @EndDate)
                ";

                using (SqlCommand cmd = new SqlCommand(query, Database.Instance.Connection))
                {
                    cmd.Parameters.AddWithValue("@DiscountName", discountName);
                    cmd.Parameters.AddWithValue("@DiscountPercent", discountPercent);
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);

                    Database.Instance.OpenConnection();
                    cmd.ExecuteNonQuery();
                    Database.Instance.CloseConnection();

                    Console.WriteLine("Данные успешно вставлены в таблицу Discounts.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка: {ex.Message}");
            }
            Console.WriteLine("Нажмите любую клавишу для возврата в меню...");
            Console.ReadKey();
        }
    }

    // Singleton
    public sealed class Database
    {
        private static readonly Lazy<Database> instance = new Lazy<Database>(() => new Database());
        public static Database Instance => instance.Value;

        private SqlConnection connection;
        public SqlConnection Connection => connection;

        public string ConnectionString { get; set; }

        private Database()
        {
            connection = new SqlConnection();
        }

        public void OpenConnection()
        {
            if (connection.State != ConnectionState.Open)
            {
                connection.ConnectionString = ConnectionString;
                connection.Open();
            }
        }

        public void CloseConnection()
        {
            if (connection.State != ConnectionState.Closed)
            {
                connection.Close();
            }
        }
    }
}
