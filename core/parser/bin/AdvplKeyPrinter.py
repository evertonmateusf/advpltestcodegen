from .AdvplListener import AdvplListener
from .Estruturas.AdvplFunction import AdvplFunction
from .Estruturas.AdvplWsClient import AdvplWsClient

class AdvplKeyPrinter(AdvplListener):

    funcoes = []
    funcaoAtual = None
    wsList = []
    wsdata = None
    method = None
    variavelAtual = None
    ultimoContxt = ''

    def enterFuncDeclaration(self, ctx):  
        # print(ctx.identifier().getText())
        function = AdvplFunction(ctx.identifier().getText())
        self.funcaoAtual = function
        self.ultimoContxt = 'funcao'
    
    def exitFuncDeclaration(self, ctx):
        self.funcoes.append(self.funcaoAtual)
        self.ultimoContxt = ''

    def enterInitFuncOrMethod(self, ctx):
        self.ultimoContxt = 'InitFuncOrMethod'

    
    def enterIdentifier(self, ctx):
        
        if self.ultimoContxt == 'variavel':
            self.variavelAtual = ctx.getText()
        pass

    def exitVariableDeclarationStatement(self, ctx):
        self.funcaoAtual.addVariable(self.variavelAtual)
        self.ultimoContxt = ''
        pass
    
    def enterVariableDeclarationStatement(self, ctx):
        self.ultimoContxt = 'variavel'
        # print("Passei por: enterVariableDeclarationStatement")
        # print(ctx.getText())
    
    def enterModifiersFunction(self, ctx):
        self.funcaoAtual.type = ctx.getText()
        self.ultimoContxt = 'ModifiersFunction'
    
    def enterFormalParameter(self, ctx):
        self.funcaoAtual.addParameter(ctx.getText())
        # print("Passei por: enterFormalParameter")
        self.method[1].append(ctx.getText())
        # print(ctx.getText())
        # print("Ultimo contexto: " + self.ultimoContxt )
        self.ultimoContxt = 'FormalParameter'
 
    def enterWsdataDefinition(self, ctx):
        # print("Passei por: enterWsdataDefinition")
        # print(ctx.identifier().getText())
        self.wsdata = [ctx.identifier().getText(),[]]
        self.ultimoContxt = 'WsdataDefinition'

    def enterWsDataType(self, ctx):
        # print("Passei por: enterWsDataType")
        for identifier in ctx.identifier():
        #    print(identifier.getText())
           self.wsdata[1].append(identifier.getText())
        self.wsList[len(self.wsList)-1].addProperty(self.wsdata)
        self.ultimoContxt = 'WsDataType'

    def enterWsServiceClientDeclaration(self, ctx):
        # print("Passei por: enterWsServiceClientDeclaration")
        self.wsList.append(AdvplWsClient(ctx.identifier().getText(), 'WSCLIENT'))
        # print(ctx.identifier().getText())
        self.ultimoContxt = 'WsServiceClientDeclaration'

    def enterWsmethodClientBody(self, ctx):
        # print("Passei por: enterWsmethodClientBody")
        #ctx.identifier()[0] nome do metodo
        #ctx.identifier()[1] nome da classe
        self.method = [ctx.identifier()[0].getText(),[]]
        self.ultimoContxt = 'WsmethodClientBody'

    def exitWsmethodClientBody(self, ctx):
        # print("Passei por: exitWsmethodClientBody")
        self.wsList[len(self.wsList)-1].addMethod(self.method)

    def enterWsServiceClientStructDeclaration(self, ctx):
        # print("Passei por: enterWsServiceClientStructDeclaration")
        # print(ctx.getText())
        self.wsList.append(AdvplWsClient(ctx.identifier().getText(), 'WSSTRUCT'))
