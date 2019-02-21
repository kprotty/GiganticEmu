using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Net.Http;

namespace launcher
{
    public static class Account
    {

        static public bool authenticated;
        static public string auth_token;
        static public string username;
        static public string nick_name;
        static public long moid;

        public class Friend
        {
            public string username;
            public Int64 moid;
            public string status;
        }

        static public List<Friend> friends = new List<Friend>();

        //not yet implemented
        static public List<Friend> get_friends()
        {
            return friends;
        }

        static public void add_friend(Array friend)
        {
            

        }

    }

}
