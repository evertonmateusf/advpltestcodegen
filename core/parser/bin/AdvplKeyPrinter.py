from .AdvplListener import AdvplListener
from .AdvplFunction import AdvplFunction

class AdvplKeyPrinter(AdvplListener):

    funcoes = []
    funcaoAtual = None
    variavelAtual = None
    ultimoContxt = None

    def enterFuncDeclaration(self, ctx):  
        #ctx.identifier.__
        print(ctx.identifier().getText())
        function = AdvplFunction(ctx.identifier().getText())
        self.funcaoAtual = function
        self.ultimoContxt = 'funcao'
    
    def exitFuncDeclaration(self, ctx):
        self.funcoes.append(self.funcaoAtual)
        self.ultimoContxt = None

    def exitProgram(self, ctx):
        pass
    # Enter a parse tree produced by AdvplParser#identifier.
    def enterIdentifier(self, ctx):
        if self.ultimoContxt == 'variavel':
            self.variavelAtual = ctx.getText()
        pass

    # Exit a parse tree produced by AdvplParser#variableDeclarationStatement.
    def exitVariableDeclarationStatement(self, ctx):
        self.funcaoAtual.addVariable(self.variavelAtual)
        self.ultimoContxt = None
        pass
    
    def enterVariableDeclarationStatement(self, ctx):
        self.ultimoContxt = 'variavel'
    
    # Enter a parse tree produced by AdvplParser#modifiersFunction.
    def enterModifiersFunction(self, ctx):
        self.funcaoAtual.type = ctx.getText()
    
    # Enter a parse tree produced by AdvplParser#formalParameter.
    def enterFormalParameter(self, ctx):
        self.funcaoAtual.addParameter(ctx.getText())
    
    # Enter a parse tree produced by AdvplParser#privateVariableDeclarationStatement.
    # def enterPrivateVariableDeclarationStatement(self, ctx):
        # print("Aqui é uma private!") 
    
    # Exit a parse tree produced by AdvplParser#ifStatement.
    # def enterIfStatement(self, ctx):
    #     print("enterIfStatement")
    #     # print(ctx.getText())
    #     # self.ultimoContxt = 'if'

    # # Enter a parse tree produced by AdvplParser#ifFunctioncall.
    # def enterIfFunctioncall(self, ctx):
    #     print("enterIfFunctioncall")
    #     # print(ctx.getText())
    
    # def enterIfCall(self, ctx):
    #     print("enterIfCall")
    #     # print(ctx.getText())
    
    # def enterStatementExpression(self, ctx):
    #     print("enterStatementExpression")
    #     print(ctx.getText())

    # def enterExprPrimary(self, ctx):
    #     print("enterExprPrimary")
    #     print(ctx.getText())

    # def enterExpressionList(self, ctx):
    #     print("enterExpressionList")
    #     print(ctx.getText())

    # def enterExprLogical(self, ctx):
    #     print("enterExprLogical")
    #     print(ctx.getText())

    # def enterExprComp(self, ctx):
    #     print("enterExprComp")
    #     print(ctx.getText())