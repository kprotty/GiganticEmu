#pragma once

// up-to-date windows definitions
#define WIN32_LEAN_AND_MEAN
#define WINVER          0x0501
#define _WIN32_WINNT    0x0602
#include <Windows.h>

// winsock2
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")

// json & strings
#include "json.hpp"
#include <string.h>
using json = nlohmann::json;

void ArcPanic(const char* message) {
    MessageBoxA(NULL, message, "Error", MB_ICONEXCLAMATION);
    exit(1);
}

void ArcWriteWideString(const std::string& string, wchar_t* buffer, size_t buffer_size) {
    std::wstring wide_string(string.begin(), string.end());

    // make sure not to overwrite on the buffer
    size_t num_chars = wide_string.length();
    if (num_chars >= buffer_size) {
        num_chars = buffer_size - 1;
    }

    std::wmemcpy(buffer, wide_string.c_str(), num_chars);
    buffer[num_chars] = 0; // null terminate it
}

class ArcUserAccount {
public:
    long moid;
    std::string nick;
    std::string name;
    std::string token;
    std::string server;
};

class ArcClient {
private:
    SOCKET client = -1;

public:
    ~ArcClient() {
        if (client != -1)
            closesocket(client);
    }

    void Connect(const char* host, const char* port) {
        ADDRINFO *addr, hints = {0};
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_protocol = IPPROTO_TCP;
        getaddrinfo(host, port, &hints, &addr);

        if ((client = socket(hints.ai_family, SOCK_STREAM, hints.ai_protocol)) == -1)
            throw std::runtime_error("[ArcSDK] Failed to create a socket for the launcher");

        if (connect(client, addr->ai_addr, addr->ai_addrlen) == SOCKET_ERROR)
            throw std::runtime_error("[ArcSDK] Failed to connect to the launcher client");
    }

    void GetUserAccount(ArcUserAccount& account) {
        const char* query = "{\"query\":\"account\"}";
        send(client, query, strlen(query), 0);
        shutdown(client, SD_SEND);

        char buffer[512] = { 0 };
        if (recv(client, buffer, sizeof(buffer), 0) == SOCKET_ERROR)
            throw std::runtime_error("[ArcSDK] Failed to receive data from the launcher client");

        auto data = json::parse(buffer);
        if (!data["success"].get<bool>())
            throw std::runtime_error("[ArcSDK] Failed to authenticate the launcher client");

        auto payload = data["payload"];
        account.moid = payload["moid"].get<long>();
        account.name = payload["name"].get<std::string>();
        account.nick = payload["nick"].get<std::string>();
        account.token = payload["token"].get<std::string>();
        account.server = payload["server"].get<std::string>();
    }
};