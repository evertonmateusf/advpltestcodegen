from .AdvplListener import AdvplListener

class AdvplKeyPrinter(AdvplListener):
    def enterFuncDeclaration(self, ctx):         
        print("Oh, a key!") 