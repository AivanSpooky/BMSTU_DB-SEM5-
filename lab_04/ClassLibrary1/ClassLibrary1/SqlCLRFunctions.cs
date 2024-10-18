using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace ClassLibrary1
{
    public class SqlCLRFunctions
    {
        [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read)]
        public static SqlString CleanGameTitle(SqlString title)
        {
            if (title.IsNull)
                return SqlString.Null;
            string cleaned = Regex.Replace(title.Value, @"[-_\d]", " ");
            return new SqlString(cleaned);
        }


        [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read)]
        public static SqlInt32 GetUserRegistrationDays(SqlInt32 userID)
        {
            using (var connection = new SqlConnection("context connection=true"))
            {
                connection.Open();
                using (var command = new SqlCommand("SELECT DATEDIFF(DAY, RegistrationDate, GETDATE()) FROM Users WHERE UserID = @userID", connection))
                {
                    command.Parameters.AddWithValue("@userID", userID);
                    object result = command.ExecuteScalar();
                    return (result != null) ? new SqlInt32((int)result) : SqlInt32.Null;
                }
            }
        }
    }
    [Serializable]
    [StructLayout(LayoutKind.Sequential)]
    [SqlUserDefinedAggregate(Format.UserDefined, IsInvariantToNulls = true, MaxByteSize = -1)]
    public class GetMaxGamePrice : IBinarySerialize
    {
        private SqlDecimal maxPrice;
        public void Init()
        {
            maxPrice = SqlDecimal.Null;
        }
        public void Accumulate(SqlDecimal price)
        {
            if (!price.IsNull && (maxPrice.IsNull || price > maxPrice))
            {
                maxPrice = price;
            }
        }
        public void Merge(GetMaxGamePrice other)
        {
            if (!other.maxPrice.IsNull && (maxPrice.IsNull || other.maxPrice > maxPrice))
            {
                maxPrice = other.maxPrice;
            }
        }
        public SqlDecimal Terminate()
        {
            return maxPrice.IsNull ? 0 : maxPrice;
        }
        public void Read(BinaryReader r)
        {
            maxPrice = new SqlDecimal(r.ReadDecimal());
        }
        public void Write(BinaryWriter w)
        {
            w.Write(maxPrice.IsNull ? 0 : maxPrice.Value);
        }
    }
}
