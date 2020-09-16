# -*- coding: utf-8 -*-
import sys, os, settings
from core import codeGenController, project
import argparse

class ComandsController:
    ap = argparse.ArgumentParser()

    def __init__(self, firstComands=None, runOk=None, api=None):
        self.firstComands = ['STARTPROJECT','BUILD','BUILDTEMPLATETESTS']
        self.runOk = False
        self.codeGen = codeGenController.codeGenController()
        self.project = project.project()
        self.ap.add_argument("-s", "--startproject",action='store_true',help="Create the project structure")
        self.ap.add_argument("-b", "--build",action='store_true',help="Create testcase, testgroup and testsuite to cover line codes of an ADVPL file, by default will read files from folder \\src\\analise. Use parameters -i or -f to change the origin.")
        self.ap.add_argument("-t", "--buildtemplatetest",action='store_true',help="Create blanks testcase, testgroup and testsuite files to an ADVPL file")
        self.ap.add_argument("-f", "--inputfile", required=False,help="Base file to generate tests")
        self.ap.add_argument("-i", "--inputpath", required=False,help="Folder that contain the files to generate tests")
        self.ap.add_argument("-o", "--outputpath", required=False,help="Folder to save the tests generated")
        self.args = vars(self.ap.parse_args())
        return

    def run(self, run):
        
        self.codeGen.inputfile = '' if self.args['inputfile'] == None else self.args['inputfile']
        self.codeGen.inputpath = settings.PATH_SRC_ANALISE if self.args['inputpath'] == None else self.args['inputpath']
        self.codeGen.outputpath = settings.PATH_SRC if self.args['outputpath'] == None else self.args['outputpath']
        self.project.inputpath = self.codeGen.inputpath
        self.project.outputpath = self.codeGen.outputpath
        if self.args['startproject']:
            self.project.startProject()
        if self.args['build']:
            self.codeGen.build()
            return
        if self.args['buildtemplatetest']:
            self.codeGen.buildTemplate()
            return
        return

        
