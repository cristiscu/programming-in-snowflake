import os

def getFullPath(filename):
    #return f"{os.path.dirname(__file__)}/{filename}"
    crtdir = os.path.dirname(__file__)
    pardir = os.path.abspath(os.path.join(crtdir, os.pardir))
    return f"{pardir}/{filename}"
