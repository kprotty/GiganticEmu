import time

def mice_command(command_name):
    def decorator(function):
        function.__command__ = command_name
        return function
    return decorator

class MiceHandler:
    def __init__(self, client):
        self.client = client
        self.command_handler = dict([
            (getattr(self, f).__command__, getattr(self, f))
            for f in dir(self) if hasattr(getattr(self, f), '__command__')
        ])

    # handle command dispatch
    async def process(self, command, payload):
        handler = self.command_handler.get(command)
        if handler:
            return await handler(payload)
        self.client.server.logger.info(f'Unhandled MICE command: {command}')
        return None

    @mice_command('player.getservertime')
    async def get_server_time(self, payload):
        return [{'datetime': time.strftime('%Y.%m.%d-%H:%M:%S')}]

    '''
    TODO: Implement more commands:
    https://github.com/kprotty/GiganticEmu/blob/gabs/mice/lib/miceFunctions.rb
    https://github.com/kprotty/GiganticEmu/blob/gabs/mice/lib/miceServer.rb#L189
    '''