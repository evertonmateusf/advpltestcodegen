# -*- coding: cp1252 -*-
import sys, os, settings, csv, shutil
from core.codeGenerators.TestCaseCodeGenerator import TestCaseCodeGenerator
from antlr4 import *
import datetime

class WsClientTestCaseCodeGenerator(TestCaseCodeGenerator):

    def __init__ (self, outputPath=None):
        super().__init__(outputPath=None)
        self.outputPath = settings.PATH_SRC_TEST_CASES if outputPath==None else outputPath
        self.templateFile = 'TestCase.template'
        return
   
    def applyFileRules(self,printer,fonte):
        methodName = []
        addMethod = []
        for ws in printer.wsList:
            if ws.type.upper() == 'WSCLIENT':
                print("[" + datetime.datetime.now().ctime() + "]Gerando caso de teste para a classe " + ws.name)
                methodName.append(''.rjust(4)+"METHOD "+ws.name+"()")
                addMethod.append(''.rjust(4)+"self:AddTestMethod( '"+ws.name+"',,'Teste do WSCLIENT "+ws.name+".' ) ")
                localVars = []
                localVars.append(''.rjust(4)+"Local oWs := " + ws.name + "():New() ")
                setPropertiesAndCallMethods = []
                textFather = ''.rjust(4)+" oWs"
                self.initWsProperties(printer.wsList, ws, setPropertiesAndCallMethods, textFather,0)
                variables = {
                        'fonte': fonte,
                        'WsName': ws.name,
                        'setPropertiesAndCallMethods': '\n'.join(setPropertiesAndCallMethods),
                        'localVars': '\n'.join(localVars),
                    }
                self.makeTempFile(variables,fonte + '.' + ws.name + '.TestWsClient','TestWsClient.template')
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
        printer.wsList.clear()

    def initWsProperties(self, wsList, ws, setPropertiesAndCallMethods, textFather, lookAheadCount):
        callMethod = ''
        for wsProp in ws.properties:
            if self.isWebStruct(wsList,wsProp[1][0].upper()):
                textSon = textFather + ":" + wsProp[0]
                setPropertiesAndCallMethods.append( textSon + " := " + wsProp[1][0].upper() + "():new()")
                for wsItem in wsList:
                    if wsItem.name == wsProp[1][0].upper() and lookAheadCount < 20:
                        self.initWsProperties(wsList, wsItem, setPropertiesAndCallMethods, textSon, lookAheadCount+1)
                        break
            else:
                setPropertiesAndCallMethods.append( textFather + ":" + wsProp[0] + " := " + self.getPropertyTypeValue(wsProp[1][0].upper()))
        for wsMethod in ws.methods:
            if wsMethod[0].upper() != "NEW":
                # if wsMethod[0].upper() == "SOAPRECV":
                #     callMethod = textFather + ':SOAPRECV(XmlParser( cXml, "_", @cError, @cWarning ))'
                # else:
                params = []
                for parameter in wsMethod[1]:
                    params.append(self.getTypeValue(parameter[0:1].upper()))
                callMethod = textFather + ":" + wsMethod[0] + "(" + ",".join(params) +")"
                setPropertiesAndCallMethods.append(callMethod)
            pass

    def isWebStruct(self, wsList, property):
        isWebStruct = False
        for wsItem in wsList:
            # print( "wsItem.name: " +  wsItem.name)
            if wsItem.name == property and wsItem.type.upper() == 'WSSTRUCT':
                isWebStruct = True
                break
        return isWebStruct

    def getTempFileName(self):
        return 'TestWsClient.tmp'
