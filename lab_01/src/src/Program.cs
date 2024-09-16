using System;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Xml.Linq;
using Faker;

namespace src
{
    internal class Program
    {
        private static Random _random = new Random();
        static void Main(string[] args)
        {
            /*// Параметры подключения
            string connectionString = "Server=LAPTOP-7106M2BU;Database=GamingPlatform;Trusted_Connection=True;";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // Генерация CSV для таблицы Users
                using (StreamWriter writer = new StreamWriter("Users.csv"))
                {
                    writer.WriteLine("Username,Email,RegistrationDate,Country,AccountStatus");

                    for (int i = 0; i < 1000; i++)
                    {
                        string username = NameFaker.Name();
                        string email = GenerateUniqueEmail(connection);
                        DateTime registrationDate = DateTime.Now.AddDays(-_random.Next(0, 365));
                        string country = LocationFaker.Country();
                        bool accountStatus = _random.Next(0, 2) == 1;

                        writer.WriteLine($"{username},{email},{registrationDate.ToString("yyyy-MM-dd")},{country},{accountStatus}");
                    }
                }

                // Генерация CSV для таблицы Developers
                using (StreamWriter writer = new StreamWriter("Developers.csv"))
                {
                    writer.WriteLine("Name,Country,Founded,Website,EmployeeCount");

                    for (int i = 0; i < 1000; i++)
                    {
                        string name = CompanyFaker.Name();
                        string country = LocationFaker.Country();
                        DateTime founded = DateTime.Now.AddYears(-_random.Next(1, 50));
                        string website = InternetFaker.Domain();
                        int employeeCount = _random.Next(1, 1000);

                        writer.WriteLine($"{name},{country},{founded.ToString("yyyy-MM-dd")},{website},{employeeCount}");
                    }
                }

                // Генерация CSV для таблицы Games
                var developerIds = GetAllDeveloperIds(connection);
                using (StreamWriter writer = new StreamWriter("Games.csv"))
                {
                    writer.WriteLine("Title,ReleaseDate,Genre,DeveloperID,MinSystemRequirements");

                    for (int i = 0; i < 1000; i++)
                    {
                        string title = $"Game-{i}";
                        DateTime releaseDate = DateTime.Now.AddYears(-_random.Next(1, 10));
                        string genre = _random.Next(1, 4) switch
                        {
                            1 => "Action",
                            2 => "Adventure",
                            3 => "Strategy",
                            _ => "Unknown"
                        };
                        int developerID = developerIds[_random.Next(0, developerIds.Count)];
                        string minSystemRequirements = "CPU: 2GHz, RAM: 4GB, HDD: 20GB";

                        writer.WriteLine($"{title},{releaseDate.ToString("yyyy-MM-dd")},{genre},{developerID},{minSystemRequirements}");
                    }
                }

                // Генерация CSV для таблицы Reviews
                var userIds = GetAllUserIds(connection);
                var gameDeveloperMapping = GetGameDeveloperMapping(connection);
                using (StreamWriter writer = new StreamWriter("Reviews.csv"))
                {
                    writer.WriteLine("UserID,GameID,DeveloperID,ReviewText,GameRating,HoursPlayed,ReviewDate");

                    for (int i = 0; i < 1000; i++)
                    {
                        int userID = userIds[_random.Next(0, userIds.Count)];
                        int gameID = gameDeveloperMapping.Keys.ElementAt(_random.Next(0, gameDeveloperMapping.Count));
                        int developerID = gameDeveloperMapping[gameID];
                        string reviewText = _random.Next(1, 4) switch
                        {
                            1 => "Amazing Graphics!",
                            2 => "This is so fun to play!",
                            3 => "OK",
                            _ => "Unknown"
                        };
                        int gameRating = _random.Next(1, 11);
                        int hoursPlayed = _random.Next(1, 100);
                        DateTime reviewDate = DateTime.Now.AddDays(-_random.Next(0, 365));

                        writer.WriteLine($"{userID},{gameID},{developerID},{reviewText},{gameRating},{hoursPlayed},{reviewDate.ToString("yyyy-MM-dd")}");
                    }
                }
            }

            Console.WriteLine("CSV файлы успешно сгенерированы.");

            
            return;*/
            // Параметры подключения
            string connectionString = "Server=LAPTOP-7106M2BU;Database=GamingPlatform;Trusted_Connection=True;";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // Генерация данных для таблицы Users
                for (int i = 0; i < 1000; i++)
                {
                    string username = NameFaker.Name();
                    string email = GenerateUniqueEmail(connection);
                    DateTime registrationDate = DateTime.Now.AddDays(-_random.Next(0, 365));
                    string country = LocationFaker.Country();
                    bool accountStatus = _random.Next(0, 2) == 1;

                    string insertUserQuery = "INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus) " +
                                              "VALUES (@Username, @Email, @RegistrationDate, @Country, @AccountStatus)";

                    using (SqlCommand command = new SqlCommand(insertUserQuery, connection))
                    {
                        command.Parameters.AddWithValue("@Username", username);
                        command.Parameters.AddWithValue("@Email", email);
                        command.Parameters.AddWithValue("@RegistrationDate", registrationDate);
                        command.Parameters.AddWithValue("@Country", country);
                        command.Parameters.AddWithValue("@AccountStatus", accountStatus);

                        command.ExecuteNonQuery();
                    }
                }

                // Генерация данных для таблицы Developers
                for (int i = 0; i < 1000; i++)
                {
                    string name = CompanyFaker.Name();
                    string country = LocationFaker.Country();
                    DateTime founded = DateTime.Now.AddYears(-_random.Next(1, 50));
                    string website = InternetFaker.Domain();
                    int employeeCount = _random.Next(1, 1000);

                    string insertDeveloperQuery = "INSERT INTO Developers (Name, Country, Founded, Website, EmployeeCount) " +
                                                   "VALUES (@Name, @Country, @Founded, @Website, @EmployeeCount)";

                    using (SqlCommand command = new SqlCommand(insertDeveloperQuery, connection))
                    {
                        command.Parameters.AddWithValue("@Name", name);
                        command.Parameters.AddWithValue("@Country", country);
                        command.Parameters.AddWithValue("@Founded", founded);
                        command.Parameters.AddWithValue("@Website", website);
                        command.Parameters.AddWithValue("@EmployeeCount", employeeCount);

                        command.ExecuteNonQuery();
                    }
                }

                // Генерация данных для таблицы Games
                // Необходимо сначала получить DeveloperID из таблицы Developers
                var developerIds = GetAllDeveloperIds(connection);

                for (int i = 0; i < 1000; i++)
                {
                    string title = $"Game-{i}";
                    DateTime releaseDate = DateTime.Now.AddYears(-_random.Next(1, 10));
                    string genre = _random.Next(1, 4) switch
                    {
                        1 => "Action",
                        2 => "Adventure",
                        3 => "Strategy",
                        _ => "Unknown"
                    };
                    int developerID = developerIds[_random.Next(0, developerIds.Count)];

                    string minSystemRequirements = "CPU: 2GHz, RAM: 4GB, HDD: 20GB";

                    string insertGameQuery = "INSERT INTO Games (Title, ReleaseDate, Genre, DeveloperID, MinSystemRequirements) " +
                                              "VALUES (@Title, @ReleaseDate, @Genre, @DeveloperID, @MinSystemRequirements)";

                    using (SqlCommand command = new SqlCommand(insertGameQuery, connection))
                    {
                        command.Parameters.AddWithValue("@Title", title);
                        command.Parameters.AddWithValue("@ReleaseDate", releaseDate);
                        command.Parameters.AddWithValue("@Genre", genre);
                        command.Parameters.AddWithValue("@DeveloperID", developerID);
                        command.Parameters.AddWithValue("@MinSystemRequirements", minSystemRequirements);

                        command.ExecuteNonQuery();
                    }
                }

                // Генерация данных для таблицы Reviews
                // Необходимо сначала получить UserID и GameID из таблиц Users и Games
                var userIds = GetAllUserIds(connection);
                var gameDeveloperMapping = GetGameDeveloperMapping(connection);

                for (int i = 0; i < 1000; i++)
                {
                    int userID = userIds[_random.Next(0, userIds.Count)];
                    int gameID = gameDeveloperMapping.Keys.ElementAt(_random.Next(0, gameDeveloperMapping.Count));
                    int developerID = gameDeveloperMapping[gameID];
                    string reviewText = _random.Next(1, 4) switch
                    {
                        1 => "Amazing Graphics!",
                        2 => "This is so fun to play!",
                        3 => "OK",
                        _ => "Unknown"
                    };
                    int gameRating = _random.Next(1, 11);
                    int hoursPlayed = _random.Next(1, 100);
                    DateTime reviewDate = DateTime.Now.AddDays(-_random.Next(0, 365));

                    string insertReviewQuery = "INSERT INTO Reviews (UserID, GameID, DeveloperID, ReviewText, GameRating) " +
                                                "VALUES (@UserID, @GameID, @DeveloperID, @ReviewText, @GameRating)";

                    using (SqlCommand command = new SqlCommand(insertReviewQuery, connection))
                    {
                        command.Parameters.AddWithValue("@UserID", userID);
                        command.Parameters.AddWithValue("@GameID", gameID);
                        command.Parameters.AddWithValue("@DeveloperID", developerID);
                        command.Parameters.AddWithValue("@ReviewText", reviewText);
                        command.Parameters.AddWithValue("@GameRating", gameRating);
                        command.Parameters.AddWithValue("@HoursPlayed", hoursPlayed);
                        command.Parameters.AddWithValue("@ReviewDate", reviewDate);

                        command.ExecuteNonQuery();
                    }
                }

                Console.WriteLine("Тестовые данные успешно добавлены в базу данных.");
            }
        }

