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

// libc++ stuff
#include <string>
#include <cstring>
#include <cstdint>
#include <stdexcept>

void ArcPanic(const char* message);

void ArcWriteString(const std::wstring& string, wchar_t* buffer, size_t buffer_size);

class ArcUserAccount {
public:
    std::wstring nick;
    std::wstring name;
    std::wstring token;
};

class ArcClient {
private:
    SOCKET client = -1;

public:
    ~ArcClient();

    void Connect(const char* host, const char* port);

    void ReadUserAccount(ArcUserAccount& account);
};
