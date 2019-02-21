# MiceProtocol

Mice is the internal name for the Gigantic protocol that handles in game activities, including matchmaking, store purchases, parties ect.

## Encoding and Encryption
packets are variable length prepended, generally an array consisting of two/three elements where client packets contain an identifier.

If token auth server responds with non null `ck` and `sck` values, these keys will be used to encrypt packets with Salsa20. First authentication packet uses Salsa20/12 with `ck` key and no nonce, the following packets use the `sck` key with 16 rounds.
