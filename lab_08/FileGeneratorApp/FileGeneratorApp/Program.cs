using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Timers;
using Newtonsoft.Json;

namespace FileGeneratorApp
{
    class Program
    {
        static string connectionString = @"Data Source=LAPTOP-7106M2BU;Initial Catalog=GamingPlatform;Integrated Security=True";
        static Timer timer;

        static void Main(string[] args)
        {
            // Установка таймера
            timer = new Timer(300000 / 5 / 60 * 2);
            timer.Elapsed += Timer_Elapsed;


            timer.AutoReset = true;
            timer.Enabled = true;

            Console.WriteLine("Приложение запущено. Нажмите Enter для выхода.");
            Console.ReadLine();
        }

        private static void Timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            GenerateFile();
        }

        static void GenerateFile()
        {
            try
            {
                List<GameData> games = GenerateNewData(10);
                string jsonData = JsonConvert.SerializeObject(games, Formatting.Indented);

                // Генерируем имя файла по маске
                string fileName = GenerateFileName();


                string directoryPath = @"C:\DataFiles";
                if (!Directory.Exists(directoryPath))
                {
                    Directory.CreateDirectory(directoryPath);
                }

                string filePath = Path.Combine(directoryPath, fileName);

                File.WriteAllText(filePath, jsonData);

                Console.WriteLine($"[{DateTime.Now}] Файл '{fileName}' успешно создан.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка при генерации файла: {ex.Message}");
            }
        }

        // Метод для генерации новых данных
        static List<GameData> GenerateNewData(int count)
        {
            List<GameData> games = new List<GameData>();
            Random random = new Random();

            for (int i = 1; i <= count; i++)
            {
                games.Add(new GameData
                {
                    Title = $"NewGame-{i}",
                    ReleaseDate = DateTime.Now.AddDays(-random.Next(0, 365)).ToString("yyyy-MM-dd"),
                    Description = "Generated description",
                    CategoryID = 1,
                    DeveloperID = 1,
                    Price = Math.Round((decimal)(random.NextDouble() * 100), 2),
                    MinSystemRequirements = "4GB RAM, 2GB VRAM",
                    Discontinued = false
                });
            }

            return games;
        }

        static string GenerateFileName()
        {
            string fileId = Guid.NewGuid().ToString();
            string tableName = "Games";
            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string fileName = $"{fileId}_{tableName}_{timestamp}.json";

            return fileName;
        }
    }

    class GameData
    {
        public string Title { get; set; }
        public string ReleaseDate { get; set; }
        public string Description { get; set; }
        public int CategoryID { get; set; }
        public int DeveloperID { get; set; }
        public decimal Price { get; set; }
        public string MinSystemRequirements { get; set; }
        public bool Discontinued { get; set; }
    }
}
