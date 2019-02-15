# GiganticEmu
Experimenting with recreating a custom client for Gigantic. This repo is just a reference implementation for building up on and documenting the existing work done by Gabs.

## Architecture
The game is required to be patched in a few ways in order to be playable. Each (soon to be) root folder in the repo corresponds to a required component in the architecture that is in need of patching or rewrite.

### ArcSDK
The Gigantic client uses `arksdk.dll` in order to obtain user information, friends, and a link to the [Mice Server](###miceserver). In order for the client to connect to the custom server (instead of Arc/Motiga servers), a different dll needs to be compiled with the code in the `ArcSDK` folder and the resulting binary (`arksdk.dll`) replacing the existing one in Gigantic's folder.

### Launcher
This embodies a modified launcher used to launch Gigantic rather than relying on Arc's laucher. The launcher itself takes in:
* a server address to connect to
* the clients username
* the clients password

and sends this information to the [Data Server](###dataserver) located at the server address to retrieve both 1) an authentication token and 2) the address of the [Mice Server](###miceserver).

The launcher now launches the game (Gigantic, usually located in `Binaries\\Win64\\RxGame-Win64-Shipping.exe`) as well as a tcp server. The patched ArcSDK in the game connects to this tcp server and receives the token + user info + mice server address which it will use for player, lobby and party information.

### DataServer
The data server (from what I can tell) is reponsibly for handling sign-in information and responding with authenticated information (username, token, friends, etc.) as well as the server address of the [Mice Server](###miceserver). It seems to also handle match history, leaderboards and cdn inventory items? (More info is needed here)

### MiceServer
The mice server is in charge of party matches, queuing up and starting games. Gigantic, using the data received from `ArcSDK <- Launcher <- DataServer` connects to the mice server through TCP and has the option to utilize Salsa/(12 or 15) for encryption. Once a party and match are found, each client for the match is sent some session info which contains the address of the [Match Server](###matchserver) used to communicate game data while playing with each other. Some of the features the mice server handles are:

* Party Queuing/Messaging/Hosting/Inviting
* Friend List/Request/Response/Notification
* Player Status/Messaging/Inventory/Shop/Lobbying

### MatchServer
TODO: needs to be documented (currently, gabs is working on reverse engineering it)
