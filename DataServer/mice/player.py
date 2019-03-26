
class Player:
    def __init__(self, client, user):
        self.exp = 0
        self.rank = 1
        self.client = client
        self.id = int(user['id'])
        self.name = user['nickname']
        self.device_id = 'noString'

    def auth_response(self):
        return ['.auth', {
            'time': 1,
            'moid': self.id,
            'exp': self.exp,
            'rank': self.rank,
            'name': self.name,
            'deviceid': self.device_id,
            'gameid': 'ggc', # 'ggl' on retail
            'version': '298288', # '326539' on retail
            'xmpp': { 'host': '127.0.0.1' }
        }]
