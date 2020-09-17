# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from string import Template
import datetime

class TestCaseTemplateCodeGenerator(codeGenerator):

    def __init__ (self, outputPath=None):
        super().__init__(outputPath=None)
        self.outputPath = settings.PATH_SRC_TEST_CASES if outputPath==None else outputPath
        if not os.path.isdir(self.outputPath): os.mkdir(self.outputPath)
        self.templateFile = 'TestCaseTemplate.template' 
        self.fileOut = "TestCase.prw"
        return

    def setFileOut(self):
        self.fileOut = "TestCase.prw"
    
    def getVariables(self):
        variables = { }
        return variables
    
    def build(self):
        if not os.path.isdir(self.outputPath): os.mkdir(self.outputPath)
        for files in os.walk(self.inputpath):
            for file in files[2]:
                filepath = os.path.join(self.outputpath, file)
                self.processFile(filepath)

    def processFile(self, filepath):
        file = os.path.basename(filepath)
        fonte = file[:-4]
        print("[" + datetime.datetime.now().ctime() + "]Gerando testeCase para o arquivo " + fonte)
        fileIn = open(os.path.join(settings.PATH_TEMPLATE, self.templateFile))
        temp = Template(fileIn.read())
        variables = {
                    'fonte': fonte,
                }
        result = temp.substitute(variables)
        f = open(os.path.join(self.outputPath, fonte + self.fileOut) , "w+")
        f.write(result)
        f.close()