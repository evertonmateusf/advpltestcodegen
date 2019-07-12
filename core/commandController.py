# -*- coding: utf-8 -*-
import sys, os, settings
from core import managedb, codeGenController, project

class ComandsController:
    
    def __init__(self, firstComands=None, runOk=None, api=None):
        self.firstComands = ['startproject','addcolumn','testconnect', 'addentity', 'list', 'build', 'testcase']
        self.runOk = False
        self.codeGen = codeGenController.codeGenController()
        self.project = project.project()
        return

    def run(self, run):
        run[1] = run[1].upper()
        command = run[1] if len(run) > 1 else ''

        if command == 'TESTCONNECT':
            mdb = managedb.ManagementDb()
            mdb.testeConnect()
            return
        if command == 'STARTPROJECT':
            self.project.startProject()
            return
        if command == 'BUILD':
            self.project.createDir()
            self.codeGen.build()
            return
        if command == 'TESTEFUN':
            print("TESTE")
            return
        return

        
