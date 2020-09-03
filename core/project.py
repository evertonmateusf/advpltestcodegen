# -*- coding: utf-8 -*-
import sys, os, settings, csv, re
from pathlib import Path
from string import Template

class project:

    def __init__(self):
        return

    #Create project folders 
    def startProject(self):
        self.createDir()

    def createDir(self):
    
        if not os.path.isdir(settings.PATH_TEMP): os.mkdir(settings.PATH_TEMP)
        if not os.path.isdir(settings.PATH_FILESTORAGE): os.mkdir(settings.PATH_FILESTORAGE)
        if not os.path.isdir(settings.PATH_SRC): os.mkdir(settings.PATH_SRC)
        if not os.path.isdir(settings.PATH_SRC_TEST): os.mkdir(settings.PATH_SRC_TEST)
        if not os.path.isdir(settings.PATH_SRC_TEST_CASES): os.mkdir(settings.PATH_SRC_TEST_CASES)
        if not os.path.isdir(settings.PATH_SRC_TEST_GROUP): os.mkdir(settings.PATH_SRC_TEST_GROUP)
        if not os.path.isdir(settings.PATH_SRC_TEST_SUITE): os.mkdir(settings.PATH_SRC_TEST_SUITE)
        
        if not os.path.isdir(settings.PATH_SRC_ANALISE): os.mkdir(settings.PATH_SRC_ANALISE)

        return

