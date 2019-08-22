# -*- coding: utf-8 -*-
import csv
import os
import re
import sys
from pathlib import Path
from core.codeGenerators import (TestCaseCodeGenerator,
                  TestGroupCodeGenerator, TestSuiteCodeGenerator,
                  )

class codeGenController:

    def __init__(self):
        return

    def getGenerators(self):
        generators = []
        generators.append(TestCaseCodeGenerator.TestCaseCodeGenerator())
        generators.append(TestGroupCodeGenerator.TestGroupCodeGenerator())
        generators.append(TestSuiteCodeGenerator.TestSuiteCodeGenerator())

        return generators

    def build(self):

        generators = self.getGenerators()
        for generator in generators:
            generator.build()
        return

    