# -*- coding: cp1252 -*-
import os

#DataBase Info
DATABASES = {
    'default': {
        'NAME': 'P12117MNTDB',
        'USER': 'sa',
        'PASSWORD': 'masterkey',
        'HOST': '.',
    }
}

#Protheus Info
PROTHEUS_ENVIORMENT = {
    'default': {
        'COMPANY' : 'T1',
        'FILIAL' : 'M SP 01',
        'PREFIX' : 'Cen',
        'SEGMENT' : 'healthcare' ,
        'PRODUCT' : 'Protheus',
        'PRDUCT_DESCRIPTION' : 'Central de Obrigações',
        'DICTIONARY_IN_DATABASE' : True,
        'CONTACT' : 'comiteintegracao@totvs.com.br',
    }
}

PATH_PROJECT = os.path.dirname(os.path.abspath(__file__))

#Project Path
PATH_SRC = os.path.join(PATH_PROJECT, "src")
PATH_TEMPLATE = os.path.join(PATH_PROJECT, "templates")
PATH_TEMP = os.path.join(PATH_PROJECT, "temp")
PATH_FILESTORAGE = os.path.join(PATH_PROJECT, "filestorage")

#Inside src
PATH_SRC_TEST = os.path.join(PATH_SRC, "test")
PATH_SRC_ANALISE = os.path.join(PATH_SRC, "analise")

#Inside Template
PATH_TEMPLATE_LIBS = os.path.join(PATH_TEMPLATE, "libs")
PATH_TEMPLATE_DOCS = os.path.join(PATH_TEMPLATE, "docs")

#Inside Test
PATH_SRC_TEST_CASES = os.path.join(PATH_SRC_TEST, "cases")
PATH_SRC_TEST_GROUP = os.path.join(PATH_SRC_TEST, "group")
PATH_SRC_TEST_SUITE = os.path.join(PATH_SRC_TEST, "suite")