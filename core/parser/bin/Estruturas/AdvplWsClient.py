# -*- coding: cp1252 -*-

class AdvplWsClient:

    type  = ''
    name  = ''
    parameters = []
    variables = []
    
    def __init__ (self, name, type):
        self.name = name
        self.type = type
        self.methods = []
        self.properties = []
        return

    def setType(self, type):
        self.type = type
        return

    def addMethod(self, method):
        self.methods.append(method)
        return
   
    def addProperty(self, property):
        self.properties.append(property)
        return
    