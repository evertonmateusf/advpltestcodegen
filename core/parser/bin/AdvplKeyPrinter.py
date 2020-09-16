from .AdvplListener import AdvplListener
from .Estruturas.AdvplWsClient import AdvplWsClient

class AdvplKeyPrinter(AdvplListener):

    wsList = []
    wsdata = None
    method = None
    
    def enterWsdataDefinition(self, ctx):
        # print(ctx.identifier().getText())
        self.wsdata = [ctx.identifier().getText(),[]]

    def enterWsDataType(self, ctx):
        for identifier in ctx.identifier():
           self.wsdata[1].append(identifier.getText())
        self.wsList[len(self.wsList)-1].addProperty(self.wsdata)

    def enterWsServiceClientDeclaration(self, ctx):
        self.wsList.append(AdvplWsClient(ctx.identifier().getText(), 'WSCLIENT'))

    def enterWsmethodClientBody(self, ctx):
        #ctx.identifier()[0] nome do metodo
        #ctx.identifier()[1] nome da classe
        self.method = [ctx.identifier()[0].getText(),[]]

    def exitWsmethodClientBody(self, ctx):
        self.wsList[len(self.wsList)-1].addMethod(self.method)

    def enterWsServiceClientStructDeclaration(self, ctx):
        self.wsList.append(AdvplWsClient(ctx.identifier().getText(), 'WSSTRUCT'))
