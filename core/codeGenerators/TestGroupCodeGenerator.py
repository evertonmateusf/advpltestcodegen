# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from string import Template

class TestGroupCodeGenerator(codeGenerator):

    def __init__ (self, function=None):
        super().__init__(function=None)
        self.templateFile = 'TestGroup.template' 
        self.srcPath = settings.PATH_SRC_TEST_GROUP
        return

    def setFileOut(self):
        self.fileOut = "FunctionTestGroup.prw"
    
    def getVariables(self,storagePathFile):
        variables = { }
        # variables = { 
        #         'className': self.shortName, 
        #         'entity' : self.entity,
        #         'prefix' : self.prefix,
        #     }
        return variables
