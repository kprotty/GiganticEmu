import logging
from os import getenv
from sanic.log import logger
from .client import MiceClient

class MiceServer:
    def __init__(self, loop, pool):
        self.loop = loop
        self.pool = pool
        self.logger = logger

    @staticmethod
    async def start(loop, pool):
        host = getenv('MICE_HOST')
        port = int(getenv('MICE_PORT'))
        
        server = MiceServer(loop, pool)
        server.logger.info(f'Starting MICE server @ {host}:{port}')

        await loop.create_server(lambda: MiceClient(server), host=host, port=port)
