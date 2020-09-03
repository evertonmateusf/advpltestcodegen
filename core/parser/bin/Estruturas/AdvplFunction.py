# -*- coding: cp1252 -*-

class AdvplFunction:

    type  = ''
    name  = ''
    parameters = []
    variables = []
    
    def __init__ (self, name):
        self.name = name
        self.type = 'FUNCTION'
        self.parameters = []
        self.variables = []
        return

    def setType(self, type):
        self.type = type
        return

    def addVariable(self, variable):
        self.variables.append(variable)
        return

    def addParameter(self, parameter):
        self.parameters.append(parameter)
        return
    