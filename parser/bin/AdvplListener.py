# Generated from C:\prjs\advpltestcodegen\parser\grammar\Advpl.g4 by ANTLR 4.7.2
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .AdvplParser import AdvplParser
else:
    from AdvplParser import AdvplParser

# This class defines a complete listener for a parse tree produced by AdvplParser.
class AdvplListener(ParseTreeListener):

    # Enter a parse tree produced by AdvplParser#program.
    def enterProgram(self, ctx:AdvplParser.ProgramContext):
        pass

    # Exit a parse tree produced by AdvplParser#program.
    def exitProgram(self, ctx:AdvplParser.ProgramContext):
        pass


    # Enter a parse tree produced by AdvplParser#directives.
    def enterDirectives(self, ctx:AdvplParser.DirectivesContext):
        pass

    # Exit a parse tree produced by AdvplParser#directives.
    def exitDirectives(self, ctx:AdvplParser.DirectivesContext):
        pass


    # Enter a parse tree produced by AdvplParser#includeDeclaration.
    def enterIncludeDeclaration(self, ctx:AdvplParser.IncludeDeclarationContext):
        pass

    # Exit a parse tree produced by AdvplParser#includeDeclaration.
    def exitIncludeDeclaration(self, ctx:AdvplParser.IncludeDeclarationContext):
        pass


    # Enter a parse tree produced by AdvplParser#ifDef.
    def enterIfDef(self, ctx:AdvplParser.IfDefContext):
        pass

    # Exit a parse tree produced by AdvplParser#ifDef.
    def exitIfDef(self, ctx:AdvplParser.IfDefContext):
        pass


    # Enter a parse tree produced by AdvplParser#elseDef.
    def enterElseDef(self, ctx:AdvplParser.ElseDefContext):
        pass

    # Exit a parse tree produced by AdvplParser#elseDef.
    def exitElseDef(self, ctx:AdvplParser.ElseDefContext):
        pass


    # Enter a parse tree produced by AdvplParser#endifDef.
    def enterEndifDef(self, ctx:AdvplParser.EndifDefContext):
        pass

    # Exit a parse tree produced by AdvplParser#endifDef.
    def exitEndifDef(self, ctx:AdvplParser.EndifDefContext):
        pass


    # Enter a parse tree produced by AdvplParser#defineDeclaration.
    def enterDefineDeclaration(self, ctx:AdvplParser.DefineDeclarationContext):
        pass

    # Exit a parse tree produced by AdvplParser#defineDeclaration.
    def exitDefineDeclaration(self, ctx:AdvplParser.DefineDeclarationContext):
        pass


    # Enter a parse tree produced by AdvplParser#undefineDeclaration.
    def enterUndefineDeclaration(self, ctx:AdvplParser.UndefineDeclarationContext):
        pass

    # Exit a parse tree produced by AdvplParser#undefineDeclaration.
    def exitUndefineDeclaration(self, ctx:AdvplParser.UndefineDeclarationContext):
        pass


    # Enter a parse tree produced by AdvplParser#classDeclaration.
    def enterClassDeclaration(self, ctx:AdvplParser.ClassDeclarationContext):
        pass

    # Exit a parse tree produced by AdvplParser#classDeclaration.
    def exitClassDeclaration(self, ctx:AdvplParser.ClassDeclarationContext):
        pass


    # Enter a parse tree produced by AdvplParser#dataDefinition.
    def enterDataDefinition(self, ctx:AdvplParser.DataDefinitionContext):
        pass

    # Exit a parse tree produced by AdvplParser#dataDefinition.
    def exitDataDefinition(self, ctx:AdvplParser.DataDefinitionContext):
        pass


    # Enter a parse tree produced by AdvplParser#methodDefinition.
    def enterMethodDefinition(self, ctx:AdvplParser.MethodDefinitionContext):
        pass

    # Exit a parse tree produced by AdvplParser#methodDefinition.
    def exitMethodDefinition(self, ctx:AdvplParser.MethodDefinitionContext):
        pass


    # Enter a parse tree produced by AdvplParser#modifiersMethod.
    def enterModifiersMethod(self, ctx:AdvplParser.ModifiersMethodContext):
        pass

    # Exit a parse tree produced by AdvplParser#modifiersMethod.
    def exitModifiersMethod(self, ctx:AdvplParser.ModifiersMethodContext):
        pass


    # Enter a parse tree produced by AdvplParser#methodBody.
    def enterMethodBody(self, ctx:AdvplParser.MethodBodyContext):
        pass

    # Exit a parse tree produced by AdvplParser#methodBody.
    def exitMethodBody(self, ctx:AdvplParser.MethodBodyContext):
        pass


    # Enter a parse tree produced by AdvplParser#funcDeclaration.
    def enterFuncDeclaration(self, ctx:AdvplParser.FuncDeclarationContext):
        pass

    # Exit a parse tree produced by AdvplParser#funcDeclaration.
    def exitFuncDeclaration(self, ctx:AdvplParser.FuncDeclarationContext):
        pass


    # Enter a parse tree produced by AdvplParser#superCall.
    def enterSuperCall(self, ctx:AdvplParser.SuperCallContext):
        pass

    # Exit a parse tree produced by AdvplParser#superCall.
    def exitSuperCall(self, ctx:AdvplParser.SuperCallContext):
        pass


    # Enter a parse tree produced by AdvplParser#initFuncOrMethod.
    def enterInitFuncOrMethod(self, ctx:AdvplParser.InitFuncOrMethodContext):
        pass

    # Exit a parse tree produced by AdvplParser#initFuncOrMethod.
    def exitInitFuncOrMethod(self, ctx:AdvplParser.InitFuncOrMethodContext):
        pass


    # Enter a parse tree produced by AdvplParser#variableDeclarationStatement.
    def enterVariableDeclarationStatement(self, ctx:AdvplParser.VariableDeclarationStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#variableDeclarationStatement.
    def exitVariableDeclarationStatement(self, ctx:AdvplParser.VariableDeclarationStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#modifiersFunction.
    def enterModifiersFunction(self, ctx:AdvplParser.ModifiersFunctionContext):
        pass

    # Exit a parse tree produced by AdvplParser#modifiersFunction.
    def exitModifiersFunction(self, ctx:AdvplParser.ModifiersFunctionContext):
        pass


    # Enter a parse tree produced by AdvplParser#formalParameters.
    def enterFormalParameters(self, ctx:AdvplParser.FormalParametersContext):
        pass

    # Exit a parse tree produced by AdvplParser#formalParameters.
    def exitFormalParameters(self, ctx:AdvplParser.FormalParametersContext):
        pass


    # Enter a parse tree produced by AdvplParser#formalParameter.
    def enterFormalParameter(self, ctx:AdvplParser.FormalParameterContext):
        pass

    # Exit a parse tree produced by AdvplParser#formalParameter.
    def exitFormalParameter(self, ctx:AdvplParser.FormalParameterContext):
        pass


    # Enter a parse tree produced by AdvplParser#identifier.
    def enterIdentifier(self, ctx:AdvplParser.IdentifierContext):
        pass

    # Exit a parse tree produced by AdvplParser#identifier.
    def exitIdentifier(self, ctx:AdvplParser.IdentifierContext):
        pass


    # Enter a parse tree produced by AdvplParser#staticVariableDeclarationStatement.
    def enterStaticVariableDeclarationStatement(self, ctx:AdvplParser.StaticVariableDeclarationStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#staticVariableDeclarationStatement.
    def exitStaticVariableDeclarationStatement(self, ctx:AdvplParser.StaticVariableDeclarationStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#privateVariableDeclarationStatement.
    def enterPrivateVariableDeclarationStatement(self, ctx:AdvplParser.PrivateVariableDeclarationStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#privateVariableDeclarationStatement.
    def exitPrivateVariableDeclarationStatement(self, ctx:AdvplParser.PrivateVariableDeclarationStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#publicVariableDeclarationStatement.
    def enterPublicVariableDeclarationStatement(self, ctx:AdvplParser.PublicVariableDeclarationStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#publicVariableDeclarationStatement.
    def exitPublicVariableDeclarationStatement(self, ctx:AdvplParser.PublicVariableDeclarationStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#block.
    def enterBlock(self, ctx:AdvplParser.BlockContext):
        pass

    # Exit a parse tree produced by AdvplParser#block.
    def exitBlock(self, ctx:AdvplParser.BlockContext):
        pass


    # Enter a parse tree produced by AdvplParser#statement.
    def enterStatement(self, ctx:AdvplParser.StatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#statement.
    def exitStatement(self, ctx:AdvplParser.StatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#ifStatement.
    def enterIfStatement(self, ctx:AdvplParser.IfStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#ifStatement.
    def exitIfStatement(self, ctx:AdvplParser.IfStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#forStatement.
    def enterForStatement(self, ctx:AdvplParser.ForStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#forStatement.
    def exitForStatement(self, ctx:AdvplParser.ForStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#forInit.
    def enterForInit(self, ctx:AdvplParser.ForInitContext):
        pass

    # Exit a parse tree produced by AdvplParser#forInit.
    def exitForInit(self, ctx:AdvplParser.ForInitContext):
        pass


    # Enter a parse tree produced by AdvplParser#doStatement.
    def enterDoStatement(self, ctx:AdvplParser.DoStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#doStatement.
    def exitDoStatement(self, ctx:AdvplParser.DoStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#whileStatement.
    def enterWhileStatement(self, ctx:AdvplParser.WhileStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#whileStatement.
    def exitWhileStatement(self, ctx:AdvplParser.WhileStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#docaseStatement.
    def enterDocaseStatement(self, ctx:AdvplParser.DocaseStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#docaseStatement.
    def exitDocaseStatement(self, ctx:AdvplParser.DocaseStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#returnStatement.
    def enterReturnStatement(self, ctx:AdvplParser.ReturnStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#returnStatement.
    def exitReturnStatement(self, ctx:AdvplParser.ReturnStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#exitOrLoopStatement.
    def enterExitOrLoopStatement(self, ctx:AdvplParser.ExitOrLoopStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#exitOrLoopStatement.
    def exitExitOrLoopStatement(self, ctx:AdvplParser.ExitOrLoopStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprPrimary.
    def enterExprPrimary(self, ctx:AdvplParser.ExprPrimaryContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprPrimary.
    def exitExprPrimary(self, ctx:AdvplParser.ExprPrimaryContext):
        pass


    # Enter a parse tree produced by AdvplParser#Assignment.
    def enterAssignment(self, ctx:AdvplParser.AssignmentContext):
        pass

    # Exit a parse tree produced by AdvplParser#Assignment.
    def exitAssignment(self, ctx:AdvplParser.AssignmentContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprIncrPos.
    def enterExprIncrPos(self, ctx:AdvplParser.ExprIncrPosContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprIncrPos.
    def exitExprIncrPos(self, ctx:AdvplParser.ExprIncrPosContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprIncrPre.
    def enterExprIncrPre(self, ctx:AdvplParser.ExprIncrPreContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprIncrPre.
    def exitExprIncrPre(self, ctx:AdvplParser.ExprIncrPreContext):
        pass


    # Enter a parse tree produced by AdvplParser#AliasAssignment.
    def enterAliasAssignment(self, ctx:AdvplParser.AliasAssignmentContext):
        pass

    # Exit a parse tree produced by AdvplParser#AliasAssignment.
    def exitAliasAssignment(self, ctx:AdvplParser.AliasAssignmentContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprLogical.
    def enterExprLogical(self, ctx:AdvplParser.ExprLogicalContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprLogical.
    def exitExprLogical(self, ctx:AdvplParser.ExprLogicalContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprComp.
    def enterExprComp(self, ctx:AdvplParser.ExprCompContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprComp.
    def exitExprComp(self, ctx:AdvplParser.ExprCompContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprPlus.
    def enterExprPlus(self, ctx:AdvplParser.ExprPlusContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprPlus.
    def exitExprPlus(self, ctx:AdvplParser.ExprPlusContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprNot.
    def enterExprNot(self, ctx:AdvplParser.ExprNotContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprNot.
    def exitExprNot(self, ctx:AdvplParser.ExprNotContext):
        pass


    # Enter a parse tree produced by AdvplParser#ExprMul.
    def enterExprMul(self, ctx:AdvplParser.ExprMulContext):
        pass

    # Exit a parse tree produced by AdvplParser#ExprMul.
    def exitExprMul(self, ctx:AdvplParser.ExprMulContext):
        pass


    # Enter a parse tree produced by AdvplParser#arguments.
    def enterArguments(self, ctx:AdvplParser.ArgumentsContext):
        pass

    # Exit a parse tree produced by AdvplParser#arguments.
    def exitArguments(self, ctx:AdvplParser.ArgumentsContext):
        pass


    # Enter a parse tree produced by AdvplParser#expressionList.
    def enterExpressionList(self, ctx:AdvplParser.ExpressionListContext):
        pass

    # Exit a parse tree produced by AdvplParser#expressionList.
    def exitExpressionList(self, ctx:AdvplParser.ExpressionListContext):
        pass


    # Enter a parse tree produced by AdvplParser#optionalExpression.
    def enterOptionalExpression(self, ctx:AdvplParser.OptionalExpressionContext):
        pass

    # Exit a parse tree produced by AdvplParser#optionalExpression.
    def exitOptionalExpression(self, ctx:AdvplParser.OptionalExpressionContext):
        pass


    # Enter a parse tree produced by AdvplParser#arrayAccess.
    def enterArrayAccess(self, ctx:AdvplParser.ArrayAccessContext):
        pass

    # Exit a parse tree produced by AdvplParser#arrayAccess.
    def exitArrayAccess(self, ctx:AdvplParser.ArrayAccessContext):
        pass


    # Enter a parse tree produced by AdvplParser#methodAccessLoop.
    def enterMethodAccessLoop(self, ctx:AdvplParser.MethodAccessLoopContext):
        pass

    # Exit a parse tree produced by AdvplParser#methodAccessLoop.
    def exitMethodAccessLoop(self, ctx:AdvplParser.MethodAccessLoopContext):
        pass


    # Enter a parse tree produced by AdvplParser#primary_ref.
    def enterPrimary_ref(self, ctx:AdvplParser.Primary_refContext):
        pass

    # Exit a parse tree produced by AdvplParser#primary_ref.
    def exitPrimary_ref(self, ctx:AdvplParser.Primary_refContext):
        pass


    # Enter a parse tree produced by AdvplParser#Parens.
    def enterParens(self, ctx:AdvplParser.ParensContext):
        pass

    # Exit a parse tree produced by AdvplParser#Parens.
    def exitParens(self, ctx:AdvplParser.ParensContext):
        pass


    # Enter a parse tree produced by AdvplParser#VarArrayAccess.
    def enterVarArrayAccess(self, ctx:AdvplParser.VarArrayAccessContext):
        pass

    # Exit a parse tree produced by AdvplParser#VarArrayAccess.
    def exitVarArrayAccess(self, ctx:AdvplParser.VarArrayAccessContext):
        pass


    # Enter a parse tree produced by AdvplParser#Call.
    def enterCall(self, ctx:AdvplParser.CallContext):
        pass

    # Exit a parse tree produced by AdvplParser#Call.
    def exitCall(self, ctx:AdvplParser.CallContext):
        pass


    # Enter a parse tree produced by AdvplParser#ClassConstructor.
    def enterClassConstructor(self, ctx:AdvplParser.ClassConstructorContext):
        pass

    # Exit a parse tree produced by AdvplParser#ClassConstructor.
    def exitClassConstructor(self, ctx:AdvplParser.ClassConstructorContext):
        pass


    # Enter a parse tree produced by AdvplParser#CallWithAtt.
    def enterCallWithAtt(self, ctx:AdvplParser.CallWithAttContext):
        pass

    # Exit a parse tree produced by AdvplParser#CallWithAtt.
    def exitCallWithAtt(self, ctx:AdvplParser.CallWithAttContext):
        pass


    # Enter a parse tree produced by AdvplParser#ObjectAttribAccess.
    def enterObjectAttribAccess(self, ctx:AdvplParser.ObjectAttribAccessContext):
        pass

    # Exit a parse tree produced by AdvplParser#ObjectAttribAccess.
    def exitObjectAttribAccess(self, ctx:AdvplParser.ObjectAttribAccessContext):
        pass


    # Enter a parse tree produced by AdvplParser#ObjectMethodAccess.
    def enterObjectMethodAccess(self, ctx:AdvplParser.ObjectMethodAccessContext):
        pass

    # Exit a parse tree produced by AdvplParser#ObjectMethodAccess.
    def exitObjectMethodAccess(self, ctx:AdvplParser.ObjectMethodAccessContext):
        pass


    # Enter a parse tree produced by AdvplParser#Var.
    def enterVar(self, ctx:AdvplParser.VarContext):
        pass

    # Exit a parse tree produced by AdvplParser#Var.
    def exitVar(self, ctx:AdvplParser.VarContext):
        pass


    # Enter a parse tree produced by AdvplParser#lit.
    def enterLit(self, ctx:AdvplParser.LitContext):
        pass

    # Exit a parse tree produced by AdvplParser#lit.
    def exitLit(self, ctx:AdvplParser.LitContext):
        pass


    # Enter a parse tree produced by AdvplParser#ArrayOrBlock.
    def enterArrayOrBlock(self, ctx:AdvplParser.ArrayOrBlockContext):
        pass

    # Exit a parse tree produced by AdvplParser#ArrayOrBlock.
    def exitArrayOrBlock(self, ctx:AdvplParser.ArrayOrBlockContext):
        pass


    # Enter a parse tree produced by AdvplParser#MacroExecucao.
    def enterMacroExecucao(self, ctx:AdvplParser.MacroExecucaoContext):
        pass

    # Exit a parse tree produced by AdvplParser#MacroExecucao.
    def exitMacroExecucao(self, ctx:AdvplParser.MacroExecucaoContext):
        pass


    # Enter a parse tree produced by AdvplParser#IfCall.
    def enterIfCall(self, ctx:AdvplParser.IfCallContext):
        pass

    # Exit a parse tree produced by AdvplParser#IfCall.
    def exitIfCall(self, ctx:AdvplParser.IfCallContext):
        pass


    # Enter a parse tree produced by AdvplParser#Assume.
    def enterAssume(self, ctx:AdvplParser.AssumeContext):
        pass

    # Exit a parse tree produced by AdvplParser#Assume.
    def exitAssume(self, ctx:AdvplParser.AssumeContext):
        pass


    # Enter a parse tree produced by AdvplParser#NumberCHSay.
    def enterNumberCHSay(self, ctx:AdvplParser.NumberCHSayContext):
        pass

    # Exit a parse tree produced by AdvplParser#NumberCHSay.
    def exitNumberCHSay(self, ctx:AdvplParser.NumberCHSayContext):
        pass


    # Enter a parse tree produced by AdvplParser#atxCommand.
    def enterAtxCommand(self, ctx:AdvplParser.AtxCommandContext):
        pass

    # Exit a parse tree produced by AdvplParser#atxCommand.
    def exitAtxCommand(self, ctx:AdvplParser.AtxCommandContext):
        pass


    # Enter a parse tree produced by AdvplParser#arrayInitializer.
    def enterArrayInitializer(self, ctx:AdvplParser.ArrayInitializerContext):
        pass

    # Exit a parse tree produced by AdvplParser#arrayInitializer.
    def exitArrayInitializer(self, ctx:AdvplParser.ArrayInitializerContext):
        pass


    # Enter a parse tree produced by AdvplParser#blockInitializer.
    def enterBlockInitializer(self, ctx:AdvplParser.BlockInitializerContext):
        pass

    # Exit a parse tree produced by AdvplParser#blockInitializer.
    def exitBlockInitializer(self, ctx:AdvplParser.BlockInitializerContext):
        pass


    # Enter a parse tree produced by AdvplParser#blockParams.
    def enterBlockParams(self, ctx:AdvplParser.BlockParamsContext):
        pass

    # Exit a parse tree produced by AdvplParser#blockParams.
    def exitBlockParams(self, ctx:AdvplParser.BlockParamsContext):
        pass


    # Enter a parse tree produced by AdvplParser#LiteralNumber.
    def enterLiteralNumber(self, ctx:AdvplParser.LiteralNumberContext):
        pass

    # Exit a parse tree produced by AdvplParser#LiteralNumber.
    def exitLiteralNumber(self, ctx:AdvplParser.LiteralNumberContext):
        pass


    # Enter a parse tree produced by AdvplParser#LiteralStringDupla.
    def enterLiteralStringDupla(self, ctx:AdvplParser.LiteralStringDuplaContext):
        pass

    # Exit a parse tree produced by AdvplParser#LiteralStringDupla.
    def exitLiteralStringDupla(self, ctx:AdvplParser.LiteralStringDuplaContext):
        pass


    # Enter a parse tree produced by AdvplParser#LiteralStringSimples.
    def enterLiteralStringSimples(self, ctx:AdvplParser.LiteralStringSimplesContext):
        pass

    # Exit a parse tree produced by AdvplParser#LiteralStringSimples.
    def exitLiteralStringSimples(self, ctx:AdvplParser.LiteralStringSimplesContext):
        pass


    # Enter a parse tree produced by AdvplParser#LiteralLogical.
    def enterLiteralLogical(self, ctx:AdvplParser.LiteralLogicalContext):
        pass

    # Exit a parse tree produced by AdvplParser#LiteralLogical.
    def exitLiteralLogical(self, ctx:AdvplParser.LiteralLogicalContext):
        pass


    # Enter a parse tree produced by AdvplParser#LiteralNil.
    def enterLiteralNil(self, ctx:AdvplParser.LiteralNilContext):
        pass

    # Exit a parse tree produced by AdvplParser#LiteralNil.
    def exitLiteralNil(self, ctx:AdvplParser.LiteralNilContext):
        pass


    # Enter a parse tree produced by AdvplParser#ifFunctioncall.
    def enterIfFunctioncall(self, ctx:AdvplParser.IfFunctioncallContext):
        pass

    # Exit a parse tree produced by AdvplParser#ifFunctioncall.
    def exitIfFunctioncall(self, ctx:AdvplParser.IfFunctioncallContext):
        pass


    # Enter a parse tree produced by AdvplParser#chStatement.
    def enterChStatement(self, ctx:AdvplParser.ChStatementContext):
        pass

    # Exit a parse tree produced by AdvplParser#chStatement.
    def exitChStatement(self, ctx:AdvplParser.ChStatementContext):
        pass


    # Enter a parse tree produced by AdvplParser#defineCh.
    def enterDefineCh(self, ctx:AdvplParser.DefineChContext):
        pass

    # Exit a parse tree produced by AdvplParser#defineCh.
    def exitDefineCh(self, ctx:AdvplParser.DefineChContext):
        pass


    # Enter a parse tree produced by AdvplParser#activateCh.
    def enterActivateCh(self, ctx:AdvplParser.ActivateChContext):
        pass

    # Exit a parse tree produced by AdvplParser#activateCh.
    def exitActivateCh(self, ctx:AdvplParser.ActivateChContext):
        pass


    # Enter a parse tree produced by AdvplParser#setsCh.
    def enterSetsCh(self, ctx:AdvplParser.SetsChContext):
        pass

    # Exit a parse tree produced by AdvplParser#setsCh.
    def exitSetsCh(self, ctx:AdvplParser.SetsChContext):
        pass


    # Enter a parse tree produced by AdvplParser#paramType.
    def enterParamType(self, ctx:AdvplParser.ParamTypeContext):
        pass

    # Exit a parse tree produced by AdvplParser#paramType.
    def exitParamType(self, ctx:AdvplParser.ParamTypeContext):
        pass


    # Enter a parse tree produced by AdvplParser#classException.
    def enterClassException(self, ctx:AdvplParser.ClassExceptionContext):
        pass

    # Exit a parse tree produced by AdvplParser#classException.
    def exitClassException(self, ctx:AdvplParser.ClassExceptionContext):
        pass


    # Enter a parse tree produced by AdvplParser#crlf.
    def enterCrlf(self, ctx:AdvplParser.CrlfContext):
        pass

    # Exit a parse tree produced by AdvplParser#crlf.
    def exitCrlf(self, ctx:AdvplParser.CrlfContext):
        pass


    # Enter a parse tree produced by AdvplParser#crlfEmpty.
    def enterCrlfEmpty(self, ctx:AdvplParser.CrlfEmptyContext):
        pass

    # Exit a parse tree produced by AdvplParser#crlfEmpty.
    def exitCrlfEmpty(self, ctx:AdvplParser.CrlfEmptyContext):
        pass


