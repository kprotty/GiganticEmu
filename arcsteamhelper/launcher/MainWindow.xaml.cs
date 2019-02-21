using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace launcher
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public static Uri server;

        public MainWindow()
        {
            new Thread(GameSocket.StartListening).Start();
            InitializeComponent();
            
        }

        private void login_click(object sender, EventArgs e)
        {

            //check form
            if (form_host.Text == null)
            {
                show_error("No host empty");
                return;
            }
            else if (!Uri.IsWellFormedUriString(form_host.Text, UriKind.Absolute))
            {
                show_error("Invalid url");
                return;
            }

            server = new Uri(form_host.Text);
            

            if (form_username == null || form_password == null)
            {
                show_error("Invalid credentials");
                return;
            }

            var response = auth.authenticate(form_username.Text, form_password.Password, server);

            if (response.success)
            {
                Account.authenticated = true;
                Account.auth_token = response.result.token;
                Account.username = response.result.username;
                Account.nick_name = response.result.nick_name;
                Account.moid = response.result.moid;

                login_status.Text = String.Empty;

                Game.Start();

                this.WindowState = WindowState.Minimized;
            }
            else
            {
                show_error(response.reason);
                return;
            }


        }

        private void show_error(string error)
        {
            login_status.Foreground = Brushes.Red;
            login_status.Background = Brushes.White;
            login_status.Text = error;
        }
    }
}
