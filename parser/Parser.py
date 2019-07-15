import sys
from bin.AdvplKeyPrinter import AdvplKeyPrinter
from bin.AdvplLexer import AdvplLexer
from bin.AdvplParser import AdvplParser
from antlr4 import *

# Comando para gerar os fontes de parser a partir da gramática
# antlr-4.7.2-complete.jar -Dlanguage=Python3 Advpl.g4

def main(argv):
    input_stream = FileStream(argv[1],"cp1252")
    lexer = AdvplLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AdvplParser(stream)
    tree = parser.program()
    printer = AdvplKeyPrinter()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)
    for function in printer.funcoes:
        print(function.type + ' ' + function.name) 
        for parameter in function.parameters:
            print(parameter)
        for variable in function.variables:
            print(variable)
 
if __name__ == '__main__':
    main(sys.argv)
