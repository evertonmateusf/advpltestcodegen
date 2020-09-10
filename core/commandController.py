# -*- coding: utf-8 -*-
import sys, os, settings
from core import codeGenController, project

class ComandsController:
    
    def __init__(self, firstComands=None, runOk=None, api=None):
        self.firstComands = ['STARTPROJECT','BUILD','BUILDTEMPLATETESTS']
        self.runOk = False
        self.codeGen = codeGenController.codeGenController()
        self.project = project.project()
        return

    def run(self, run):
        run[1] = run[1].upper()
        command = run[1] if len(run) > 1 else ''

        if command == 'STARTPROJECT':
            self.project.startProject()
            return
        if command == 'BUILD':
            self.project.createDir()
            self.codeGen.build()
            return
        if command == 'BUILDTEMPLATETESTS':
            self.codeGen.buildTemplate()
            return
        print('Comando inválido.')
        print('Comandos disponíveis: ' + ', '.join(self.firstComands))
        return

        
