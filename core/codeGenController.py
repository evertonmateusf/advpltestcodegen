# -*- coding: utf-8 -*-
import csv
import os
import re
import sys
from pathlib import Path
from core.codeGenerators import (TestCaseCodeGenerator,
                  TestGroupCodeGenerator, TestSuiteCodeGenerator,
                  )
import settings
import datetime

class codeGenController:

    def __init__(self):
        return

    def getGenerators(self):
        generators = []
        generators.append(TestCaseCodeGenerator.TestCaseCodeGenerator())
        generators.append(TestGroupCodeGenerator.TestGroupCodeGenerator())
        generators.append(TestSuiteCodeGenerator.TestSuiteCodeGenerator())

        return generators

    def build(self):

        generators = self.getGenerators()
        for generator in generators:
            generator.build()
        self.cleanTemp()
        return
    
    def cleanTemp(self):
        print("[" + datetime.datetime.now().ctime() + "]Deletando arquivos temporarios")
        for files in os.walk(settings.PATH_TEMP):
            for file in files[2]:
                storagePathFile = os.path.join(settings.PATH_TEMP,file )
                if os.path.isfile(storagePathFile):
                    os.remove(storagePathFile)
         

    