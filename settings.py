# -*- coding: cp1252 -*-
import os

#Protheus Info
PROTHEUS_ENVIORMENT = {
    'default': {
        'COMPANY' : 'T1',
        'FILIAL' : 'M SP 01',
    }
}

PATH_PROJECT = os.path.dirname(os.path.abspath(__file__))

#Project Path
PATH_SRC = os.path.join(PATH_PROJECT, "src")
PATH_TEMPLATE = os.path.join(PATH_PROJECT, "templates")
PATH_TEMP = os.path.join(PATH_PROJECT, "temp")

#Inside src
PATH_SRC_TEST = os.path.join(PATH_SRC, "test")
PATH_SRC_ANALISE = os.path.join(PATH_SRC, "analise")

#Inside Test
PATH_SRC_TEST_CASES = os.path.join(PATH_SRC, "cases")
PATH_SRC_TEST_GROUP = os.path.join(PATH_SRC, "group")
PATH_SRC_TEST_SUITE = os.path.join(PATH_SRC, "suite")