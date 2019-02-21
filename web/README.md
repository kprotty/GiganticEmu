# Web

Facilitates http password auth and some client APIs, with a finished match server/ functioning proxy it would become possible to retrieve match statistics ect. This also serves as a frontend to those features.

## Client API
`cdn.html` contains a json object containing a list of all store items and values.
`/auth/0.0/arc/auth` hardcoded token auth uri, responds with information required to connect to the mice server.
`users/` Since the Arc launcher has been completely replaced the domains are no longer hardcoded, instead we're just using devise authentication here. (with a super dodgey token)
