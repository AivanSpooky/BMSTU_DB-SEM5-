using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static linqapp.Program;

namespace linqapp
{
    public static class LINQtoOBJ
    {
        public static void LinqToObjects()
        {
            Console.WriteLine("\n--- LINQ to Objects ---");

            // --- Инициализация игр и жанров ---
            List<Game> games = GetSampleGames();
            List<Category> categories = GetSampleCategories();

            // 1. Простая выборка с from, where, select
            var recentGames = from game in games
                              where game.ReleaseDate.Year >= 2020
                              select game;

            Console.WriteLine("\n1. Recent Games (Released in or after 2020):");
            foreach (var game in recentGames)
                Console.WriteLine(game.Title);

            // 2. С orderby
            var orderedGames = from game in games
                               orderby game.Price descending
                               select game;

            Console.WriteLine("\n2. Games Ordered by Price (Descending):");
            foreach (var game in orderedGames)
                Console.WriteLine($"{game.Title} - ${game.Price}");

            // 3. Joining
            var gamesWithCategories = from game in games
                                      join category in categories on game.CategoryID equals category.CategoryID
                                      select new { game.Title, Category = category.CategoryName };

            Console.WriteLine("\n3. Games with Categories:");
            foreach (var item in gamesWithCategories)
            {
                Console.WriteLine($"{item.Title} - {item.Category}");
            }

            // 4.
            var gamesGroupedByCategory = from game in games
                                         group game by game.CategoryID into gameGroup
                                         select gameGroup;

            Console.WriteLine("\n4. Games Grouped by CategoryID:");
            foreach (var group in gamesGroupedByCategory)
            {
                Console.WriteLine($"CategoryID: {group.Key}");
                foreach (var game in group)
                {
                    Console.WriteLine($" - {game.Title}");
                }
            }

            // 5.
            var gamesWithTax = from game in games
                               let priceWithTax = game.Price * 1.2m
                               where priceWithTax > 20
                               select new { game.Title, PriceWithTax = priceWithTax };

            Console.WriteLine("\n5. Games with Price Including Tax (> $20):");
            foreach (var item in gamesWithTax)
            {
                Console.WriteLine($"{item.Title} - ${item.PriceWithTax:F2}");
            }
        }
        // === LINQ to Objects ===
        public class Game
        {
            public int GameID { get; set; }
            public string Title { get; set; }
            public DateTime ReleaseDate { get; set; }
            public string Description { get; set; }
            public int CategoryID { get; set; }
            public int DeveloperID { get; set; }
            public decimal Price { get; set; }
            public string MinSystemRequirements { get; set; }
            public bool Discontinued { get; set; }
        }

        public class Category
        {
            public int CategoryID { get; set; }
            public string CategoryName { get; set; }
        }

        static List<Game> GetSampleGames()
        {
            return new List<Game>
            {
                new Game { GameID = 1, Title = "SampleGame-1", ReleaseDate = new DateTime(2020, 5, 1), Description = "An epic adventure game.", CategoryID = 1, DeveloperID = 1, Price = 29.99m, MinSystemRequirements = "4GB RAM, 2GB VRAM", Discontinued = false },
                new Game { GameID = 2, Title = "SampleGame-2", ReleaseDate = new DateTime(2019, 8, 15), Description = "A classic space shooter.", CategoryID = 2, DeveloperID = 2, Price = 19.99m, MinSystemRequirements = "2GB RAM, 1GB VRAM", Discontinued = false },
                new Game { GameID = 3, Title = "SampleGame-3", ReleaseDate = new DateTime(2021, 3, 22), Description = "Solve the mysteries of the maze.", CategoryID = 1, DeveloperID = 3, Price = 24.99m, MinSystemRequirements = "6GB RAM, 4GB VRAM", Discontinued = false },
                new Game { GameID = 4, Title = "SampleGame-4", ReleaseDate = new DateTime(2018, 11, 5), Description = "High-speed racing action.", CategoryID = 3, DeveloperID = 4, Price = 39.99m, MinSystemRequirements = "8GB RAM, 6GB VRAM", Discontinued = false },
                new Game { GameID = 5, Title = "SampleGame-5", ReleaseDate = new DateTime(2022, 1, 10), Description = "Challenge your mind.", CategoryID = 4, DeveloperID = 5, Price = 14.99m, MinSystemRequirements = "2GB RAM, 1GB VRAM", Discontinued = false },
            };
        }

        static List<Category> GetSampleCategories()
        {
            return new List<Category>
            {
                new Category { CategoryID = 1, CategoryName = "Adventure" },
                new Category { CategoryID = 2, CategoryName = "Arcade" },
                new Category { CategoryID = 3, CategoryName = "Racing" },
                new Category { CategoryID = 4, CategoryName = "Puzzle" },
            };
        }
    }
}
