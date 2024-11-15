using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StackExchange.Redis;
using Newtonsoft.Json;
using System.Timers;
using System.Diagnostics;
using OxyPlot;
using OxyPlot.Legends;
using OxyPlot.Series;
using OxyPlot.WindowsForms;
using OxyPlot.Axes;
using System.Windows.Forms;

namespace PerfComp
{
    internal class Program
    {
        static string sqlConnectionString = @"Data Source=LAPTOP-7106M2BU;Initial Catalog=GamingPlatform;Integrated Security=True;TrustServerCertificate=True";
        static ConnectionMultiplexer redis = ConnectionMultiplexer.Connect("localhost");
        static IDatabase redisDb = redis.GetDatabase();
        static string query = @"
            SELECT TOP 10
                G.Title,
                COUNT(O.OrderID) AS PurchaseCount
            FROM
                Orders O    
                INNER JOIN Games G ON O.GameID = G.GameID
            GROUP BY
                G.Title
            ORDER BY
                PurchaseCount DESC;";

        static async Task Main(string[] args)
        {
            var scenarios = new List<(string Name, Action ModifyAction)>
            {
                ("Без изменения данных", null),
                ("Добавление новых строк каждые 10 секунд", AddNewOrder),
                ("Удаление строк каждые 10 секунд", DeleteRandomOrder),
                ("Изменение строк каждые 10 секунд", UpdateRandomOrder),
            };

            foreach (var scenario in scenarios)
            {
                Console.WriteLine($"Запуск сценария: {scenario.Name}");
                await RunScenario(scenario.Name, scenario.ModifyAction);
                Console.WriteLine($"Сценарий '{scenario.Name}' завершен.");
                Console.WriteLine("Нажмите Enter для продолжения...");
                Console.ReadLine();
            }

            redis.Close();
            Console.WriteLine("Все сценарии завершены.");
        }

        static async Task RunScenario(string scenarioName, Action modifyAction)
        {
            List<double> dbTimes = new List<double>();
            List<double> cacheTimes = new List<double>();
            List<DateTime> timestamps = new List<DateTime>();

            System.Timers.Timer queryTimer = new System.Timers.Timer(5000); // 5 секунд
            System.Timers.Timer modifyTimer = new System.Timers.Timer(10000); // 10 секунд

            bool isRunning = true;

            async void QueryTimer_Elapsed(object sender, ElapsedEventArgs e)
            {
                if (!isRunning) return;

                // Запрос к БД
                var (_, dbTime) = FetchFromDatabase(sqlConnectionString, query);
                dbTimes.Add(dbTime.TotalMilliseconds);

                // Запрос через кэш
                var (_, cacheTime, source) = await FetchFromCacheAsync(redisDb, sqlConnectionString, query);
                cacheTimes.Add(cacheTime.TotalMilliseconds);

                // Временная метка
                timestamps.Add(DateTime.Now);
                Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] DB Time: {dbTime.TotalMilliseconds} ms, Cache Time: {cacheTime.TotalMilliseconds} ms (Source: {source})");
            }

            void ModifyTimer_Elapsed(object sender, ElapsedEventArgs e)
            {
                if (!isRunning) return;

                modifyAction?.Invoke();

                // Очистка кэша после изменения данных
                if (modifyAction != null)
                {
                    redisDb.KeyDelete("top_10_games");
                    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Data modified and cache cleared.");
                }
            }

            queryTimer.Elapsed += QueryTimer_Elapsed;
            modifyTimer.Elapsed += ModifyTimer_Elapsed;

            queryTimer.Start();
            if (modifyAction != null)
                modifyTimer.Start();

            Console.WriteLine($"Сценарий '{scenarioName}' запущен. Выполнение в течение 1 минуты...");
            await Task.Delay(TimeSpan.FromMinutes(1));

            isRunning = false;
            queryTimer.Stop();
            modifyTimer.Stop();

            // Построение графика
            PlotResults(dbTimes, cacheTimes, timestamps, scenarioName);
        }

        static (List<(string Title, int PurchaseCount)>, TimeSpan) FetchFromDatabase(string connectionString, string query)
        {
            List<(string Title, int PurchaseCount)> results = new List<(string, int)>();
            var stopwatch = Stopwatch.StartNew();

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.CommandTimeout = 60;
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string title = reader.GetString(0);
                                int purchaseCount = reader.GetInt32(1);
                                results.Add((title, purchaseCount));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при выполнении запроса к БД: {ex.Message}");
            }

