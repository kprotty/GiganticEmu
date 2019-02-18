# Data Server
In order to connect to the data server, one must change certain values in the `RxGame\Config\DefaultEngine.ini` file:

```ini
[MotigaAuthIntegration]
AuthUrlPrefix=http://localhost:12000/

[ArcIntegration]
AuthUrlPrefix=http://localhost:12000/
```

PostgresSQL: postgres@localhost:5432