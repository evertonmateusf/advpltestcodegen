# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.codeGenerator import TestCaseCodeGenerator
from antlr4 import *
import datetime

class FunctionTestCaseCodeGenerator(TestCaseCodeGenerator):

    def __init__ (self, outputPath=None):
        super().__init__(outputPath=None)
        return
   
    def applyFileRules(self,printer,fonte):
        methodName = []
        addMethod = []
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
        printer.funcoes.clear()

    def getTempFileName(self):
        return 'TestFunction.tmp'

