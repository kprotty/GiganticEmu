# GiganticEMU

Forewarning I am not a developer, just another hacker, the quality of this project likely reflects that :P
This is a quick proof of concept demonstrating the core components, it's my hope that people with development experience can rebase the whole thing into something functional. There are many components and features missing, while I have made progress on those components I have nothing I'm willing to show at the moment, for the time being this would allow a competent developer to create a core private server.


## Architecture
In order to replace the deprecated components of the Gigantic client, several components must be replaced. This includes the arc launcher, `arcsdk.dll` library, mice protocol, http server and finally the match server.

The launcher authenticates via http with password and retrieves a token, this token is retrieved in game by either command line argument or through the `arcsdk.dll`, upon pressing play the token is sent via http which responds with the ip and port of the mice server.

Of course I still lack the match server, for the time being the core client test binary can be used to create matches.
