using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.IO;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Windows.Threading;
using System.Threading.Tasks;
using System.Windows;

using Newtonsoft.Json;

namespace launcher
{
    static public class GameSocket
    {
        public class ClientPacket
        {
            public string query;
            public Array payload;
        }

        public class ServerResponse
        {
            public string query;
            public bool success;
            public object payload;
        }

        public class Account_details
        {
            public string token = Account.auth_token;
            public string name = Account.username;
            public string nick = Account.nick_name;
            public string server = MainWindow.server.ToString();
            public long moid = Account.moid;
        }

        public static string data = null;

        static public void StartListening()
        {
            byte[] bytes = new Byte[1024];
            byte[] msg = new Byte[1024];

            IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName());
            IPAddress ipAddress = IPAddress.Parse("127.0.0.1");
            IPEndPoint localEndPoint = new IPEndPoint(ipAddress, 11000);

            Socket listener = new Socket(ipAddress.AddressFamily,SocketType.Stream, ProtocolType.Tcp);

            try
            {
                listener.Bind(localEndPoint);
                listener.Listen(10);

                while (true)
                {
                    Socket handler = listener.Accept();
                    data = null;
                    msg = null;
                    ClientPacket client_data;

                    while (true)
                    {
                        int bytesRec = handler.Receive(bytes);
                        data += Encoding.ASCII.GetString(bytes, 0, bytesRec);
                        data = data.Trim();
                        break;
                    }

                    ServerResponse resp = new ServerResponse();

                    if (!Account.authenticated)
                    {
                        resp.success = false;
                        resp.payload = "unauthenticated";
                    }
                    else
                    {
                        try
                        {
                            client_data = JsonConvert.DeserializeObject<ClientPacket>(data);
                            switch (client_data.query)
                            {
                                case "account":
                                    resp.success = true;
                                    resp.payload = new Account_details();
                                    break;
                                case "list_friends":
                                    resp.success = false;
                                    resp.payload = "not implemented";
                                    break;
                                case "add_friend":
                                    resp.success = false;
                                    resp.payload = "not implemented";
                                    break;
                                default:
                                    resp.success = false;
                                    resp.payload = "no such function";
                                    break;
                            }
                        }
                        catch (Exception e)
                        {
                            resp.success = false;
                            resp.payload = e;
                        }
                    }

                    msg = Encoding.ASCII.GetBytes(JsonConvert.SerializeObject(resp));

                    handler.Send(msg);
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.ToString());
            }
        }

    }

    public static class Game
    {
        static Process game_process;

        public static void Start()
        {
            try
            {
                game_process = new Process();
                game_process.Exited += new EventHandler(close);
                game_process.EnableRaisingEvents = true;
                game_process.StartInfo.FileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Binaries\\Win64\\RxGame-Win64-Shipping.exe");
                game_process.Start();
                return;
            }
            catch (Exception e)
            {
                MessageBox.Show(e.ToString());
            }
        }

        public static void close(object sender, EventArgs e)
        {
            System.Environment.Exit(0);
        }
    }
}
