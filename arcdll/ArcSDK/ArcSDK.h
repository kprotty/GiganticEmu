#pragma once

#include "json.hpp"
#include <stdio.h>
#include <string.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#pragma comment(lib, "Ws2_32.lib")

using json = nlohmann::json;

class Account
{
	public:
		std::string token;
		std::string accountname;
		std::string nickname;
		std::string server;
		long moid;
};

class Friend
{
	std::string nickname;
	std::string status;
	long moid;
};

// Game client originally used named pipes to communicate with Arc launcher, using sockets instead.
class GameSocket
{
	private:
		SOCKET listen_sock;
		SOCKET client;

	public:
		//create socket
		GameSocket() 
		{
			ADDRINFO hints = {0}, *test;
			hints.ai_family = AF_INET;
			hints.ai_socktype = SOCK_STREAM;
			hints.ai_protocol = IPPROTO_TCP;

			getaddrinfo("127.0.0.1", "11000", &hints, &test);
			
			if ((client = socket(hints.ai_family, SOCK_STREAM, hints.ai_protocol)) == -1) {
				perror("Could not connect to socket");
			}

			int sock_status = connect(client, test->ai_addr, test->ai_addrlen);

			if (sock_status == SOCKET_ERROR)
			{
				MessageBox(NULL, L"Could not connect to Launcher", L"error", MB_ICONEXCLAMATION);
				return;
			}
		};

		//send query to launcher socket, returns json containing
		void getAccount(Account &acc, std::string &server)
		{
			const char* qeury = "{\"query\":\"account\"}";
			send(client, qeury, strlen(qeury), 0);
			shutdown(client, SD_SEND);

			const int BUFF_SIZE = 512;
			char buffer[BUFF_SIZE];
			memset(buffer, 0, BUFF_SIZE); // Really shouldn't lol.
			int recv_size = recv(client, buffer, BUFF_SIZE, 0);

			if (recv_size == SOCKET_ERROR)
			{
				MessageBox(NULL, L"Could not receive account status", L"error", MB_ICONEXCLAMATION);
				return;
			} else
			{
				try {
					auto j = json::parse(buffer);
					if (j["success"].get<bool>() == false)
					{
						MessageBox(NULL, L"Could not authenticate", L"error", MB_ICONEXCLAMATION);
					}
					acc.token = j["payload"]["token"].get<std::string>();
					acc.accountname = j["payload"]["name"].get<std::string>();
					acc.nickname = j["payload"]["nick"].get<std::string>();
					server = j["payload"]["server"].get<std::string>();
					acc.moid = j["payload"]["moid"].get<long>();
				}
				catch (const std::exception& e)
				{
					MessageBoxA(NULL, e.what() , "ERROR", MB_ICONEXCLAMATION);
				}
			}
		}

		/*
		void get_friends()
		{

		}
		
		void add_friend(string nick, long moid)
		{

		}
		*/


		void close()
		{
			closesocket(client);
		}
};