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
    outputPath = ''
    inputfile = ''
    inputpath = settings.PATH_SRC_ANALISE
    outputpath = settings.PATH_SRC

    def __init__ (self, outputPath=None):
        self.outputPath = outputPath
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

        f = open(os.path.join(self.outputPath, self.fileOut) , "w+")
        f.write(result)
        f.close()
        return
    
    def getVariables(self):
        return {}
        
    def setFileOut(self):
        return

    def build(self):
        if not os.path.isdir(self.outputPath): os.mkdir(self.outputPath)
        self.setFileOut()
        self.writeFile(self.getVariables())
        return