        // Метод для получения всех GameID и соответствующих DeveloperID
        static Dictionary<int, int> GetGameDeveloperMapping(SqlConnection connection)
        {
            var gameDeveloperMapping = new Dictionary<int, int>();
            var query = "SELECT GameID, DeveloperID FROM Games";

            using (SqlCommand command = new SqlCommand(query, connection))
            using (SqlDataReader reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    gameDeveloperMapping[reader.GetInt32(0)] = reader.GetInt32(1);
                }
            }

            return gameDeveloperMapping;
        }

        private static bool EmailExists(SqlConnection connection, string email)
        {
            string query = "SELECT COUNT(1) FROM Users WHERE Email = @Email";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                command.Parameters.AddWithValue("@Email", email);
                return (int)command.ExecuteScalar() > 0;
            }
        }
        private static string GenerateUniqueEmail(SqlConnection connection)
        {
            string email;
            do
            {
                email = InternetFaker.Email();
            } while (EmailExists(connection, email));
            return email;
        }

        private static List<int> GetAllUserIds(SqlConnection connection)
        {
            List<int> userIds = new List<int>();

            string query = "SELECT UserID FROM Users";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        userIds.Add(reader.GetInt32(0));
                    }
                }
            }

            return userIds;
        }

        private static List<int> GetAllGameIds(SqlConnection connection)
        {
            List<int> gameIds = new List<int>();

            string query = "SELECT GameID FROM Games";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        gameIds.Add(reader.GetInt32(0));
                    }
                }
            }

            return gameIds;
        }

        private static List<int> GetAllDeveloperIds(SqlConnection connection)
        {
            List<int> developerIds = new List<int>();

            string query = "SELECT DeveloperID FROM Developers";
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        developerIds.Add(reader.GetInt32(0));
                    }
                }
            }

            return developerIds;
        }

    }
}
