from controllers import Controller
from mice.server import MiceServer

from os import getenv
from sanic import Sanic
from sanic.log import logger
from dotenv import load_dotenv
from asyncpg import create_pool
from sanic.response import json
from sanic.exceptions import NotFound

if __name__ == '__main__':
    load_dotenv()
    pool = None

    # setup the http server & the cdn static json
    app = Sanic(__name__)
    app.static('cdn', 'cdn.json')

    # handle 404 HTTP requests
    @app.exception([NotFound])
    def not_found(request, exception):
        logger.warning(f'Unhandled route {request.method} {request.path}')
        return json({'error': 'Unexpected route'}, status=404)

    # create the database connection pool and mice server
    @app.listener('before_server_start')
    def init(sanic, loop):
        global pool
        pool = loop.run_until_complete(create_pool(
            loop=loop,
            host=getenv('DB_HOST'),
            port=int(getenv('DB_PORT')),
            user=getenv('DB_USER'),
            password=getenv('DB_PASS'),
            database=getenv('DB_NAME'),
            min_size=int(getenv('DB_POOL', 4)),
        ))
        loop.create_task(MiceServer.start(loop, pool))

    # wrap the HttpControllers to take in the database connection pool
    def with_pool_decorator(controller):
        def decorator(*args, **kwargs):
            args = (*args, pool)
            return controller(*args, **kwargs)
        return decorator

    # load all controlers inside the controllers/ folder (check out auth.py as an example)
    Controller.decorators = [with_pool_decorator]
    for controller in Controller.__subclasses__():
        app.add_route(controller.as_view(), controller.__route__)

    # start the http server
    app.run(
        host=getenv('HTTP_HOST'),
        port=int(getenv('HTTP_PORT'))
    )

