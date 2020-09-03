# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core import commandController, codeGenController
from string import Template


class codeGenerator():

    company = settings.PROTHEUS_ENVIORMENT['default']['COMPANY']
    filial = settings.PROTHEUS_ENVIORMENT['default']['FILIAL']
    columnsToAdd = []
    templateFile = '' 
    fileOut = ''
    srcPath = ''

    def __init__ (self, function=None):
        self.function = function
        self.variables = []
        self.templatePath = settings.PATH_TEMPLATE
        return

    def setFunction(self, function):
        self.function = function
        return

    def addVariable(self, variable):
        self.variables.append(variable)
        return
    
    def writeFile(self, variables):
        fileIn = open(os.path.join(self.templatePath, self.templateFile))   
        temp = Template(fileIn.read())
        result = temp.substitute(variables)

        f = open(os.path.join(self.srcPath, self.fileOut) , "w+")
        f.write(result)
        f.close()
        return
    
    def getVariables(self,storagePathFile):
        return('','')
        
    def setFileOut(self):
        return

    def build(self):
        self.setFileOut()
        storagePathFile = os.path.join(settings.PATH_FILESTORAGE ,  "functions.entity")
        exists = os.path.isfile(storagePathFile) 
        if exists:
            variables = self.getVariables(storagePathFile)
            self.writeFile(variables)
        return