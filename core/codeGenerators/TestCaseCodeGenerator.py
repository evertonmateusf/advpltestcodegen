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
        return

    def setFileOut(self):
        self.fileOut = "FunctionsTestCase.prw"
    
    def build(self):
        
        for files in os.walk(settings.PATH_SRC_ANALISE):
            for file in files[2]:
                self.fileOut = file[:-4] + "TestCase.prw"
                input_stream = FileStream(settings.PATH_SRC_ANALISE+"\\"+file,"cp1252")
                lexer = AdvplLexer(input_stream)
                stream = CommonTokenStream(lexer)
                parser = AdvplParser(stream)
                tree = parser.program()
                printer = AdvplKeyPrinter()
                walker = ParseTreeWalker()
                walker.walk(printer, tree)
                methodName = []
                addMethod = []
                for function in printer.funcoes:
                    if function.type != 'STATIC':
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
                                'functionName': function.name,
                                'functionsCall': functionCall,
                                'localVars': '\n'.join(localVars),
                            }
                        self.makeTempFile(variables,function.name + '.TestFunction','TestFunction.template')
                    variables = {
                            'methodName': '\n'.join(methodName),
                            'addMethod': '\n'.join(addMethod)
                        }
                    self.makeTempFile(variables,'TestCase.Header','TestCase.Header.template')
                    self.makeTempFile(variables,'TestCase.MethodName','TestCase.MethodName.template')
                    self.makeTempFile(variables,'TestCase.AddMethod','TestCase.AddMethod.template')
                    self.makeTempFile(variables,'TestCase.AddHeader','TestCase.AddHeader.template')
                    self.makeTempFile(variables,'TestCase.SetupClass','TestCase.SetupClass.template')
                    self.finishTestCase()

    def makeTempFile(self, variables, file,template):
        fileIn = open(os.path.join(settings.PATH_TEMPLATE, template))
        temp = Template(fileIn.read())
        result = temp.substitute(variables)
        f = open(os.path.join(settings.PATH_TEMP, file + ".tmp") , "w+")
        f.write(result)
        f.close()

    def finishTestCase(self):
        header = open(os.path.join(settings.PATH_TEMP, 'TestCase.Header.tmp')).read()
        setupClass = open(os.path.join(settings.PATH_TEMP, 'TestCase.SetupClass.tmp')).read()
        methodName = open(os.path.join(settings.PATH_TEMP, 'TestCase.MethodName.tmp')).read()
        addHeader = open(os.path.join(settings.PATH_TEMP, 'TestCase.AddHeader.tmp')).read()
        addMethods = open(os.path.join(settings.PATH_TEMP, 'TestCase.AddMethod.tmp')).read()
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

        f = open(os.path.join(self.srcPath, self.fileOut) , "w+")
        f.write(result)
        f.close()
        return
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