            stopwatch.Stop();
            return (results, stopwatch.Elapsed);
        }

        static async Task<(List<(string Title, int PurchaseCount)>, TimeSpan, string)> FetchFromCacheAsync(IDatabase redisDb, string connectionString, string query)
        {
            var stopwatch = Stopwatch.StartNew();
            string cacheKey = "top_10_games";

            List<(string Title, int PurchaseCount)> results = null;
            string source;

            try
            {
                // Попытка получить данные из кэша
                string cachedData = await redisDb.StringGetAsync(cacheKey);
                if (!string.IsNullOrEmpty(cachedData))
                {
                    // Данные найдены в кэше
                    results = JsonConvert.DeserializeObject<List<(string Title, int PurchaseCount)>>(cachedData);
                    source = "cache";
                }
                else
                {
                    // Данных нет в кэше, выполняем запрос к БД
                    (results, _) = FetchFromDatabase(connectionString, query);

                    // Сохраняем результаты в кэш на 30 секунд
                    string serializedData = JsonConvert.SerializeObject(results);
                    await redisDb.StringSetAsync(cacheKey, serializedData, TimeSpan.FromSeconds(30));
                    source = "database";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при работе с Redis: {ex.Message}");
                source = "error";
            }

            stopwatch.Stop();
            return (results, stopwatch.Elapsed, source);
        }

        #region OrderTableFuncs
        static void AddNewOrder()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(sqlConnectionString))
                {
                    connection.Open();
                    Random rand = new Random();
                    int userId = rand.Next(1, 100);
                    int gameId = rand.Next(1, 50);
                    decimal price = (decimal)(rand.NextDouble() * (60 - 10) + 10);
                    int quantity = rand.Next(1, 5);
                    DateTime orderDate = DateTime.Now;

                    string insertQuery = @"
                        INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
                        VALUES (@UserID, @GameID, @Price, @Quantity, @OrderDate);";

                    using (SqlCommand command = new SqlCommand(insertQuery, connection))
                    {
                        command.Parameters.AddWithValue("@UserID", userId);
                        command.Parameters.AddWithValue("@GameID", gameId);
                        command.Parameters.AddWithValue("@Price", price);
                        command.Parameters.AddWithValue("@Quantity", quantity);
                        command.Parameters.AddWithValue("@OrderDate", orderDate);

                        command.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при добавлении заказа: {ex.Message}");
            }
        }

        static void DeleteRandomOrder()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(sqlConnectionString))
                {
                    connection.Open();

                    string selectQuery = "SELECT TOP 1 OrderID FROM Orders ORDER BY NEWID();";
                    int? orderId = null;

                    using (SqlCommand selectCommand = new SqlCommand(selectQuery, connection))
                    {
                        orderId = (int?)selectCommand.ExecuteScalar();
                    }

                    if (orderId.HasValue)
                    {
                        string deleteQuery = "DELETE FROM Orders WHERE OrderID = @OrderID;";
                        using (SqlCommand deleteCommand = new SqlCommand(deleteQuery, connection))
                        {
                            deleteCommand.Parameters.AddWithValue("@OrderID", orderId.Value);
                            deleteCommand.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при удалении заказа: {ex.Message}");
            }
        }

        static void UpdateRandomOrder()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(sqlConnectionString))
                {
                    connection.Open();

                    string selectQuery = "SELECT TOP 1 OrderID FROM Orders ORDER BY NEWID();";
                    int? orderId = null;

                    using (SqlCommand selectCommand = new SqlCommand(selectQuery, connection))
                    {
                        orderId = (int?)selectCommand.ExecuteScalar();
                    }

                    if (orderId.HasValue)
                    {
                        Random rand = new Random();
                        int newQuantity = rand.Next(1, 5);

                        string updateQuery = "UPDATE Orders SET Quantity = @Quantity WHERE OrderID = @OrderID;";
                        using (SqlCommand updateCommand = new SqlCommand(updateQuery, connection))
                        {
                            updateCommand.Parameters.AddWithValue("@Quantity", newQuantity);
                            updateCommand.Parameters.AddWithValue("@OrderID", orderId.Value);
                            updateCommand.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при обновлении заказа: {ex.Message}");
            }
        }
        #endregion
        #region Graph
        // Построение графика
        static void PlotResults(List<double> dbTimes, List<double> cacheTimes, List<DateTime> timestamps, string scenarioName)
        {
            var plotModel = new PlotModel { Title = $"Время выполнения запросов ({scenarioName})" };

            // Создаем серии данных с понятными названиями для легенды
            var dbSeries = new LineSeries
            {
                Title = "Время запроса к БД",
                Color = OxyColors.Red
            };
            var cacheSeries = new LineSeries
            {
                Title = "Время запроса через кэш",
                Color = OxyColors.Blue
            };

            for (int i = 0; i < timestamps.Count; i++)
            {
                double x = DateTimeAxis.ToDouble(timestamps[i]);
                dbSeries.Points.Add(new DataPoint(x, dbTimes[i]));
                cacheSeries.Points.Add(new DataPoint(x, cacheTimes[i]));
            }

            plotModel.Series.Add(dbSeries);
            plotModel.Series.Add(cacheSeries);

            // Создаем и настраиваем легенду
            var legend = new Legend
            {
                LegendPosition = LegendPosition.TopRight,
                LegendPlacement = LegendPlacement.Outside,
                LegendOrientation = LegendOrientation.Horizontal,
            };

            // Добавляем легенду в модель
            plotModel.Legends.Add(legend);

            plotModel.Axes.Add(new DateTimeAxis
            {
                Position = AxisPosition.Bottom,
                StringFormat = "HH:mm:ss",
                Title = "Время",
                IntervalType = DateTimeIntervalType.Seconds,
                MajorGridlineStyle = LineStyle.Solid,
                MinorGridlineStyle = LineStyle.Dot
            });
            plotModel.Axes.Add(new LinearAxis
            {
                Position = AxisPosition.Left,
                Title = "Время выполнения (мс)",
                MajorGridlineStyle = LineStyle.Solid,
                MinorGridlineStyle = LineStyle.Dot
            });

            var plotView = new PlotView { Model = plotModel };
            var form = new Form { Width = 800, Height = 600, Text = $"Результаты сравнения производительности - {scenarioName}" };
            form.Controls.Add(plotView);
            plotView.Dock = DockStyle.Fill;

            Application.Run(form);
        }
        #endregion
    }
}
