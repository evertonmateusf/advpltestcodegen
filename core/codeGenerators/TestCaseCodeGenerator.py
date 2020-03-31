# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from string import Template
from core.parser.bin.AdvplKeyPrinter import AdvplKeyPrinter
from core.parser.bin.AdvplLexer import AdvplLexer
from core.parser.bin.AdvplParser import AdvplParser
from antlr4 import *

class TestCaseCodeGenerator(codeGenerator):

    def __init__ (self, function=None):
        super().__init__(function=None)
        self.templateFile = 'TestCase.template'
        self.srcPath = settings.PATH_SRC_TEST_CASES
        self.fileOut = "TestCase.prw"
        return

    def setFileOut(self):
        self.fileOut = "TestCase.prw"

    def build(self):

        for files in os.walk(settings.PATH_SRC_ANALISE):
            for file in files[2]:
                methodName = []
                addMethod = []
                fonte = file[:-4]
                print("[" + datetime.datetime.now().ctime() + "]Lendo arquivo " + fonte)
                input_stream = CaseInsensitiveFileStream(settings.PATH_SRC_ANALISE+"\\"+file,"cp1252")
                #input_stream = FileStream(settings.PATH_SRC_ANALISE+"\\"+file)
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
                for function in printer.funcoes:
                    if function.type.upper() != 'STATIC':
                        print("[" + datetime.datetime.now().ctime() + "]Gerando caso de teste da funcao " + function.name)
                        localVars = []
                        params = []
                        functionCall = ''
                        methodName.append(''.rjust(4)+"METHOD "+function.name+"()")
                        addMethod.append(''.rjust(4)+"self:AddTestMethod( '"+function.name+"',,'Teste da funcao "+function.name+".' ) ")
                        for parameter in function.parameters:
                            #print(parameter)
                            localVars.append(''.rjust(4)+"Local " + parameter + " := " + self.getTypeValue(parameter[0:1].upper()) )
                            params.append(parameter)
                        #for variable in function.variables:
                            #print(variable)
                        functionCall = function.name + "(" + ",".join(params) +")"
                        variables = {
                                'fonte': fonte,
                                'functionName': function.name,
                                'functionsCall': functionCall,
                                'localVars': '\n'.join(localVars),
                            }
                        self.makeTempFile(variables,fonte + '.' + function.name + '.TestFunction','TestFunction.template')
                    variables = {
                            'fonte': fonte,
                            'methodName': '\n'.join(methodName),
                            'addMethod': '\n'.join(addMethod)
                        }
                    self.makeTempFile(variables,fonte + '.' + 'TestCase.Header','TestCase.Header.template')
                    self.makeTempFile(variables,fonte + '.' + 'TestCase.MethodName','TestCase.MethodName.template')
                    self.makeTempFile(variables,fonte + '.' + 'TestCase.AddMethod','TestCase.AddMethod.template')
                    self.makeTempFile(variables,fonte + '.' + 'TestCase.AddHeader','TestCase.AddHeader.template')
                    self.makeTempFile(variables,fonte + '.' + 'TestCase.SetupClass','TestCase.SetupClass.template')
                    self.finishTestCase(fonte)
                self.cleanTemp()
                printer.funcoes.clear()

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
        for files in os.walk(settings.PATH_TEMP):
            for file in files[2]:
                storagePathFile = os.path.join(settings.PATH_TEMP,file )
                exists = os.path.isfile(storagePathFile)
                if exists:
                    with open(storagePathFile) as datafile:
                        if 'TestFunction.tmp' in file:
                            testes += datafile.read()
        result = header+methodName+addHeader+addMethods+setupClass+testes

        f = open(os.path.join(self.srcPath, fonte + self.fileOut) , "w+")
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

    def getVariables(self,storagePathFile):
        return {}

    def getTypeValue(self,typeValue):
        value = "Nil"

        if typeValue == "C":
            value = "''"
        elif typeValue == "D":
            value = "stod('')"
        elif typeValue == "N":
            value = "0"
        elif typeValue == "A":
            value = "{}"
        elif typeValue == "L":
            value = ".F."
        elif typeValue == "X":
            value = "''"

        return value

import codecs
from antlr4.InputStream import InputStream
import datetime

class CaseInsensitiveInputStream (InputStream):

    def _loadString(self):
        self._index = 0
        self.data = [ord(c) for c in self.strdata.upper()]
        self._size = len(self.data)


class CaseInsensitiveFileStream(CaseInsensitiveInputStream):

    def __init__(self, fileName:str, encoding:str='ascii', errors:str='strict'):
        super().__init__(self.readDataFrom(fileName, encoding, errors))
        self.fileName = fileName

    def readDataFrom(self, fileName:str, encoding:str, errors:str='strict'):
        # read binary to avoid line ending conversion
        with open(fileName, 'rb') as file:
            bytes = file.read()
            return codecs.decode(bytes, encoding, errors)
