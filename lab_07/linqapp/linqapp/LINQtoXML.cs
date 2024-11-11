using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace linqapp
{
    public static class LINQtoXML
    {
        public static void LinqToXml()
        {
            Console.WriteLine("\n--- LINQ to XML ---");

            while (true)
            {
                Console.WriteLine("\nLINQ to XML Options:");
                Console.WriteLine("1. Create XML from Database");
                Console.WriteLine("2. Read from XML");
                Console.WriteLine("3. Update XML");
                Console.WriteLine("4. Write to XML");
                Console.WriteLine("5. Back to Main Menu");
                Console.Write("Select an option (1-5): ");

                string xmlChoice = Console.ReadLine();

                switch (xmlChoice)
                {
                    case "1":
                        CreateXmlFromDatabase();
                        break;
                    case "2":
                        ReadFromXml();
                        break;
                    case "3":
                        UpdateXml();
                        break;
                    case "4":
                        WriteToXml();
                        break;
                    case "5":
                        return;
                    default:
                        Console.WriteLine("Invalid selection. Try again.");
                        break;
                }
            }
        }

        // === LINQ to XML ===
        static void CreateXmlFromDatabase()
        {
            Console.WriteLine("\nCreating XML document from database...");

            try
            {
                string sqlQuery = @"
                    SELECT 
                        g.GameID,
                        g.Title,
                        d.Name AS DeveloperName,
                        d.Country AS DeveloperCountry
                    FROM Games g
                    INNER JOIN Developers d ON g.DeveloperID = d.DeveloperID
                    ORDER BY g.GameID ASC
                ";

                // Create a list to hold the data
                var gameData = new List<GameData>();

                using (SqlConnection connection = new SqlConnection(Program.connectionString))
                {
                    SqlCommand command = new SqlCommand(sqlQuery, connection);
                    connection.Open();

                    SqlDataReader reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        gameData.Add(new GameData
                        {
                            GameID = reader.GetInt32(reader.GetOrdinal("GameID")),
                            Title = reader.GetString(reader.GetOrdinal("Title")),
                            DeveloperName = reader.GetString(reader.GetOrdinal("DeveloperName")),
                            DeveloperCountry = reader.GetString(reader.GetOrdinal("DeveloperCountry"))
                        });
                    }

                    reader.Close();
                }

                // Build the XML document using LINQ to XML
                XDocument gamesXml = new XDocument(
                    new XElement("Games",
                        from game in gameData
                        select new XElement("Game",
                            new XAttribute("GameID", game.GameID),
                            new XElement("Title", game.Title),
                            new XElement("DeveloperInfo",
                                new XElement("Developer",
                                    new XElement("Name", game.DeveloperName),
                                    new XElement("Country", game.DeveloperCountry)
                                )
                            )
                        )
                    )
                );

                // Save the XML document to a file
                gamesXml.Save("games_from_db.xml");

                Console.WriteLine("XML document created and saved as 'games_from_db.xml'.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating XML from database: {ex.Message}");
            }
        }

        // Helper class to hold game data
        class GameData
        {
            public int GameID { get; set; }
            public string Title { get; set; }
            public string DeveloperName { get; set; }
            public string DeveloperCountry { get; set; }
        }

        static void ReadFromXml()
        {
            Console.WriteLine("\nReading from XML document...");

            try
            {
                XDocument loadedGamesXml = XDocument.Load("games_from_db.xml");

                var gamesFromXml = from game in loadedGamesXml.Descendants("Game")
                                   select new
                                   {
                                       GameID = (int)game.Attribute("GameID"),
                                       Title = (string)game.Element("Title"),
                                       DeveloperName = (string)game.Element("DeveloperInfo").Element("Developer").Element("Name"),
                                       DeveloperCountry = (string)game.Element("DeveloperInfo").Element("Developer").Element("Country")
                                   };

                Console.WriteLine("\nGames Read from XML:");
                foreach (var game in gamesFromXml)
                {
                    Console.WriteLine($"GameID: {game.GameID}, Title: {game.Title}, Developer: {game.DeveloperName}, Country: {game.DeveloperCountry}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error reading XML: {ex.Message}");
            }
        }

        static void UpdateXml()
        {
            Console.WriteLine("\nUpdating XML document...");

            try
            {
                // Load the XML document
                XDocument loadedGamesXml = XDocument.Load("games_from_db.xml");

                Console.Write("Enter the GameID of the game you want to update: ");
                string inputGameID = Console.ReadLine();
                int gameID;

                if (!int.TryParse(inputGameID, out gameID))
                {
                    Console.WriteLine("Invalid GameID. Please enter a valid integer.");
                    return;
                }

                Console.Write("Enter the new title for the game: ");
                string newTitle = Console.ReadLine();

                if (string.IsNullOrWhiteSpace(newTitle))
                {
                    Console.WriteLine("Title cannot be empty. Please enter a valid title.");
                    return;
                }

                // Найти игру с нужным gameID
                var gameToUpdate = (from game in loadedGamesXml.Descendants("Game")
                                    where (int)game.Attribute("GameID") == gameID
                                    select game).FirstOrDefault();

                if (gameToUpdate != null)
                {
                    gameToUpdate.Element("Title").Value = newTitle;
                    loadedGamesXml.Save("games_from_db.xml");
                    Console.WriteLine($"Updated the title of GameID {gameID} to '{newTitle}'.");
                }
                else
                    Console.WriteLine($"Game with GameID {gameID} not found.");
            }
            catch (System.IO.FileNotFoundException)
            {
                Console.WriteLine("Error: The XML file 'games_from_db.xml' was not found.");
            }
            catch (UnauthorizedAccessException)
            {
                Console.WriteLine("Error: You do not have permission to access the XML file.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An unexpected error occurred: {ex.Message}");
            }
        }

        static void WriteToXml()
        {
            Console.WriteLine("\nAdding a new game to the XML document...");

            try
            {
                XDocument loadedGamesXml;
                if (System.IO.File.Exists("games_from_db.xml"))
                    loadedGamesXml = XDocument.Load("games_from_db.xml");
                else
                    loadedGamesXml = new XDocument(new XElement("Games"));

                int newGameID = 1; // Default GameID
                var games = loadedGamesXml.Element("Games").Elements("Game");
                if (games.Any())
                {
                    newGameID = games.Max(g => (int)g.Attribute("GameID")) + 1;
                }

                Console.Write("Enter the title of the new game: ");
                string title = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(title))
                {
                    Console.WriteLine("Title cannot be empty.");
                    return;
                }
                Console.Write("Enter the developer's name: ");
                string developerName = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(developerName))
                {
                    Console.WriteLine("Developer name cannot be empty.");
                    return;
                }
                Console.Write("Enter the developer's country: ");
                string developerCountry = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(developerCountry))
                {
                    Console.WriteLine("Developer country cannot be empty.");
                    return;
                }
                Console.Write("Enter the release date (yyyy-mm-dd): ");
                string releaseDateInput = Console.ReadLine();
                DateTime releaseDate;
                if (!DateTime.TryParse(releaseDateInput, out releaseDate))
                {
                    Console.WriteLine("Invalid date format. Please use yyyy-mm-dd.");
                    return;
                }
                Console.Write("Enter the price: ");
                string priceInput = Console.ReadLine();
                decimal price;
                if (!decimal.TryParse(priceInput, out price))
                {
                    Console.WriteLine("Invalid price. Please enter a numeric value.");
                    return;
                }

                // Build the new game element
                XElement newGame = new XElement("Game",
                    new XAttribute("GameID", newGameID),
                    new XElement("Title", title),
                    new XElement("ReleaseDate", releaseDate.ToString("yyyy-MM-dd")),
                    new XElement("Price", price),
                    new XElement("DeveloperInfo",
                        new XElement("Developer",
                            new XElement("Name", developerName),
                            new XElement("Country", developerCountry)
                        )
                    )
                );

                loadedGamesXml.Element("Games").Add(newGame);
                loadedGamesXml.Save("games_from_db.xml");  // Save changes

                Console.WriteLine($"Added new game '{title}' with GameID {newGameID} to the XML document.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error writing to XML: {ex.Message}");
            }
        }
    }
}
