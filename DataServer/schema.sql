CREATE TABLE [users] (
    [id] SERIAL PRIMARY KEY,
    [email] VARCHAR NOT NULL,
    [token] VARCHAR NOT NULL,
    [nickname] VARCHAR NOT NULL,
    [password] VARCHAR NOT NULL
);