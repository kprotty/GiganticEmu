# Data Server
In order to connect to the data server, one must change certain values in the `RxGame\Config\DefaultEngine.ini` file:

```ini
[MotigaAuthIntegration]
AuthUrlPrefix=http://localhost:12000/

[ArcIntegration]
AuthUrlPrefix=http://localhost:12000/
```

Elixir can be installed by following instructions on their main website. (Not for Ubuntu/Debian, the installation of the whole Erlang/OTP platform is not necessarily required (although the deb file is). Instead, simply `sudo apt-get install elixir erlang-dev`)