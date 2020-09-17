# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from core.codeGenerators.CaseInsensitiveInputStream import CaseInsensitiveFileStream
from string import Template
from core.parser.bin.AdvplKeyPrinter import AdvplKeyPrinter
from core.parser.bin.AdvplLexer import AdvplLexer
from core.parser.bin.AdvplParser import AdvplParser
from antlr4 import *
import datetime

class TestCaseCodeGenerator(codeGenerator):

    def __init__ (self, outputPath=None):
        super().__init__(outputPath=None)
        self.outputPath = settings.PATH_SRC_TEST_CASES if outputPath==None else outputPath
        if not os.path.isdir(self.outputPath): os.mkdir(self.outputPath)
        self.templateFile = 'TestCase.template'
        self.fileOut = "TestCase.prw"
        return

    def setFileOut(self):
        self.fileOut = "TestCase.prw"

    def build(self):
        if not os.path.isdir(self.outputPath): os.mkdir(self.outputPath)
        for files in os.walk(self.inputpath):
            for file in files[2]:
                filepath = os.path.join(self.inputpath, file)
                self.processFile(filepath)

    def processFile(self, filepath):
        file = os.path.basename(filepath)
        fonte = file[:-4]
        print("[" + datetime.datetime.now().ctime() + "]Lendo arquivo " + fonte)
        try:
            input_stream = CaseInsensitiveFileStream(filepath,"cp1252")
            lexer = AdvplLexer(input_stream)
            stream = CommonTokenStream(lexer)
            print("[" + datetime.datetime.now().ctime() + "]Fazendo parse do arquivo " + fonte)
            parser = AdvplParser(stream)
            tree = parser.program()
            printer = AdvplKeyPrinter()
            walker = ParseTreeWalker()
            print("[" + datetime.datetime.now().ctime() + "]Analisando arquivo " + fonte)
            walker.walk(printer, tree)
            print("[" + datetime.datetime.now().ctime() + "]Gerando caso de teste do arquivo " + fonte)
            self.applyFileRules(printer,fonte)
        except:
            print("[" + datetime.datetime.now().ctime() + "]Erro ao processar o arquivo " + fonte)
            print(sys.exc_info()[0])
        self.cleanTemp()

    def printList(self, list):
        for item in list:
            print(item)

    def makeTempFile(self, variables, file,template):
        fileIn = open(os.path.join(settings.PATH_TEMPLATE, template))
        temp = Template(fileIn.read())
        result = temp.substitute(variables)
        f = open(os.path.join(settings.PATH_TEMP, file + ".tmp") , "w+")
        f.write(result)
        f.close()
    
    def finishTestCase(self,fonte):
        header = open(os.path.join(settings.PATH_TEMP, fonte + '.' + 'TestCase.Header.tmp')).read()
        setupClass = open(os.path.join(settings.PATH_TEMP, fonte + '.' + 'TestCase.SetupClass.tmp')).read()
        methodName = open(os.path.join(settings.PATH_TEMP, fonte + '.' + 'TestCase.MethodName.tmp')).read()
        addHeader = open(os.path.join(settings.PATH_TEMP, fonte + '.' + 'TestCase.AddHeader.tmp')).read()
        addMethods = open(os.path.join(settings.PATH_TEMP, fonte + '.' + 'TestCase.AddMethod.tmp')).read()
        testes = ''
        testesWsClient = ''
        for files in os.walk(settings.PATH_TEMP):
            for file in files[2]:
                storagePathFile = os.path.join(settings.PATH_TEMP,file )
                exists = os.path.isfile(storagePathFile)
                if exists:
                    with open(storagePathFile) as datafile:
                        if self.getTempFileName() in file:
                            testes += datafile.read()
        result = header+methodName+addHeader+addMethods+setupClass+testes
        
        f = open(os.path.join(self.outputPath, fonte + self.fileOut) , "w+")
        f.write(result)
        f.close()
        return

    def cleanTemp(self):
        print("[" + datetime.datetime.now().ctime() + "]Deletando arquivos temporarios")
        for files in os.walk(settings.PATH_TEMP):
            for file in files[2]:
                storagePathFile = os.path.join(settings.PATH_TEMP,file )
                if os.path.isfile(storagePathFile):
                    os.remove(storagePathFile)

    def getVariables(self):
        return {}

    def getTypeValue(self,typeValue):
        value = "Nil"

        if typeValue == "C":
            value = "'string'"
        elif typeValue == "D":
            value = "stod('')"
        elif typeValue == "N":
            value = "0"
        elif typeValue == "A":
            value = "{}"
        elif typeValue == "L":
            value = ".F."
        elif typeValue == "X":
            value = "'string'"
        return value

    def getPropertyTypeValue(self,typeValue):
        value = "Nil"

        if typeValue == "STRING":
            value = "'string'"
        elif typeValue == "DATE":
            value = "stod('')"
        elif typeValue == "FLOAT" or typeValue == "INTEGER" or typeValue == "INT" or typeValue == "NUMBER" or typeValue == "NUMERIC":
            value = "0"
        elif typeValue == "ARRAY":
            value = "{}"
        elif typeValue == "BOOLEAN":
            value = ".F."
        return value
