# ArcSDK
Gigantic uses `ArcSDK.dll` to communicate with the arc client. Originally it was done through named pipes, but this is to patch it so that it communicates with an external server instead (details found inside main.cpp). Many features of the dll seem to be game independent.

## Building
Personally, i (Protty) use cmake & ninja. But feel free to add different instructions here

### Building with CMake
* `mkdir build`
* `cd build`
#### Using MSVC:
    * `cmake ..`
    * `msbuild ArcSDK.sln`
#### Using Ninja (preffered):
    * `cmake -GNinja ..`
    * `ninja`
