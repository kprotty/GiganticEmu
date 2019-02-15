# ArcSDK
Gigantic uses `ArcSDK.dll` to communicate with the arc client. Originally it was done through named pipes, but this is to patch it so that it communicates with an external server instead (details found inside main.cpp). Many features of the dll seem to be game independent.

## Building
Personally, I (Protty) use cmake & ninja. But feel free to add different instructions here. If you wish to use MSVC for the compiler, make sure to run the commands in a Visual Studio Developer Command Prompt.

- **Building with CMake**:
    * `mkdir build && cd build`
    * **Using MSBuild**:
        * `cmake .. && msbuild ArcSDK.sln`
    * **Using Ninja (preffered)**:
        * `cmake -GNinja .. && ninja`
