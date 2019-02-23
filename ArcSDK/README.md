# ArcSDK
Gigantic uses `ArcSDK.dll` to communicate with the arc client. Originally it was done through named pipes, but this is to patch it so that it communicates with an external server instead (details found inside Main.cpp). Many features of the dll seem to be game independent.

## Building
In order to build it, one must have Visual Studio installed then open a "Developer Command Prompt For VS 2017" which can be found by searching in the Start Menu. Using that command prompt, execute msbuild in this folder:
```bash
msbuild ArcSDK.vcxproj /p:configuration=debug
```
The resulting 2 files, `ArcSDK.dll` and `ArcSDK.pdb` will be located in a newly created directory `x64/debug`. These need to be copied into and replace the existing ones in Gigantics binaries.

### Notes
Exported symbols
```
CC_SetViewableRect
CC_RunCallbacks
CC_GetAccountName
CC_GetArcID
CC_GetArcRunningMode
ArcFriends
CC_LaunchClient
CC_Init
CC_UnInit
CC_GetTokenEx
CC_RegisterCallback
CC_GetSteamTicket
CC_GotoUrlInOverlay
?Get@ArcID@CC_SDK@@QEBAPEA_WXZ
?Set@ArcID@CC_SDK@@QEAAXPEB_W@Z
??4ArcID@CC_SDK@@QEAAAEAV01@AEBV01@@Z
??1ArcID@CC_SDK@@QEAA@XZ
??0ArcID@CC_SDK@@QEAA@XZ
CC_UnregisterCallback
CC_InstalledFromArc
CC_GetLaunchedParameter
CC_GetNickName
```