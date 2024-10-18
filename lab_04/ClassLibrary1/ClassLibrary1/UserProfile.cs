using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace ClassLibrary1
{
    [Serializable]
    [SqlUserDefinedType(Format.UserDefined, IsByteOrdered = true, MaxByteSize = 8000)]
    public class UserProfile : INullable, IBinarySerialize
    {
        private bool isNull;
        public bool IsNull { get { return isNull; } }

        public static UserProfile Null { get { return new UserProfile { isNull = true }; } }

        public string Username { get; set; }
        public string Email { get; set; }

        public static UserProfile Parse(SqlString s)
        {
            if (s.IsNull)
                return Null;

            string[] parts = s.Value.Split(',');
            return new UserProfile
            {
                Username = parts[0],
                Email = parts[1]
            };
        }

        public override string ToString()
        {
            return $"{Username},{Email}";
        }

        public void Write(System.IO.BinaryWriter w)
        {
            w.Write(Username ?? string.Empty);
            w.Write(Email ?? string.Empty);
        }

        public void Read(System.IO.BinaryReader r)
        {
            Username = r.ReadString();
            Email = r.ReadString();
        }
    }
}
