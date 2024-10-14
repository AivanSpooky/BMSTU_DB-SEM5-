using System;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Xml.Linq;
using Bogus.DataSets;
using Faker;
using Newtonsoft.Json;

namespace src
{
    internal class Program
    {
        private static string connectionString = "Server=LAPTOP-7106M2BU;Database=GamingPlatform;Trusted_Connection=True;";

        public static async Task Main(string[] args)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                // Экспорт данных пользователей в CSV
                await GenerateAndExportUsersToCsv(connection, "../../../../../users.csv");

                // Экспорт данных разработчиков в CSV
                await GenerateAndExportDevelopersToCsv(connection, "../../../../../developers.csv");

                // Экспорт данных категорий в CSV
                await GenerateAndExportCategoriesToCsv(connection, "../../../../../categories.csv");

                // Экспорт данных игр в CSV
                await GenerateAndExportGamesToCsv(connection, "../../../../../games.csv");

                // Экспорт данных заказов в CSV
                await GenerateAndExportOrdersToCsv(connection, "../../../../../orders.csv");

                // Экспорт данных отзывов в CSV
                await GenerateAndExportReviewsToCsv(connection, "../../../../../reviews.csv");

                Console.WriteLine("Данные успешно сгенерированы и экспортированы в CSV.");
            }
        }

        // Метод для генерации и экспорта пользователей
        private static async Task GenerateAndExportUsersToCsv(SqlConnection connection, string filePath)
        {
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "UserID", "Username", "Email", "RegistrationDate", "Country", "AccountStatus" };
                writer.WriteLine(string.Join("%", columnNames));

                for (int i = 1; i <= 1000; i++)
                {
                    string uniqueEmail = $"user{i}@{InternetFaker.Domain()}";  // Генерация уникального email

                    string[] row = new string[]
                    {
                    i.ToString(),
                    NameFaker.Name(),
                    uniqueEmail,
                    DateTimeFaker.DateTime().ToString("yyyy-MM-dd"),
                    LocationFaker.Country(),
                    BooleanFaker.Boolean() ? "1" : "0",
                    };
                    writer.WriteLine(string.Join("%", row));
                }
            }
        }

        // Метод для генерации и экспорта разработчиков
        private static async Task GenerateAndExportDevelopersToCsv(SqlConnection connection, string filePath)
        {
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "DeveloperID", "Name", "Country", "Founded", "Website", "EmployeeCount" };
                writer.WriteLine(string.Join("%", columnNames));

                for (int i = 1; i <= 1000; i++)
                {
                    string[] row = new string[]
                    {
                    i.ToString(),
                    CompanyFaker.Name(),
                    LocationFaker.Country(),
                    DateTimeFaker.DateTime().ToString("yyyy-MM-dd"), //!!!!
                    InternetFaker.Url(),
                    NumberFaker.Number(10, 1000).ToString()
                    };
                    writer.WriteLine(string.Join("%", row));
                }
            }
        }

        // Метод для генерации и экспорта категорий
        private static async Task GenerateAndExportCategoriesToCsv(SqlConnection connection, string filePath)
        {
            var categories = new string[]
            {
                "Action", "Adventure", "RPG", "Simulation", "Strategy", "Sports", "Puzzle", "Racing",
                "Fighting", "Platformer", "Shooter", "Survival", "Horror", "Stealth", "Open World",
                "Sandbox", "MMORPG", "MOBA", "Card Game", "Rhythm", "Tower Defense", "Turn-Based Strategy",
                "Real-Time Strategy", "First-Person Shooter", "Third-Person Shooter", "Beat 'em Up",
                "Hack and Slash", "Metroidvania", "Visual Novel", "Text Adventure", "Point and Click",
                "Interactive Movie", "Trivia", "Party", "Educational", "Casual", "Idle Game", "Multiplayer Online Battle Arena",
                "Roguelike", "Roguelite", "4X Strategy", "City Building", "Colony Sim", "Tycoon", "God Game", "Life Simulation",
                "Dating Sim", "Farming Sim", "Flight Sim", "Music Game", "Dance Game", "Cooking Sim", "Building", "Crafting",
                "Narrative", "Historical", "Sci-Fi", "Fantasy", "Cyberpunk", "Post-Apocalyptic", "Western", "Eastern",
                "Medieval", "Steampunk", "Space Exploration", "Pirates", "Ninja", "Samurai", "Superhero", "Vampire", "Zombie",
                "Mystery", "Detective", "Crime", "Psychological", "Espionage", "War", "Military", "Naval Warfare", "Air Combat",
                "Mecha", "Anime", "Cartoon", "Pixel Art", "8-bit", "16-bit", "Retro", "Futuristic", "Magic", "Robots", "Aliens",
                "Dinosaurs", "Post-Human", "Virtual Reality", "Augmented Reality", "Sports Management", "Wrestling", "Boxing",
                "Martial Arts", "Karate", "Judo", "Kickboxing", "Basketball", "Football", "Soccer", "Hockey", "Tennis", "Golf",
                "Skating", "Skiing", "Snowboarding", "Skateboarding", "BMX", "Motocross", "Baseball", "Cricket", "Rugby",
                "Badminton", "Table Tennis", "Volleyball", "Handball", "Archery", "Bowling", "Darts", "Fishing", "Hunting",
                "Chess", "Checkers", "Go", "Backgammon", "Mahjong", "Dominoes", "Sudoku", "Crossword", "Brain Training",
                "Board Game", "Card Battle", "Trading Card Game", "Collectible Card Game", "Deck Building", "Real-Time Tactics",
                "Turn-Based Tactics", "Grand Strategy", "Economic Simulation", "Business Simulation", "Political Simulation",
                "Government Simulation", "Empire Building", "Resource Management", "Time Management", "Puzzle Platformer",
                "Match-3", "Physics Puzzle", "Hidden Object", "Escape Room", "Trivia Quiz", "Typing Game", "Word Game", "Music Trivia",
                "Soundtrack Game", "Voice Controlled Game", "Gesture Controlled Game", "Narrative-Driven", "Choice-Based",
                "Multiple Endings", "Moral Choices", "Interactive Fiction", "Procedural Generation", "Permadeath", "Time Loop",
                "Bullet Hell", "Endless Runner", "Rhythm Action", "Musical Platformer", "Procedural Music", "Sound Puzzle",
                "Creative Sandbox", "Physics Sandbox", "Automobile Simulation", "Racing Sim", "Arcade Racing", "Kart Racing",
                "Off-Road Racing", "Drift Racing", "Drag Racing", "Motorbike Racing", "Boat Racing", "Spaceship Racing",
                "Flying Game", "Space Combat", "Dogfighting", "Starfighter Simulation", "Vehicle Combat", "Tank Simulation",
                "Tank Battle", "Naval Battle", "Battleship Simulation", "Submarine Simulation", "Train Simulation", "Bus Simulation",
                "Truck Simulation", "Heavy Machinery", "Farming Simulation", "Construction Simulation", "Demolition Game",
                "Architectural Simulation", "Interior Design", "Civil Engineering", "Bridge Building", "Tower Building",
                "City Planning", "Urban Design", "Arcade Shooter", "Side-Scrolling Shooter", "Vertical Shooter", "Isometric Shooter",
                "Twin-Stick Shooter", "Bullet Hell Shooter", "Light Gun Game", "On-Rails Shooter", "Duck Hunt", "Sniper Game",
                "Stealth Shooter", "Tactical Shooter", "Cover Shooter", "Run and Gun", "Top-Down Shooter", "Dungeon Crawler",
                "Roguelike Dungeon", "Action RPG", "Tactical RPG", "Strategy RPG", "JRPG", "WRPG", "Story-Driven RPG",
                "Open World RPG", "Party-Based RPG", "Looter Shooter", "Survival Horror", "Psychological Horror", "Supernatural Horror",
                "Monster Horror", "Slasher Horror", "Escape Game", "Survival Sim", "Base Building", "Crafting Survival",
                "Hardcore Survival", "Zombie Survival", "Post-Apocalyptic Survival", "Alien Invasion", "Caveman Simulation",
                "Time Travel", "Alternate History", "Folk Tales", "Mythology", "Legends", "Fairy Tales", "Folklore", "Epic Fantasy",
                "Dark Fantasy", "High Fantasy", "Sword and Sorcery", "Grimdark", "Heroic Fantasy", "Lovecraftian Horror",
                "Urban Fantasy", "Magical Realism", "Hard Science Fiction", "Space Opera", "Military Science Fiction",
                "Cyberpunk RPG", "Post-Cyberpunk", "Steampunk RPG", "Dieselpunk", "Atompunk", "Biopunk", "Ecotopia",
                "Near-Future", "Dystopian", "Utopian", "Climate Fiction", "Anthropomorphized Animals", "Kaiju Games",
                "Giant Robots", "Mecha RPG", "Hero Shooter", "Battle Royale", "Social Deduction", "Team-Based Game",
                "Co-Op Multiplayer", "Asymmetrical Multiplayer", "Persistent Online World", "Massively Multiplayer Online",
                "VR RPG", "Augmented Reality RPG", "Mind Control", "Underwater Exploration", "Deep Sea Survival",
                "Ancient Civilization", "Cultural Simulation", "Mythic Adventure", "Historical Fantasy", "Alternate Universe",
                "Dreamscape", "Puzzle Horror", "Survival Puzzle", "Mystery Puzzle", "Paranormal Investigation", "Detective Puzzle",
                "Forensic Game", "Crime Solving", "Cold Case Investigation", "Private Investigator", "Lawyer Simulation",
                "Courtroom Drama", "Legal Puzzle", "Medical Simulation", "Hospital Management", "Surgery Game", "Forensic Simulation",
                "Doctor Simulation", "Nurse Simulation", "EMT Simulation", "Firefighter Simulation", "Police Simulation",
                "Airport Simulation", "Air Traffic Control", "Train Conductor", "Space Station Management", "Spaceship Construction",
                "Starship Simulation", "Space Mining", "Interstellar Trading", "Alien Diplomacy", "First Contact", "Colonization",
                "Terraforming", "Sci-Fi Strategy", "Exoplanet Exploration", "Black Hole Exploration", "Quantum Physics Puzzle",
                "Time Dilation", "Time Manipulation", "Dimension Hopping", "Reality-Bending Puzzle", "Mind-Bending Platformer",
                "Psychological Puzzle", "Dream Exploration", "Subconscious Adventure", "Thought Experiment", "Philosophical Puzzle",
                "Moral Dilemmas", "Existential Puzzle", "Human Condition Simulation", "Utopian Puzzle", "Dystopian Puzzle",
                "Religious Exploration", "Mythic Exploration", "Esoteric Puzzle", "Mystical Adventure", "Occult Puzzle",
                "Shamanic Journey", "Psychic Powers", "Telekinesis Game", "Mind Control Puzzle", "Telepathy Game",
                "Brainwave Puzzle", "Synesthesia Puzzle", "Lucid Dreaming", "Astral Projection", "Out of Body Experience",
                "Near-Death Experience", "Reincarnation Puzzle", "Life Simulation", "Death Simulation", "Soul Puzzle",
                "Consciousness Puzzle", "Reality Simulation", "Simulation of Everything", "Godlike Powers", "Cosmic Entity Puzzle"
            };
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "CategoryID", "CategoryName", "Description" };
                writer.WriteLine(string.Join(",", columnNames));

                for (int i = 1; i <= categories.Length; i++)
                {
                    string[] row = new string[]
                    {
                    i.ToString(),
                    categories[i - 1],
                    TextFaker.Sentence()
                    };
                    writer.WriteLine(string.Join(",", row));
                }
            }
        }

        // Метод для генерации и экспорта игр
        private static DateTime[] gdates = new DateTime[1000];
        private static async Task GenerateAndExportGamesToCsv(SqlConnection connection, string filePath)
        {
            var random = new Random();
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "GameID", "Title", "ReleaseDate", "Description", "CategoryID", "DeveloperID", "Price", "MinSystemRequirements", "Discontinued" };
                writer.WriteLine(string.Join(",", columnNames));

                for (int i = 1; i <= 1000; i++)
                {
                    gdates[i - 1] = DateTimeFaker.DateTime();
                    string[] row = new string[]
                    {
                    i.ToString(),
                    $"Game-{i}",
                    gdates[i - 1].ToString("yyyy-MM-dd"),
                    TextFaker.Sentence().Length > 100 ? TextFaker.Sentence().Substring(0, 100) : TextFaker.Sentence(),
                    NumberFaker.Number(1, 382).ToString(),
                    NumberFaker.Number(1, 1000).ToString(),
                    Math.Round((decimal)random.NextDouble() * (100.00m - 0.00m) + 0.00m, 2).ToString(),
                    "Windows XP 2.0 + GHz 512 MB ОЗУ OpenGL 2.0 support 100 MB",
                    BooleanFaker.Boolean() ? "1" : "0"
                    };
                    writer.WriteLine(string.Join(",", row));
                }
            }
        }

        // Метод для генерации и экспорта заказов
        private static async Task GenerateAndExportOrdersToCsv(SqlConnection connection, string filePath)
        {
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "OrderID", "UserID", "GameID", "Price", "Quantity", "OrderDate" };
                writer.WriteLine(string.Join(",", columnNames));

                for (int i = 1; i <= 1000; i++)
                {
                    string[] row = new string[]
                    {
                    i.ToString(),
                    NumberFaker.Number(1, 1000).ToString(), // 1000 пользователей
                    NumberFaker.Number(1, 1000).ToString(), // 1000 игр
                    NumberFaker.Number(10, 60).ToString(),
                    NumberFaker.Number(1, 5).ToString(),
                    gdates[i - 1].AddDays(NumberFaker.Number(1, 5)).ToString("yyyy-MM-dd")
                    };
                    writer.WriteLine(string.Join(",", row));
                }
            }
        }

        // Метод для генерации и экспорта отзывов
        private static async Task GenerateAndExportReviewsToCsv(SqlConnection connection, string filePath)
        {
            using (StreamWriter writer = new StreamWriter(filePath, false, Encoding.UTF8))
            {
                string[] columnNames = { "ReviewID", "UserID", "GameID", "ReviewText", "GameRating" };
                writer.WriteLine(string.Join(",", columnNames));

                for (int i = 1; i <= 1000; i++)
                {
                    string[] row = new string[]
                    {
                    i.ToString(),
                    NumberFaker.Number(1, 1000).ToString(),
                    NumberFaker.Number(1, 1000).ToString(),
                    TextFaker.Sentence(),
                    NumberFaker.Number(1, 10).ToString()
                    };
                    writer.WriteLine(string.Join(",", row));
                }
            }
        }
    }
}
    


