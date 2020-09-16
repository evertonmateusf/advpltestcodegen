# -*- coding: cp1252 -*-
import codecs
from antlr4.InputStream import InputStream

class CaseInsensitiveInputStream (InputStream):

    def _loadString(self):
        self._index = 0
        self.data = [ord(c) for c in self.strdata.upper()]
        self._size = len(self.data)

class CaseInsensitiveFileStream(CaseInsensitiveInputStream):

    def __init__(self, fileName:str, encoding:str='ascii', errors:str='strict'):
        super().__init__(self.readDataFrom(fileName, encoding, errors))
        self.fileName = fileName

    def readDataFrom(self, fileName:str, encoding:str, errors:str='strict'):
        # read binary to avoid line ending conversion
        with open(fileName, 'rb') as file:
            bytes = file.read()
            return codecs.decode(bytes, encoding, errors)
