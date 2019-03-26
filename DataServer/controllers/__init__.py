from os import getenv
from glob import glob
from sanic.response import json
from sanic.views import HTTPMethodView
from pkgutil import extend_path, walk_packages

# HTTP Rest API view model needed for handlers
class Controller(HTTPMethodView):
    pass

# import all submodules in this folder
__path__ = extend_path(__path__, __name__)
for _import, module, _ispkg in walk_packages(path=__path__):
    __import__(__name__ + '.' + module)
