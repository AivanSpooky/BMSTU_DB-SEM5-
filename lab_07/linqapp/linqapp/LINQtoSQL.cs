using System;
using System.Collections.Generic;
using System.Data.Linq.Mapping;
using System.Data.Linq;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace linqapp
{
    // LINQ to SQL
    [Table(Name = "Games")]
    public class GameEntity
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int GameID { get; set; }

        [Column]
        public string Title { get; set; }

        [Column]
        public DateTime ReleaseDate { get; set; }

        [Column]
        public string Description { get; set; }

        [Column]
        public int CategoryID { get; set; }

        [Column]
        public int DeveloperID { get; set; }

        [Column]
        public decimal Price { get; set; }

        [Column]
        public string MinSystemRequirements { get; set; }

        [Column]
        public bool? Discontinued { get; set; }
    }

    [Table(Name = "Developers")]
    public class DeveloperEntity
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int DeveloperID { get; set; }

        [Column]
        public string Name { get; set; }

        [Column]
        public string Country { get; set; }

        [Column]
        public DateTime? Founded { get; set; }

        [Column]
        public string Website { get; set; }

        [Column]
        public int? EmployeeCount { get; set; }
    }

    [Table(Name = "Categories")]
    public class CategoryEntity
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int CategoryID { get; set; }

        [Column]
        public string CategoryName { get; set; }

        [Column]
        public string Description { get; set; }
    }

    public class GamingPlatformDataContext : DataContext
    {
        public Table<GameEntity> Games;
        public Table<DeveloperEntity> Developers;
        public Table<CategoryEntity> Categories;

        public GamingPlatformDataContext(string connectionString) : base(connectionString) { }

        [Function(Name = "dbo.GetGamesByCategoryByID")]
        [ResultType(typeof(GameEntity))]
        public ISingleResult<GameEntity> GetGamesByCategoryByID([Parameter(Name = "CategoryID", DbType = "Int")] int categoryID)
        {
            IExecuteResult result = ExecuteMethodCall(this, ((MethodInfo)MethodInfo.GetCurrentMethod()), categoryID);
            return (ISingleResult<GameEntity>)result.ReturnValue;
        }
    }
    public static class LINQtoSQL
    {
        public static void LinqToSql()
        {
            Console.WriteLine("\n--- LINQ to SQL ---");

            while (true)
            {
                Console.WriteLine("\nLINQ to SQL Options:");
                Console.WriteLine("1. Single-Table Query");
                Console.WriteLine("2. Multi-Table Query");
                Console.WriteLine("3. Add, Update, Delete Operations");
                Console.WriteLine("4. Execute Stored Procedure");
                Console.WriteLine("5. Back to Main Menu");
                Console.Write("Select an option (1-5): ");

                string sqlChoice = Console.ReadLine();

                switch (sqlChoice)
                {
                    case "1":
                        SingleTableQuery();
                        break;
                    case "2":
                        MultiTableQuery();
                        break;
                    case "3":
                        AddUpdateDeleteOperations();
                        break;
                    case "4":
                        ExecuteStoredProcedure();
                        break;
                    case "5":
                        return;
                    default:
                        Console.WriteLine("Invalid selection. Try again.");
                        break;
                }
            }
        }
        // === LINQ to SQL ===
        static void SingleTableQuery()
        {
            Console.WriteLine("\nPerforming single-table query...");

            using (var db = new GamingPlatformDataContext(Program.connectionString))
            {
                var gamesQuery = from game in db.Games
                                 where game.Price > 20
                                 select game;

                Console.WriteLine("\nGames Priced Above $20:");
                foreach (var game in gamesQuery)
                    Console.WriteLine($"{game.Title} - ${game.Price}");
            }
        }

        static void MultiTableQuery()
        {
            Console.WriteLine("\nPerforming multi-table query...");

            using (var db = new GamingPlatformDataContext(Program.connectionString))
            {
                var gamesWithDevelopers = from game in db.Games
                                          join dev in db.Developers on game.DeveloperID equals dev.DeveloperID
                                          select new { game.Title, DeveloperName = dev.Name };

                Console.WriteLine("\nGames with Developer Names:");
                foreach (var item in gamesWithDevelopers)
                    Console.WriteLine($"{item.Title} - Developed by {item.DeveloperName}");
            }
        }

        static void AddUpdateDeleteOperations()
        {
            Console.WriteLine("\nAdd, Update, Delete Operations:");

            using (var db = new GamingPlatformDataContext(Program.connectionString))
            {
                // Adding a new game
                GameEntity newGame = new GameEntity
                {
                    Title = "New Adventure",
                    ReleaseDate = DateTime.Now,
                    Description = "An exciting new adventure game.",
                    CategoryID = 1,
                    DeveloperID = 1,
                    Price = 49.99m,
                    MinSystemRequirements = "8GB RAM, 4GB VRAM",
                    Discontinued = false
                };

                db.Games.InsertOnSubmit(newGame);
                db.SubmitChanges();

                Console.WriteLine("Added a new game to the database.");

                // Refresh the newGame object from the database
                db.Refresh(RefreshMode.KeepChanges, newGame);

                // Updating the existing game
                var gameToUpdate = db.Games.FirstOrDefault(g => g.GameID == newGame.GameID);
                if (gameToUpdate != null)
                {
                    gameToUpdate.Price = 44.99m;
                    db.SubmitChanges();

                    Console.WriteLine("Updated the price of the new game.");
                }

                // Deleting the game
                var gameToDelete = db.Games.FirstOrDefault(g => g.GameID == newGame.GameID);
                if (gameToDelete != null)
                {
                    db.Games.DeleteOnSubmit(gameToDelete);
                    db.SubmitChanges();

                    Console.WriteLine("Deleted the new game from the database.");
                }
            }
        }

        static void ExecuteStoredProcedure()
        {
            Console.WriteLine("\nExecuting stored procedure GetGamesByCategoryByID...");

            using (var db = new GamingPlatformDataContext(Program.connectionString))
            {
                Console.Write("Enter CategoryID to retrieve games: ");
                if (int.TryParse(Console.ReadLine(), out int categoryId))
                {
                    var gamesInCategory = db.GetGamesByCategoryByID(categoryId);

                    Console.WriteLine($"\nGames in CategoryID {categoryId}:");
                    foreach (var game in gamesInCategory)
                        Console.WriteLine($"{game.Title}");
                }
                else
                    Console.WriteLine("Invalid CategoryID.");
            }
        }
    }
}
