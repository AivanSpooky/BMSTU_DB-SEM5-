using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data.Entity;
using System.Linq;

namespace App
{
    public class satellite
    {
        [Key]
        public int ID_Sputnik { get; set; }
        public string Name { get; set; }
        public DateTime ProductionDate { get; set; }
        public string Country { get; set; }
        public virtual ICollection<flight> flight { get; set; }
    }
    public class flight
    {
        [Key]
        public int ID_Flight { get; set; }
        public int ID_Sputnik { get; set; }
        public DateTime LaunchDate { get; set; }
        public TimeSpan LaunchTime { get; set; }
        public string DayOfWeek { get; set; }
        public int Type { get; set; } // 0 = прилет, 1 = вылет
        public virtual satellite satellite { get; set; }
    }
    public class DbCnt : DbContext
    {
        public DbCnt() : base("Data Source=LAPTOP-7106M2BU;Initial Catalog=RK3;Integrated Security=True") { }
        public DbSet<satellite> satellites { get; set; }
        public DbSet<flight> flights { get; set; }
    }
    internal class Program
    {
        static void Main(string[] args)
        {
            Database.SetInitializer<DbCnt>(null);
            // === 2.1 ===
            Console.WriteLine("Страны, производящие аппараты только в мае:");
            using (var context = new DbCnt())
            {
                var cs = context.satellites
                    .GroupBy(s => s.Country)
                    .Where(g => g.All(s => s.ProductionDate.Month == 5))
                    .Select(g => g.Key)
                    .ToList();

                if (!cs.Any())
                    Console.WriteLine("Нет таких стран");
                else
                    foreach (var country in cs)
                        Console.WriteLine(country);
            }

            // === 2.2 ===
            Console.WriteLine("Спутники, не возвращавшиеся (нет прилётов) в текущем календарном году:");
            using (var context = new DbCnt())
            {
                int y = DateTime.Now.Year;
                var sats = context.satellites
                    .Where(s => !context.flights.Any(f => f.ID_Sputnik == s.ID_Sputnik
                                                          && f.Type == 0 // прилёт
                                                          && f.LaunchDate.Year == y))
                    .ToList();

                if (!sats.Any())
                    Console.WriteLine("Нет таких спутников");
                else
                    foreach (var sat in sats)
                        Console.WriteLine($"{sat.ID_Sputnik}: {sat.Name}");
            }

            // === 2.3 ===
            Console.WriteLine("Страны, в которых есть хотя бы один аппарат с первым запуском после 2024-10-01:");
            using (var context = new DbCnt())
            {
                DateTime cutoff = new DateTime(2024, 10, 1);

                var cs = context.satellites
                    .Where(s =>
                        context.flights
                            .Where(f => f.ID_Sputnik == s.ID_Sputnik)
                            .GroupBy(f => f.ID_Sputnik)
                            .Any(g => g.Min(x => x.LaunchDate) > cutoff)
                    )
                    .Select(s => s.Country)
                    .Distinct()
                    .ToList();

                if (!cs.Any())
                    Console.WriteLine("Нет таких стран");
                else
                    foreach (var country in cs)
                        Console.WriteLine(country);
            }
        }
    }
}