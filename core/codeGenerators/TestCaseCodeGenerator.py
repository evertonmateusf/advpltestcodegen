# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import codeGenerator
from string import Template

class TestCaseCodeGenerator(codeGenerator):

    def __init__ (self, function=None):
        super().__init__(function=None)
        self.templateFile = 'TestCase.template' 
        self.srcPath = settings.PATH_SRC_TEST_CASES
        return

    def setFileOut(self):
        self.fileOut = "FunctionsTestCase.prw"
    
    def build(self):
        localVars = []
        params = []
        methodName = []
        addMethod = []
        functionName = ''
        functionCall = ''
        
        storagePathFile = os.path.join(settings.PATH_FILESTORAGE ,  "functions.txt")
        exists = os.path.isfile(storagePathFile) 
        if exists:
            with open(storagePathFile) as datafile:
                data = csv.reader(datafile, delimiter=';')
                for function in data:
                    if len(function) > 0:
                        localVars = []
                        params = []
                        if function[0] == "function":
                            functionName = function[1]
                            methodName.append(''.rjust(4)+"METHOD "+function[1]+"()")
                            addMethod.append(''.rjust(4)+"self:AddTestMethod( '"+function[1]+"',,'Teste da funcao "+function[1]+".' ) ")
                        elif function[0] == "variable":
                            for variable in function:
                                if variable.strip() != "" and variable != "variable":
                                    localVars.append(''.rjust(4)+"Local " + variable + " := " + self.getTypeValue(variable[0:1].upper()) )
                                    params.append(variable)
                            functionCall = functionName + "(" + ",".join(params) +")"
                            variables = {
                                    'functionName': functionName,
                                    'functionsCall': functionCall,
                                    'localVars': '\n'.join(localVars),
                                }
                            self.fileOut = functionName + "TestCase.temp"
                            self.makeTempFile(variables,functionName + '.TestFunction','TestFunction.template')
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
        return

    def makeTempFile(self, variables, file,template):
        fileIn = open(os.path.join(settings.PATH_TEMPLATE, template))
        temp = Template(fileIn.read())
        result = temp.substitute(variables)
        f = open(os.path.join(settings.PATH_TEMP, file + ".tmp") , "w+")
        f.write(result)
        f.close()

    def finishTestCase(self):
        self.setFileOut()
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
