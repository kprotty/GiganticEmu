using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Security;
using Newtonsoft.Json;
using System.Net.Http;

namespace launcher
{
    public class auth
    {

        public class auth_http_resposne
        {
            public string token;
            public string username;
            public string nick_name;
            public long moid;
        }

        public class auth_result
        {
            public bool success;
            public string reason;
            public auth_http_resposne result;
        }

        public static auth_result authenticate(string username, string password, Uri host)
        {
            var resp = new auth_result();

            var content2 = new FormUrlEncodedContent(
                new Dictionary<string, string>
                    {
                        {"username", username },
                        {"password", password }
                    }
                );

            var dict = new Dictionary<string, string>();
            dict.Add("user[email]", username);
            dict.Add("user[password]", password);
            var content = new FormUrlEncodedContent(dict);

            try
            {
                using (var client = new HttpClient())
                {
                    client.BaseAddress = host;
                    client.DefaultRequestHeaders.Add("client", "launcher");
                    var http_resposne = client.PostAsync("/users/sign_in.html", content).Result;

                    if (http_resposne.StatusCode == System.Net.HttpStatusCode.OK)
                    {
                        var auth_http_http_resposne = http_resposne.Content.ReadAsStringAsync().Result;
                        var auth = JsonConvert.DeserializeObject<auth_http_resposne>(auth_http_http_resposne);
                        resp.success = true;
                        resp.result = auth;
                        return resp;
                    }
                    else
                    {
                        resp.success = false;
                        resp.reason = "Denied";
                        return resp;
                    }
                }
            }
            catch (HttpRequestException)
            {
                content.Dispose();
                resp.success = false;
                resp.reason = "HTTP error";
                return resp;
            }
            catch (Exception)
            {
                content.Dispose();
                resp.success = false;
                resp.reason = "Connection failed";
                return resp;
            }                           
            
        }

    }

}
