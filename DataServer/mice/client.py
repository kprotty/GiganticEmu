from os import getenv
from array import array
from json import loads, dumps
from asyncio import ensure_future, Protocol

from .salsa import Salsa
from .player import Player
from .handler import MiceHandler

class MiceClient(Protocol):
    def __init__(self, server):
        try:
            self.handler = MiceHandler(self)
            self.server = server
            self.player = None
            self.buffer = b''
        except Exception as ex:
            server.logger.warn('Failed to create MiceClient:' + repr(ex))

    def connection_made(self, transport):
        self.transport = transport

    def data_received(self, data):
        ensure_future(self.receive_data(data))

    def send_encoded(self, data):
        data = self.salsa_out.encrypt(dumps(data).encode())
        self.transport.write(self.pack_w(len(data)) + data)

    async def receive_data(self, data):
        if not self.player:
            return await self.authenticate(data)
        for (command, payload, id) in self.parse_commands(data):
            result = await self.handler.process(command, payload)
            if result:
                self.send_encoded([result, id])

    async def authenticate(self, data):
        # extract the token from the first auth message
        # it uses a different amount of SALSA rounds
        salsa = Salsa(getenv('SALSA_CK'), 12)
        data = salsa.decrypt(data[1:]).decode()
        token = loads(data)[0]

        # get the user & close connection on invalid token
        async with self.server.pool.acquire() as conn:
            user = await conn.fetchrow('SELECT * from users where token=$1', token)
        if not user:
            return self.transport.close()

        # complete authentication & send auth_response
        self.player = Player(self, user)
        self.salsa_in = Salsa(getenv('SALSA_SCK'), 16)
        self.salsa_out = Salsa(getenv('SALSA_SCK'), 16)
        self.send_encoded(self.player.auth_response())

    @staticmethod
    def unpack_w(data):
        ''' Equivalent to ruby's String.unpack('w') '''
        length = 0
        while data:
            length = (length << 7) | (data[0] & 0x7f)
            data = data[1:]
        return length

    @staticmethod
    def pack_w(length):
        ''' Equivalent to ruby's Array.pack('w') '''
        output = []
        while length:
            output.append((length & 0x7f) | (0x80 if output else 0))
            length >>= 7
        if not output:
            output = [0]
        output.reverse()
        return array('B', output).tostring()

    def parse_commands(self, data):
        self.buffer += data
        while self.buffer:
            # read the command length from the bytes
            if self.buffer[0] == 0xff:
                command_length = self.unpack_w(self.buffer[:3])
                next_buffer = self.buffer[3:]
            elif self.buffer[0] >= 0x80:
                command_length = self.unpack_w(self.buffer[:2])
                next_buffer = self.buffer[2:]
            else:
                command_length = self.buffer[0]
                next_buffer = self.buffer[1:]

            # theres not enough data to satisfy the length, come back next time
            if command_length > len(next_buffer):
                return

            # decrypt, JSON parse and yield a mice command then move on 
            command = loads(self.salsa_in.encrypt(next_buffer[:command_length]))
            yield (command[0], command[1], command[2])
            self.buffer = next_buffer[command_length:]
