using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Reflection;
using System;
using System.Data.SqlClient;

namespace linqapp
{
    internal class Program
    {
        public static string connectionString = @"Data Source=LAPTOP-7106M2BU;Initial Catalog=GamingPlatform;Integrated Security=True";

        static void Main(string[] args)
        {
            while (true)
            {
                Console.WriteLine("\n=== Gaming Platform Menu ===");
                Console.WriteLine("1. LINQ to Objects - Five Queries");
                Console.WriteLine("2. LINQ to XML");
                Console.WriteLine("3. LINQ to SQL");
                Console.WriteLine("4. Exit");
                Console.Write("Select an option (1-4): ");

                string mainChoice = Console.ReadLine();

                switch (mainChoice)
                {
                    case "1":
                        LINQtoOBJ.LinqToObjects();
                        break;
                    case "2":
                        LINQtoXML.LinqToXml();
                        break;
                    case "3":
                        LINQtoSQL.LinqToSql();
                        break;
                    case "4":
                        Console.WriteLine("Exiting application...");
                        return;
                    default:
                        Console.WriteLine("Invalid selection. Try again.");
                        break;
                }
            }
        }
    }
}
