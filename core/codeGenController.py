# -*- coding: utf-8 -*-
import csv
import os
import re
import sys
from pathlib import Path
from core.codeGenerators import WsClientTestCaseCodeGenerator, TestCaseTemplateCodeGenerator, TestGroupCodeGenerator, TestSuiteCodeGenerator
import settings
import datetime

class codeGenController:

    def __init__(self):
        self.inputfile = ''
        self.inputpath = settings.PATH_SRC_ANALISE
        self.outputpath = settings.PATH_SRC
        if not os.path.isdir(settings.PATH_TEMP): os.mkdir(settings.PATH_TEMP)
        return

    def getGenerators(self):
        generators = []
        # generators.append(TestCaseCodeGenerator.TestCaseCodeGenerator())
        generators.append(WsClientTestCaseCodeGenerator.WsClientTestCaseCodeGenerator(os.path.join(self.outputpath, "cases")))
        generators.append(TestGroupCodeGenerator.TestGroupCodeGenerator(os.path.join(self.outputpath, "group")))
        generators.append(TestSuiteCodeGenerator.TestSuiteCodeGenerator(os.path.join(self.outputpath, "suite")))

        return generators
    
    def getTestTemplateGenerators(self):
        generators = []
        generators.append(TestCaseTemplateCodeGenerator.TestCaseTemplateCodeGenerator(os.path.join(self.outputpath, "cases")))
        generators.append(TestGroupCodeGenerator.TestGroupCodeGenerator(os.path.join(self.outputpath, "group")))
        generators.append(TestSuiteCodeGenerator.TestSuiteCodeGenerator(os.path.join(self.outputpath, "suite")))

        return generators
        
    def processGenerators(self,generators):
        for generator in generators:
            generator.inputpath = self.inputpath
            if self.inputfile == '':
                generator.build()
            else:
                generator.processFile(self.inputfile)
        self.cleanTemp()

    def build(self):
        self.processGenerators(self.getGenerators())
    
    def buildTemplate(self):
        self.processGenerators(self.getTestTemplateGenerators())

    def cleanTemp(self):
        print("[" + datetime.datetime.now().ctime() + "]Deletando arquivos temporarios")
        for files in os.walk(settings.PATH_TEMP):
            for file in files[2]:
                storagePathFile = os.path.join(settings.PATH_TEMP,file )
                if os.path.isfile(storagePathFile):
                    os.remove(storagePathFile)
         

    