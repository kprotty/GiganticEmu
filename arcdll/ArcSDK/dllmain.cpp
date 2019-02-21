// dllmain.cpp : Defines the entry point for the DLL application.

#include "stdafx.h"
#include "ArcSDK.h"
#include <iostream>
#include <stdio.h>
#include <easyhook.h>

#define EXTERN_DLL_EXPORT extern "C" __declspec(dllexport)

Account g_acc;
std::string g_server;

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		{
		//auth_server_hook();
		GameSocket sock;
		sock.getAccount(g_acc, g_server);
		sock.close();
		break;
		}
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

// Client function GetAddressInfo reads key 'AuthUrlPrefix' from '.\RxGame\Config\DefaultEngine.ini'
// TODO: hook function use domain specified by launcher
void auth_server_hook()
{
}

namespace CC_SDK
{
	EXTERN_DLL_EXPORT class ArcID
	{
		wchar_t *Internalstring;

	public:
		wchar_t *Get()
		{
			return Internalstring;
		}
	};
}

EXTERN_DLL_EXPORT void *ArcFriends()
{
	return nullptr;
}
EXTERN_DLL_EXPORT void *Matchmaking()
{
	return nullptr;
}
EXTERN_DLL_EXPORT void *Networking()
{
	return nullptr;
}

EXTERN_DLL_EXPORT int64_t CC_GetAccountName(const wchar_t *State, wchar_t *Buff, uint32_t Bufflen)
{
	std::wstring wide = std::wstring(g_acc.accountname.begin(), g_acc.accountname.end());
	const wchar_t* name = wide.c_str();

	std::wmemset(Buff, 0, Bufflen);
	std::wmemcpy(Buff, name, wide.length());
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetArcID(int64_t a1, int64_t a2)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetArcRunningMode(uint32_t *Mode)
{
	*Mode = 0;
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetLaunchedParameter(const wchar_t *a1, int a2, wchar_t *Buff, signed int Bufflen)
{
	/* Retail dll writes version|username|lang to buffer, isn't necessary.
	*/
	const wchar_t* response = L"ggl";
	std::wmemset(Buff, 0, Bufflen);
	std::wmemcpy(Buff, response, sizeof(response));
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetNickName(const wchar_t *State, wchar_t *Buff, uint32_t Bufflen)
{
	std::wstring wide = std::wstring(g_acc.nickname.begin(), g_acc.nickname.end());
	const wchar_t* nick = wide.c_str();

	std::wmemset(Buff, 0, Bufflen);
	std::wmemcpy(Buff, nick, wide.length());
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetSteamTicket(int64_t a1, unsigned int *a2)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetToken(int64_t a1, int64_t a2, int64_t a3, unsigned int *a4, unsigned int *a5)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetTokenEx(const wchar_t *a1, const wchar_t *a2, const wchar_t *a3, wchar_t *Buff, uint32_t Bufflen, uint32_t a6)
{
	/* Authentication token that will be sent from the game client to authentication server.
	Usually this token will be acquired from the arc client which launches the game with the token argument.
	Was formated like so: "XHj3VK1webHFQchh"
	*/

	std::wstring wide = std::wstring(g_acc.token.begin(), g_acc.token.end());
	const wchar_t* token = wide.c_str();

	std::wmemset(Buff, 0, Bufflen);
	std::wmemcpy(Buff, token, wide.length());
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GetUserAvatarLink(int64_t a1, wchar_t *a2, unsigned int *a3, int a4)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_GotoUrlInOverlay(int64_t a1, const wchar_t *a2)
{
	return 0;
}

EXTERN_DLL_EXPORT wchar_t *CC_Init(int64_t a1, int64_t a2, uint32_t *a3)
{
	// Never figured out what this was for, this string remains the same for the release build.
	static wchar_t Internalstate[]{ L"This is our secret, probably encrypted, internal state.." };
	return Internalstate;
}

EXTERN_DLL_EXPORT int64_t CC_InstalledFromArc(unsigned int a1, unsigned int a2)
{
	/* Checks if installed on Arc.
	0x4CA00 = Ok
	*/
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_InviteFriendInOverlay(int64_t a1, int64_t *a2)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_LaunchClient(const wchar_t *a1, int a2, int64_t a3)
{
	/* 
	Checks arc status, returns int code, 0xE0000019 = ok
	For some reason the "Gigantic-Core_de" build requires a return value of 0 instead
	*/
	//return 0;
	return 0xE0000019;
}

// Client registers callback pointer and periodically checks for functions, probably used for friend requests in game?
// Not needed, not implemented.
EXTERN_DLL_EXPORT int64_t CC_RegisterCallback()
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_RunCallbacks()
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_SetViewableRect(const wchar_t *a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_ShowOverlay(int64_t a1, unsigned int a2)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_UnInit(const wchar_t *a1)
{
	return 0;
}

EXTERN_DLL_EXPORT int64_t CC_UnregisterCallback()
{
	return 0;
}

