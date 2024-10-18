using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace ClassLibrary1
{
    public class SqlCLRTriggers
    {
        [SqlTrigger(Name = "trg_InsteadOfInsertOrders", Target = "Orders", Event = "FOR INSERT")]
        public static void InsteadOfInsertOrders()
        {
            SqlTriggerContext triggerContext = SqlContext.TriggerContext;
            if (triggerContext.TriggerAction == TriggerAction.Insert)
            {
                using (var connection = new SqlConnection("context connection=true"))
                {
                    connection.Open();
                    using (var command = new SqlCommand("SELECT Price FROM inserted", connection))
                    {
                        using (var reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                decimal price = reader.GetDecimal(0);
                                if (price < 0)
                                    throw new Exception("Цена заказа не может быть отрицательной.");
                            }
                        }
                    }
                }
            }
        }
    }
}
