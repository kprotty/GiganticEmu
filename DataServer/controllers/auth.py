from base64 import b64encode as b64
from . import getenv, json, Controller

class ArcAuth(Controller):
    __route__ = '/auth/0.0/arc/auth'

    async def post(self, request, pool):
        # extract form data
        if 'arc_token' not in request.form:
            return json({'error': 'arc_token not found'}, status=401)
        version = int(request.form.get('version', '16897'))
        token = request.form.get('arc_token')

        # fetch the associated user
        async with pool.acquire() as conn:
            user = await conn.fetchrow('SELECT * from users where token=$1', token)
        if not user:
            return json({'error': 'Invalid arc_token'}, status=400)

        # create the response
        return json({
            'result': 'ok',
            'auth': token,
            'token': token,
            'name': user['nickname'],
            'username': user['email'],
            'buddy_key': False,
            'founders_pack': True,
            
            'host': getenv('MICE_HOST'),
            'port': int(getenv('MICE_PORT')),
            'ck': b64(b'\x00\x00' + getenv('SALSA_CK').encode()).decode(),
            'sck': b64(b'\x00\x00' + getenv('SALSA_SCK').encode()).decode(),

            'flags': '', # unknown string
            'xbox_preview': False,
            'accounts': 'accmple', # unknown string
            'mostash_verbosity_level': 0,
            'min_version': version,
            'current_version': version, # game doesnt event check

            'catalog': {
                'cdn_url': f"http://{getenv('HTTP_HOST')}:{getenv('HTTP_PORT')}/cdn",
                'sha256_digest': '04cd2302958566b0219c78a6066049933f5da07ec23634f986194ba6e7c9094e'
            },
            'announcements': {
                'message': 'serverMessage',
                'status': 'serverStatus'
            },
            'voice_chat': {
                'baseurl': 'http://127.0.01/voice.html',
                'username': 'sup:.username.@voice.sipServ.com',
                'token': 'sipToken'
            },
        })
