# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from string import Template
import datetime

class TestCaseTemplateCodeGenerator(codeGenerator):

    def __init__ (self, function=None):
        super().__init__(function=None)
        self.templateFile = 'TestCaseTemplate.template' 
        self.fileOut = "TestCase.prw"
        self.srcPath = settings.PATH_SRC_TEST_CASES
        return

    def setFileOut(self):
        self.fileOut = "TestCase.prw"
    
    def getVariables(self,storagePathFile):
        variables = { }
        return variables
    
    def build(self):
        
        for files in os.walk(settings.PATH_SRC_ANALISE):
            for file in files[2]:
                fonte = file[:-4]
                print("[" + datetime.datetime.now().ctime() + "]Gerando testeCase para o arquivo " + fonte)
                fileIn = open(os.path.join(settings.PATH_TEMPLATE, self.templateFile))
                temp = Template(fileIn.read())
                variables = {
                            'fonte': fonte,
                        }
                result = temp.substitute(variables)
                f = open(os.path.join(self.srcPath, fonte + self.fileOut) , "w+")
                f.write(result)
                f.close()