#INCLUDE "plsxfun.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SET.CH"
#INCLUDE "ap5mail.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PPLMFUN.CH"
#INCLUDE "TCBROWSE.CH"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

#DEFINE __aCdCri186 {"09L",OemToAnsi(STR0072) }//"Procedimento existente no pacote. ( Participações )."
#DEFINE __aCdCri178 {"09E",OemToAnsi(STR0073) }//"Bloqueio de pagamento ou exclusao da composicao ao negar sub-item."
#DEFINE __aCdCri179 {"09F",OemToAnsi(STR0074) }//"Bloqueio de pagamento, composicao nao autorizada no Atendimento."
#DEFINE __aCdCri09Z {"09Z","Guia Juridica - Esta guia não será submetida aos critérios de validação do sistema!"}

STATIC __lGloAuto	  := .f.
STATIC __aCritGlosas  := {}
STATIC __cLastDesc    := ""
STATIC __aMatCom	  := {}
STATIC __cOpeUsr      := {}
STATIC __aGuiJur	  := {.F.,.F.} // Guia Juridica: Autorizado a prosseguir ? ## Deve mandar pra Auditoria ?

STATIC __MV_PLGEPAD	  := getNewPar("MV_PLGEPAD","")
STATIC __tamBCF_CHAVE := tamSX3("BCF_CHAVE")[1]
STATIC __cCARGAPUB	  := PLSINICIA()
STATIC __lBCT_GLOATO  := BCT->( fieldPos("BCT_GLOATO")) > 0

STATIC __PLSA498GUI	  := .f.
STATIC __cFilBCF	  := xFilial('BCF')
STATIC __cFilBCT	  := xFilial('BCT')

/*/{Protheus.doc} PLSRetTit
Retorna um titulo de acordo com um alias.
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
Function PLSRetTit(cAlias)
local cRet    := ""
local cFilSX2 := NIL
local _cFilX2 := SX2->(DbFilter())

SX2->(DbClearFilter())
SX2->(DbSetOrder(1))
if SX2->(MsSeek(cAlias))
	cRet := allTrim(SX2->(X2NOME()))
endIf	


Set Filter To &_cFilX2

	
Return cRet

/*/{Protheus.doc} PLSGRAVERR
Grava erros em um formato padrao para uso externo
@type function
@author TOTVS
@since 28.08.01
@version 1.0
/*/
Function PLSGravErr(cTipo,uValor,aMsgErro)
	
If cTipo == "T" // Texto Simples
	aadd(aMsgErro,{"T",uValor})
ElseIf cTipo == "H" // Help padrao (funcao help)
	aadd(aMsgErro,{"H",uValor})
Endif
	
Return(aMsgErro)

/*/{Protheus.doc} PLSINTVLD
Retorna se a Operadora   e valida para o operador...
@type function
@author TOTVS
@since 28.08.01
@version 1.0
/*/
Function PLSINTVLD(cCodInt,cCodOpe)
LOCAL lRet      := .T.
DEFAULT cCodInt := &(ReadVar())
DEFAULT cCodOpe := RETCODUSR()

If ! cCodInt $ PLSINTAUT()
	HELP("",1,"PLSINTVLD")
	lRet := .F.
Endif
	
Return(lRet)

/*/{Protheus.doc} PLSVLDINT
Valida o conteudo da uma Operadora  ...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSVldInt(cCodInt,lPlsServer)
LOCAL lRet     		:= .T.
LOCAL lForcou 		:= .F.

DEFAULT lPlsServer 	:= PLSSERVER()
DEFAULT cCodInt    	:= PLSINTPAD()

// Estou sempre retornando .T. talvez nao seja necessario fazer a consistencia
// no usuario protheus x operadora....
If Empty(__cOpeUsr)
	__cOpeUsr := PLSINTAUT()
EndIf

lRet := ( cCodInt $ __cOpeUsr )

//alguns campos nao faz sentido fazer com que o usuario cadastre o operador do sistema com base na operadora
//por exemplo.: Campo Operadora na rotina Debito/Credito -> nesta rotina o campo operadora serve para identificara operadora para o qual sera feito o debito/credito

If ReadVar() $ "M->BSQ_CODINT" .Or. GetNewPar("MV_PLSUNI","0") == "1"
	lRet 	:= .T.
	lForcou := .T.
Endif

If !lForcou
	
	If ! lRet
		
		If ! lPlsServer
			HELP("",1,"PLSINTVLD")
		EndIf
		
	EndIf
	
	If lRet
		__cOpePad := cCodInt
	Else
		lRet := Empty(__cOpeUsr)
	EndIf
	
Else
	__cOpePad := plsIntPad()
Endif
	
Return(lRet)

/*/{Protheus.doc} PLSNAODISP
Retorna uma mensagem informando rotina nao disponivel
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSNAODISP(cFuncao)
	
	MsgInfo(OemtoAnsi(STR0003)+Chr(13)+Chr(13)+OemtoAnsi(STR0004)+cFuncao) //"Funcao ainda nao disponibilizada pelo departamento de sistemas"###"Codigo da Funcao "
	
Return

/*/{Protheus.doc} PLSISAUTO
Retorna se esta em modo automatico ou nao...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSISAUTO()
Return(If(__cInterNet=="AUTOMATICO",.T.,.F.))

/*/{Protheus.doc} PLSOBRIGAT
Mesma coisa do Obrigatorio mais o parametro lHelp
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSObrigat(aGets,aTela,tObg,lPlsServer,aMsgErro)
	Local i,n,bCampo,x,y, cText := "", cByte
	#ifdef ENGLISH
		Local aPos := {"First","Second","Third","Fourth","FIfth","Sixth","Seventh","Eigth","Nineth","Last"}
		Local cFold := "Folder"
	#else
		#ifdef SPANISH
			Local aPos := {"Primera","Segunda","Tercera","Quarta","Quinta","Sexta","Septima","Octava","Novena","Ultima"}
			Local cFold := "Carpeta"
		#else
			Local aPos := {"Primeira","Segunda","Terceira","Quarta","Quinta","Sexta","Setima","Oitava","Nona","Ultima"}
			Local cFold := "Pasta"
		#endif
	#endif
	DEFAULT lPlsServer := PLSSERVER()
	bCampo := {|nCPO| Field(nCPO) }
	tObg:=""
	FOR i:=1 TO LEN(aGETS)
		If SubStr(aGETS[i],22,1) == "T" .AND. Empty(M->&(SubStr(aGETS[i],9,10)))
			AchaATELA(@x,@y,i,aTela)
			If x*y > 0
				tObg:=tObg+aTELA[x][y]
				If Empty(ctext)
					cByte := Subs(aGets[i],24,1)
					If cByte == " "
						cText := Subs(aTela[x,y],1,18)
					ElseIf cByte$"123456789"
						cText := Subs(aTela[x,y],1,18)+" -> "+aPos[Val(cByte)]+" "+cFold
					Else
						cText := Subs(aTela[x,y],1,18)+" -> "+aPos[10]+" "+cFold
					EndIf
				EndIf
			Else
				tObg := "VV"
			EndIf
		EndIf
		
	NEXT i
	
	cText := cText + Space(50-Len(cText))
	
	If LEN(tObg) > 0
		If ! lPlsServer
			Help(1," ","OBRIGAT",,cText,3,0)
		Endif
		PLSGravErr("H","OBRIGAT",@aMsgErro)
		Return(IF(!lPlsServer,.F.,{.F.,aMsgErro}))
	EndIf
Return(.T.)

/*/{Protheus.doc} PLSINTAUT
Lista as Operadoras   autorizadas para um operador...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSINTAUT(cCodOpe)
	LOCAL cRet      := ""
	DEFAULT cCodOpe := PLSRtCdUsr()
	
	BX4->(DbSetOrder(1))
	If BX4->(MsSeek(xFilial("BX4")+cCodOpe))
		While ! BX4->(Eof()) .And. BX4->(BX4_FILIAL+BX4_CODOPE) == xFilial("BX4")+cCodOpe
			cRet += BX4->BX4_CODINT+","
			BX4->(DbSkip())
		Enddo
	Endif
	
Return(cRet)

/*/{Protheus.doc} PLSINTPAD
Retorna a Operadora   padrao para um operador...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
function PLSINTPAD()

if empty(__MV_PLGEPAD)

	if empty(__cOpePad)
		
		aviso( 	OemtoAnsi(STR0005), ; //"Parametrizacao Operadora"
				OemtoAnsi(STR0006)+AllTrim(PLRETOPE())+OemtoAnsi(STR0007),; //"O Usuario '"###"' esta sem parametrizacao para uma ou mais Operadoras. Isso deve ser feito antes de utilizar esta e outras opcoes do sistema"
				{ OemtoAnsi(STR0008) }, 2 ) 	                                                                     //"Ok"
		
	endIf
	
else
	
	__cOpePad := __MV_PLGEPAD
	
endIf

return(__cOpePad)

/*/{Protheus.doc} PLSRTMASPR
Retorna procedimento com sua mascara padrao...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSRTMASPR(cCodPad,cCodPSA)
	LOCAL   cMascara   := "@R "
	
	BA8->(DbSetOrder(3))
	If BA8->(MsSeek(xFilial("BA8")+cCodPad+cCodPSA))
		
		BF8->(DbSetOrder(1))
		If BF8->(MsSeek(xFilial("BF8")+BA8->BA8_CODTAB))
			
			While ! BF8->(Eof()) .And. BF8->(BF8_FILIAL+BF8_CODINT+BF8_CODIGO) == xFilial("BF8")+BA8->BA8_CODTAB
				cMascara += Replicate("!",Val(BF8->BF8_DIGITO))+BF8->BF8_SEPARA
				BF8->(DbSkip())
			Enddo
		Endif
	Endif
	
Return(TransForm(cCodPSA,cMascara))

/*/{Protheus.doc} PlsSinc
Funcao para replicao de campos de uma tabela para outra
@type function
@author TOTVS
@since 02.10.2001
@param cProg  ,   caracter, Codigo do programa para referencia na sincronizacao
@param cAlias1,   caracter, Alias de origem dos campos
@param cAlias2,   caracter, Alias de destino dos campos
@param lEmpty,    Logico, Verifica se Estiver Vazio o Campo antes para não Limpar na integração
@param lLeTab,   Logico, Informa se deve usar os dados de uma determinada tabela que deverá ser posicionada
@param nRecAlia1, Recno para posicionar no alias contido em cAlias1 (usar somente se precisar dos dados da tabela e não da memória)
@param nIndAlia1, Indice para posicionar no alias contido em cAlias1 (usar somente se precisar dos dados da tabela e não da memória),
				  Só deve ser usado caso não use o recno.
@param cChvAlia1, Chave para posicionar no alias contido em cAlias1 (usar somente se precisar dos dados da tabela e não da memória),
				  Só deve ser usado caso não use o recno e não deve conter a filial na chave.
				  O conteúdo deve ser o valor que deverá ser localizado na tabela.
@param nRecAlia2, Recno para posicionar no alias contido em cAlias2 (usar somente se precisar dos dados da tabela e não da memória)
@param nIndAlia2, Indice para posicionar no alias contido em cAlias2 (usar somente se precisar dos dados da tabela e não da memória),
				  Só deve ser usado caso não use o recno.
@param cChvAlia2  Chave para posicionar no alias contido em cAlias2 (usar somente se precisar dos dados da tabela e não da memória),
				  Só deve ser usado caso não use o recno e não deve conter a filial na chave.
				  Deverá passar os campos referentes ao alias cAlias1 que deverá ser usado para posicionar na tabela do cAlias2
				  Exemplo: "BA1_CODINT+BA1_CODEMP+BA1_MATRIC"	
@version 1.0
/*/
Function PlsSinc(cProg, cAlias1, cAlias2, lEmpty, lLeTab, nRecAlia1, nIndAlia1, cChvAlia1, nRecAlia2, nIndAlia2,cChvAlia2)  
	
	Local   aArea     := GetArea()
	Local   lOK1      := .F.
	Local   lOK2      := .F.
	Local   cAliasUsu := ""   
	Local   lRetSekTb := .T.
	
	Default lEmpty    :=.F.
	Default lLeTab   := .F.
	Default nRecAlia1 := 0
	Default nIndAlia1 := 0
	Default cChvAlia1 := ""
	Default nRecAlia2 := 0
	Default nIndAlia2 := 0
	Default cChvAlia2 := ""
	
	cProg := PadR(cProg,10)
	BBL->(DbSetOrder(2))
	
	If BBL->(MsSeek(xFilial()+cProg+cAlias1+cAlias2))
		
		//Com a variável lLeMemo true, não irá considerar os dados da memoria, e sim os dados de uma tabela posicionada.
		/*Com o lLeMemo true, alem de posicionar na tabela de onde os dados serão extraídos,
		  é obrigatório posicionar na tabela que será sincronizada,caso contrário
		  o sistema irá considerar os valores da memoria do alias contido na variável cAlias1 podendo
		  causar error log em determinada situação
		*/
		If lLeTab

			//Utiliza o recno para posicionar na tabela 
			If nRecAlia1 != 0 

				&(cAlias1)->(DbGoTo(nRecAlia1))
				
				//verifica se o registro existe e se foi posicionado corretamente
				If &(cAlias1)->(Recno()) == nRecAlia1
					cAliasUsu := cAlias1+"->"
				EndIf

			ElseIf nIndAlia1 > 0 .AND. !EMPTY(cChvAlia1)

				&(cAlias1)->(DbSetOrder(nIndAlia1))

				//Faz um seek para posicionar no registro correto, se não vai continuar buscando os dados da memória
				If &(cAliasUsu)->(MsSeek(xFilial(cAliasUsu) + cChvAlia1))
					cAliasUsu := cAlias1+"->"
				EndIf
			EndIf

			/*Para posicionar na tabela que será sincronizada é obrigatório ter posicionado na tabela de onde serão
			extraido os dados.*/
			If nRecAlia2 != 0 .AND. !EMPTY(cAliasUsu)

				&(cAlias2)->(DbGoTo(nRecAlia2))
				
				//Se o recno não existe, o processo de sincronização não será executado
				If &(cAlias2)->(Recno()) != nRecAlia2
					lRetSekTb := .F.
				EndIf
	
			ElseIf nIndAlia2 > 0 .AND. !EMPTY(cChvAlia2) .AND. !EMPTY(cAliasUsu)

				&(cAlias2)->( DbSetOrder( nIndAlia2))
				
				/*Faz um seek para posicionar no registro correto, se não não encontrou, o processo de 
				  sincronização não será executado, pois o beneficiário nem sempre estará cadastrado
				  na tabela correspondente 
				*/
				If !&(cAlias2)->( MsSeek( xFilial(cAlias2) + &(cAlias1+"->"+(cChvAlia2))))
					lRetSekTb := .F.
				EndIf
			Else
				
				/*Se não posicionou na tabela contida na variável cChvAlia2, volta ao padrão de utilização da memória
				  pois é obrigatório posicionar nas duas tabelas corretamente para usar essa regra  
				*/
				cAliasUsu := "M->"
			EndIf
		
		Else
			cAliasUsu := "M->"
		EndIf

		If lRetSekTb

			//Da reclock, dessa forma não precisa nem posicionar e nem dar reclock fora da função
			If cAliasUsu != "M->"
				&(cAlias2)->( recLock(cAlias2,.F.) )
			EndIf

			While !BBL->(Eof()) .and. cProg == BBL->BBL_PROGRA .and. BBL->BBL_ALIAS1 == cAlias1 .and. BBL->BBL_ALIAS2 == cAlias2
				
				lOK1 := .T.
				lOK2 := .T.
				
				DbSelectArea(BBL->BBL_ALIAS2)
				lOK1 := FieldPos(BBL->BBL_CAMPO2) > 0
				
				If ! lOK1

					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"SIGAPLS - "+STR0031+STR0032+" ["+BBL->BBL_ALIAS2+"] "+STR0033+" ["+AllTrim(BBL->BBL_CAMPO2)+"] . "+STR0034+" PLSM160." , 0, 0, {})//"Tabela de Sincronismo invalida. "###"Tabela"###"campo"###"Efetuar a manutenção no cadastro através do programa"		
					
				Endif
				
				DbSelectArea(BBL->BBL_ALIAS1)
				lOK2 := FieldPos(BBL->BBL_CAMPO1) > 0
				
				If lOK2
					lOK2 := Type(cAliasUsu+AllTrim(BBL->BBL_CAMPO1)) <> "U"
				Endif
				
				If ! lOK2

					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"SIGAPLS - "+STR0031+STR0033+" ["+cAliasUsu+AllTrim(BBL->BBL_CAMPO1)+"] . "+STR0034+" PLSM160." , 0, 0, {})//"Tabela de Sincronismo invalida. "###"campo"###"Efetuar a manutenção no cadastro através do programa"		

				Endif
				
				If lOK1 .And. lOK2
					If AllTrim(BBL->BBL_CAMPO2) == "A2_COD_MUN"
						SA2->A2_COD_MUN := SubStr(&(cAliasUsu+AllTrim(BBL->BBL_CAMPO1)),3)
						cCodMun := SubStr(BID->BID_CODMUN,3)
						cCodEst	:= BID->BID_EST
						SA2->A2_MUN := BID->BID_DESCRI
					ElseIf AllTrim(BBL->BBL_CAMPO2) == "A1_COD_MUN"
						SA1->A1_COD_MUN := SubStr(&("M->"+AllTrim(BBL->BBL_CAMPO1)),3)
						SA1->A1_MUN := BID->BID_DESCRI
					ElseIf AllTrim(BBL->BBL_CAMPO2) == "A1_END"
						If AllTrim(BBL->BBL_CAMPO1) $ 'BA1_ENDERE/BTS_ENDERE'
							SA1->A1_END := Alltrim(&(cAliasUsu+AllTrim(BBL->BBL_CAMPO1)))+ IIF(Empty(Alltrim(&(cAliasUsu+Alltrim(BBL->BBL_ALIAS1)+"_NR_END"))),""," ,"+ Alltrim(&(cAliasUsu+Alltrim(BBL->BBL_ALIAS1)+"_NR_END")))
						Else
							SA1->A1_END := &(cAliasUsu+AllTrim(BBL->BBL_CAMPO1))
						Endif	
					ElseIf lEmpty  // Verifica se Estiver Vazio o Campo antes para não Limpar na integração
						If !Empty(&(cAliasUsu+AllTrim(BBL->BBL_CAMPO1)))
							&(BBL->BBL_ALIAS2+"->"+AllTrim(BBL->BBL_CAMPO2)) := &(cAliasUsu+AllTrim(BBL->BBL_CAMPO1))
						Endif
					ElseIf AllTrim(BBL->BBL_CAMPO2) $ "BA1_ORIEND/BA1_BAIRRO/BA1_CEPUSR/BA1_CODMUN/BA1_COMEND/BA1_ENDERE/BA1_MUNICI/BA1_NR_END/BA1_ESTADO"
						//Origem do endereço caso a opção for 5=Resp. Fam e não for responsavel da familia não podera atualizar o endereço
						If BA1->BA1_ORIEND  <> "5" .OR. BA1->BA1_RESFAM <> "0"
							&(BBL->BBL_ALIAS2+"->"+AllTrim(BBL->BBL_CAMPO2)) := &(cAliasUsu+AllTrim(BBL->BBL_CAMPO1))
						Endif
					Else
						&(BBL->BBL_ALIAS2+"->"+AllTrim(BBL->BBL_CAMPO2)) := &(cAliasUsu+AllTrim(BBL->BBL_CAMPO1))
					Endif
				Endif
				
				BBL->(DbSkip())
			EndDo

			If cAliasUsu != "M->"
				&(cAlias2)->( MsUnLock() )
			EndIf
		EndIf
	Else
		If GetNewPar("MV_PLSMSGS","1") == "1"
			MsgAlert(OemtoAnsi(STR0009)+cAlias1+" x "+cAlias2+OemtoAnsi(STR0010))	 //"Arquivo de sincronismo entre "###" nao esta integro. Verifique!"
		Endif
	endif
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} PlsDigi
Funcao de calculo do digito verificador
@type function
@author TOTVS
@since 02.10.2001
@param cCodigo, caracter, Codigo que sera gerado o digito verificador
@param nModulo, caracter, Modulo para calculo do digito (11=DEFAULT)
@version 1.0
/*/
Function PlsDigi(cCodigo,nModulo)
	DEFAULT nModulo := 11
	cRet := SubStr(Str(Mod(Val(cCodigo),nModulo),2),2,1)
Return cRet

/*/{Protheus.doc} PlsZero
Preenche com zeros a esquerda o campo ou variavel
@type function
@author TOTVS
@since 04.10.2001
@param cVar, caracter, nome do campo (DEVE SER PASSADO ENTRE ASPAS)
@version 1.0
/*/
Function PlsZero(cVar,nTam)
Local nI		:= 0
Local lPode 	:= .T.
Local cPar 		:= getNewPar("MV_PLSUNI","0")//verifica o parametro, caso 1-unimed, passar pelo if

DEFAULT cVar 	:= ReadVar()
DEFAULT nTam 	:= Iif(!Empty(cVar),Len(&cVar),0)

// protege para que a digitação do campo numero do impresso não possa ultrapassar
// o tamanho de 11 posições previsto nas normas do PTU

If cVar $ "M->BE1_NUMIMP|M->BE4_NUMIMP|M->BD5_NUMIMP" .AND. cPar == "1"
	nTam := 11
EndIF

//fim verificaçao

If Empty(&cVar)
	Return .T.
Endif

For nI := 1 to nTam
	If !(SubStr(&cVar,nI,1) $ " 0123456789")
		lPode := .F.
		Exit
	EndIf
Next

If lPode
	&cVar := StrZero(Val(Substr(&cVar,1,nTam)),nTam)
EndIf
	
Return .T.
/*/{Protheus.doc} PlsIguala
Iguala variavel PRIVATE de acordo com valor fornecido
@type function
@author TOTVS
@since 06.11.2001
@param cVar, caracter, Nome da variavel
@param uVal, caracter, Valor a igualar
@version 1.0
/*/
Function PlsIguala(cVar,uVal)
	&cVar := uVal
Return .T.

/*/{Protheus.doc} PLSXUSRBLO
Retorna usuario bloqueado ou nao...
@type function
@author TOTVS
@since 05.03.2002
@version 1.0
/*/
Function PLSXUsrBlo(cAno,cMes,dDatBlo,cMotBlo)
	LOCAL lRet := .T.
	
	If ! Empty(cMotBlo)
		If cAno+cMes >= Subs(dtos(dDatBlo),1,6)
			lRet := .F.
		Endif
	Endif
	
Return(lRet)

/*/{Protheus.doc} PLSRETGLO
Retorna descricao da glosa...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSRETGLO(cCodOpe,cCodGlo)
LOCAL cRet

BCT->(DbSetOrder(1))
If BCT->(MsSeek(xFilial("BCT") + cCodOpe + cCodGlo))
	cRet := BCT->BCT_DESCRI
Else
	cRet := space( len(BCT->BCT_DESCRI) )
Endif
	
Return(cRet)

/*/{Protheus.doc} PLSCHKCRI
Checa se a critica tem excecao no nivel correspondente
@type function
@author TOTVS
@since 27.07.2010
@version 1.0
/*/
function PLSCHKCRI(aDadPar)
local lRet			:= .t.
local nTamanho		:= 0
local cCodOpe		:= __cOpePad
local cTabela		:= iIf( len(aDadPar) >= 1,aDadPar[1],"" )
local cChave 		:= iIf( len(aDadPar) >= 2,aDadPar[2],"" )
local cCodCri		:= iIf( len(aDadPar) >= 3,aDadPar[3],"" )

// Se a critica foi informada
if ! empty(cCodCri) .and. ! empty(cChave)

	nTamanho := __tamBCF_CHAVE

	// Ajusta o tamanho da chave
	cChave := cChave + space( nTamanho - len(cChave) )

	// Valida conforme o nivel
	BCF->( dbSetOrder(1) )
	lRet := ! BCF->( msSeek( __cFilBCF + cCodOpe + cTabela + cChave + cCodCri ) )
	
endIf

return lRet

/*/{Protheus.doc} PCLPGAUTO
retorna se uma critica e para glocar automatico
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
function PCLPGAUTO()
return __lGloAuto

/*/{Protheus.doc} PCLPOSGLO
lima matriz ao alterar qualquer critica
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
function PCLPOSGLO()
__aCritGlosas := {}
return

/*/{Protheus.doc} PLSPOSGLO
Posiciona em uma determinada glosa...
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSPOSGLO(cCodOpe,cCodGlo,cDescri,cLocalExec,cAtivo,cTpLocExec,cAudito,lAnaAmbos)
local nPos			:= 0
local cPropri		:= ""
local cLocAna		:= ""
local cProt			:= ""
local cPos			:= ""
local cWeb			:= ""
local cEnvCox		:= ""
local lRet			:= .t.

default cDescri    	:= ""
default cLocalExec 	:= "1"
default cAtivo     	:= "1"
default cTpLocExec  := "1" //"1" Remote Protheus  "2" WEB  "3" POS "4" ---- "5" XML
default cAudito		:= ""
default lAnaAmbos   := .f.

// esse item se faz necessario devido as varias chamadas do plsposglo com o parametro cTpLocExec em branco e vindo da web, e assim não respeitando o campo BCT_WEB
if funName() == 'RPC' 
	cTpLocExec := "2"
endIf

nPos := aScan(__aCritGlosas,{ |x| x[1] == __cFilBCT + cCodOpe + cCodGlo })

if nPos == 0

	BCT->( dbSetOrder(1) )

	If ! BCT->( msSeek( __cFilBCT + cCodOpe + cCodGlo) )
	
		BCT->( recLock("BCT",.T.) )
		
			BCT->BCT_FILIAL  := __cFilBCT
			BCT->BCT_CODOPE  := cCodOpe
			BCT->BCT_PROPRI  := Subs(cCodGlo,1,1)
			BCT->BCT_CODGLO  := Subs(cCodGlo,2,2)
			BCT->BCT_DESCRI  := cDescri
			BCT->BCT_TIPO    := "1"
			BCT->BCT_USO     := "3"
			BCT->BCT_ATIVO   := cAtivo
			BCT->BCT_RESOBR  := "0"
			BCT->BCT_NIVEL   := "2"
			BCT->BCT_PERFOR  := "0"
			BCT->BCT_LOCANA  := "3"			
			BCT->BCT_AUDITO  := cAudito
			BCT->BCT_PROT := "1"
			BCT->BCT_POS  := "1"
			BCT->BCT_WEB  := "1"
			
			if __lBCT_GLOATO
				BCT->BCT_GLOATO  := "0"
			endIf
			
		BCT->( MsUnLock() )
		
	endIf
	
	aadd(__aCritGlosas,{BCT->(BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO),;
						BCT->BCT_PROPRI,;
						BCT->BCT_ATIVO,;
						Iif(lAnaAmbos,"3",BCT->BCT_LOCANA),;
						BCT->BCT_PROT,;
						BCT->BCT_POS,;
						BCT->BCT_WEB,;
						BCT->BCT_DESCRI,;
						BCT->BCT_ENVCOX,;
						iIf(__lBCT_GLOATO,BCT->BCT_GLOATO,'0')})
						
	nPos := len(__aCritGlosas)

endIf

cPropri     := __aCritGlosas[nPos,2]
cAtivo      := __aCritGlosas[nPos,3]
cLocAna     := __aCritGlosas[nPos,4]
cProt       := __aCritGlosas[nPos,5]
cPos        := __aCritGlosas[nPos,6]
cWeb        := __aCritGlosas[nPos,7]
__cLastDesc := __aCritGlosas[nPos,8]
cEnvCox	    := __aCritGlosas[nPos,9]

if __lBCT_GLOATO
	__lGloAuto := __aCritGlosas[nPos,10] == '1'
endIf

// De sistema sempre critica...
if cPropri $ "5,X"

	if cAtivo == "1"
		lRet := .t.
	else
		lRet := .f.
	endIf

elseIf ( cPropri $ "0,7,9" ) .And. ( ( cLocAna $ " ,3" ) .Or. ( cLocAna == cLocalExec ) ) .And. ( cAtivo == "1" )
	
	if empty(cTpLocExec)
	
		lRet := .t.
		
	elseIf ! empty(cTpLocExec)

		if cTpLocExec $ "1,4"
			
			//Protheus
			if cProt $ " ,1" 
				lRet := .T.
			else
				lRet := .F.
			endIf

		elseIf cTpLocExec == "2"
			
			//Web
			if cWeb $ " ,1" 
				lRet := .T.
			else
				lRet := .F.
			endIf

		elseIf cTpLocExec == "3"
			
			//Pos
			if cPos $ " ,1" 
				lRet := .T.
			else
				lRet := .F.
			endIf

		else
			lRet := .T.
		endIf

	else
		lRet := .T.
	endIf

else
	lRet := .F.
endIf

//se a critica esta inativa, estou na validacao do xml e o campo para envio de
//guia para conferencia esta habilitado o sistema habilita a critica
if ! lRet .and. cLocalExec == '5' .and. cEnvCox == '1'
	lRet := .t.
endIf

//se veio da geração da Guia de Recurso de glosa não haverá nenhum
//tipo de crítica.
//Essa nova guia serve apenas para pagamento e o seu valor é acordado entre
//a operadora e o prestador, por isso nada pode ser criticado.

if lRet

	//a variavel __PLSA498GUI foi criada para melhor performace 
	//o ideal e tratar os pontos de chamadas da plsposglo e nao fazer o tratamento abaixo.
	if __PLSA498GUI 
		lRet := .f.
	endIf
	
endIf	
	
return(lRet)

/*/{Protheus.doc} PLSBCTDESC
Retorna a descricao de uma glosas
@type function
@author TOTVS
@since 28.08.2001
@version 1.0
/*/
Function PLSBCTDESC()
//no futuro vamos implementar aqui um IFDEF espanhol e ingles
Return(__cLastDesc)

/*/{Protheus.doc} PlsCodSup
Gera Codigo da Natureza Superior
@type function
@author TOTVS
@since 05.06.03
@param cCodigo, caracter, Codigo da Natureza
@param cGruGen, caracter, Grupo Gerencial
@version 1.0
/*/
Function PlsCodSup(cCodigo,cGruGen)
	
	Local aArea, aAmbBF0
	Local cCod  := "" , nCont, nPos := 1
	
	cCodigo		:= Alltrim(cCodigo)
	aArea    	:= GetArea()
	aAmbBF0  	:= BF0->(GetArea())
	
	dbSelectArea("BF0") ; dbSetOrder(1)
	
	For nCont := Len(cCodigo) to 1 Step - 1
		cCod  := padr(Left(cCodigo,Len(cCodigo)-nPos),20)
		nPos ++
		If MsSeek(xFilial()+cGruGen+cCod,.f.)
			cCod := BF0->BF0_CODIGO
			Exit
		Endif
	Next
	
	M->BF0_CODSUP := cCod
	BF0->(RestArea(aAmbBf0))
	RestArea(aArea)
	
Return .T.

/*/{Protheus.doc} PlsCodSup
Valida Codigo Superior na inclusao da natureza de Saude
@type function
@author TOTVS
@since 05.06.03
@param cCodigo, caracter, Codigo da Natureza Superior
@param cGruGen, caracter, Grupo Gerencial
@version 1.0
/*/
Function PlsVldSup(cCodigo, cGruGen)
	
	Local aSaveArea	:= GetArea()
	Local lRet		:= .T.
	
	dbSelectArea("BF0")
	dbSetOrder(1)
	
	If ! Empty(cCodigo)
		If !MsSeek(xFilial()+cGruGen+cCodigo)	//A natureza deve existir nas Naturezas de Saude
			Help("  ", 1, "NOCADBF0SU")
			lRet := .F.
		EndIf
		If lRet
			If BF0->BF0_CLASSE != "1"			//A Natureza superior deve ser sintetica.
				Help(" ",1,"NOBF0SINTE")
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aSaveArea)
	
Return lRet

/*/{Protheus.doc} PLSPROAM
Acumula 1 mes em um mes e ano passado
@type function
@author TOTVS
@since 17.09.03
@version 1.0
/*/
Function PLSPROAM(cAno,cMes)
	
	If cMes == "12"
		cAno := StrZero(Val(cAno)+1,4)
		cMes := "01"
	Else
		cMes := StrZero(Val(cMes)+1,2)
	Endif
	
Return({cAno,cMes})

/*/{Protheus.doc} PLSSXBSRA
Pesquisa SXB customizada para exibir o cadastro tabela SRA, onde a pesquisa customizada.
@type function
@author TOTVS
@since 18/10/04
@version 1.0
/*/
Function PLSSXBSRA()
	Local oDlg, oBtOk, oBtCancel, oOrder, oChave, oSelect
	Local nOpc  := 0
	Local cOrder := OemtoAnsi(STR0011) //"Matrícula"
	Local cChave := PadR( &( ReadVar() ), TamSX3("RA_NOME")[1] )
	Local aOrders := {}
	Local aCpoBrw := {}
	Local cFilter := ""
	Local cTitle := OemtoAnsi(STR0012) //"Seleção de Funcionário"
	Local aIndexSRA := {}
	Local bFiltraBrw
	Local nPosSRA
	Local nTamFil := FWSIZEFILIAL()
	Aadd(aOrders,OemtoAnsi(STR0011)) //"Matrícula"
	Aadd(aOrders,OemtoAnsi(STR0013)) //"Centro Custo"
	Aadd(aOrders,OemtoAnsi(STR0014)) //"Nome"
	
	aAdd( aCpoBrw, { GetSx3Cache("RA_FILIAL","X3_CAMPO"),, GetSx3Cache("RA_FILIAL","X3_TITULO") , GetSx3Cache("RA_FILIAL","X3_PICTURE")} )
	aAdd( aCpoBrw, { GetSx3Cache("RA_MAT","X3_CAMPO"),, GetSx3Cache("RA_MAT","X3_TITULO") , GetSx3Cache("RA_MAT","X3_PICTURE")} )
	aAdd( aCpoBrw, { GetSx3Cache("RA_NOME","X3_CAMPO"),, GetSx3Cache("RA_NOME","X3_TITULO") , GetSx3Cache("RA_NOME","X3_PICTURE")} )
	aAdd( aCpoBrw, { GetSx3Cache("RA_CC","X3_CAMPO"),, GetSx3Cache("RA_CC","X3_TITULO") , GetSx3Cache("RA_CC","X3_PICTURE")} )
	
	Define msDialog oDlg title cTitle from 000,000 to 300,500 pixel
	
	bFiltraBrw	:= { || FilBrowse( "SRA" , @aIndexSRA , "RA_SITFOLH <> 'D'" ) }
	Eval( bFiltraBrw )
	
	oSelect := MsSelect():New("SRA",,,aCpoBrw,,,{ 003, 003, 117, 220 },"PLFilFil('"+Space(nTamfil)+"')","PLFilFil('"+Replicate('Z',nTamFil)+"')",oDlg)
	oSelect:bAval := {|| nOpc := 1, oDlg:End() }
	oSelect:oBrowse:Refresh()
	
	@ 125,004 say OemtoAnsi(STR0015) size 40,08 of oDlg pixel //"Ordenar por:" //"Ordenar por:"
	@ 125,042 combobox oOrder var cOrder items aOrders size 125,08 of oDlg pixel valid PLFindSRA(aIndexSra,oOrder:nAt,,bFiltraBrw,oSelect)
	@ 137,004 say OemtoAnsi(STR0016) size 40,08 of oDlg pixel //"Localizar:" //"Localizar:"
	@ 137,042 get oChave var cChave size 125,08 of oDlg pixel valid PLFindSRA(aIndexSra,oOrder:nAt,cChave,bFiltraBrw,oSelect)
	define sbutton oBtOk     from 003,220 type 1 enable action ( nOpc := 1, oDlg:End() ) of oDlg pixel
	define sbutton oBtCancel from 017,220 type 2 enable action ( nOpc := 0, oDlg:End() ) of oDlg pixel
	
	Activate MsDialog oDlg Centered
	
	nPosSRA := SRA->(RecNo())
	
	// Deleta o filtro utilizando a funcao FilBrowse
EndFilBrw("SRA",aIndexSra)

SRA->(dbGoTo(nPosSRA))

Return(.t.)

/*/{Protheus.doc} PLFindSRA
Rotina para tratar a busca na escolha da MsSelect
@type function
@author TOTVS
@since 20/10/04
@version 1.0
/*/
Static Function PLFindSRA(aIndexSra,nAt,cChave,bFiltraBrw,oSelect)
	Local lFind :=.f.
	Local nCont
	Local aEmpresas	  := AdmAbreSM0()
	Local nTamFil     := FWSIZEFILIAL()
EndFilBrw("SRA",aIndexSra)
SRA->( dbSetOrder( nAt ) )

If cChave <> NIL
	cChave := Alltrim(cChave)
	nCont := Ascan(aEmpresas,{|x| Substr(x[1],1,2) == FWGrpCompany() } )
	
	If nCont > 0
		For nCont:= nCont to Len(aEmpresas)
			If FWGrpCompany() <> Alltrim(aEmpresas[nCont,1])
				Exit
			EndIF
			
			lFind:= SRA->( MsSeek( Substr(aEmpresas[nCont,2],1,nTamFil)+cChave , .F. ) )
			If lFind
				Exit
			Endif
		Next
	Else
		lFind:= SRA->( MsSeek(cChave, .F. ))
	Endif
	If !lFind
		Alert(OemtoAnsi(STR0017)) //"Funcionario nao encontrado"
	Endif
Endif

Eval( bFiltraBrw)
oSelect:oBrowse:Refresh()
Return .t.

/*/{Protheus.doc} PLFilFil
Busca as filiais pois onde ela eh chamada nao aceita informar direto o conteudo. Tem que chamar uma funcao.
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
Function PLFilFil(cRet)
Return(cRet)

/*/{Protheus.doc} PLSendMail
Rotina para tratar o envio do e-mail após a geracao via oPrinter.
@type function
@author TOTVS
@since 20/10/04
@version 1.0
/*/
Function PLSendMail(oPrinta,lDireto)
Private aUsuario    := "", oDlgMail, nOp:=0
Private aFiles 		   := {}, lDiret:=lDireto, oPrint:=oPrinta
Private cFrom       := ""
Private cServer     := AllTrim(GetNewPar("MV_RELSERV"," "))//servidor de email
Private cAccount    := AllTrim(GetNewPar("MV_RELACNT"," ")) // conta
Private cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," ")) // senha
Private nTimeOut    := GetMv("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexão
Private lAutentica  := GetMv("MV_RELAUTH",,.F.) //Determina se o Servidor de Email necessita de Autenticação
Private cUserAut    := Alltrim(GetMv("MV_RELAUSR",,cAccount)) //Usuário para Autenticação no Servidor de Email
Private cPassAut    := Alltrim(GetMv("MV_RELAPSW",,cPassword)) //Senha para Autenticação no Servidor de Email
Private cTo         := space(200)
Private cCC         := space(200)
Private cSubject    := space(250)
Private cDocument   := oPrint:cDocument, cDiretorio:="", x:=1

If !lDiret
	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUsuario := PswRet(1)
	cFrom := cUserName
	cCC := cCC + SPACE(200)
	DEFINE MSDIALOG oDlgMail OF oMainWnd FROM 0,0 TO 200,544 PIXEL TITLE OemtoAnsi(STR0018)   //"Envio de Email"
	@ 5,4  To 079,268   OF oDlgMail PIXEL
	@ 18,8  Say OemtoAnsi(STR0019)   Size 12,8             OF oDlgMail PIXEL //"De: "
	@ 33,8  Say OemtoAnsi(STR0020)  Size 16,8             OF oDlgMail PIXEL //"Para:"
	@ 48,8  Say OemtoAnsi(STR0021)    Size 16,8             OF oDlgMail PIXEL //"CC:"
	@ 63,8  Say OemtoAnsi(STR0022) Size 21,8           OF oDlgMail PIXEL //"Assunto:"
	
	@ 18,33  MSGet cFrom    Size 233,10  When .F. OF oDlgMail PIXEL
	@ 33,33  MSGet cTo      Size 233,10  F3 "_EM" OF oDlgMail PIXEL
	@ 48,33  MSGet cCC      Size 233,10  F3 "_EM" OF oDlgMail PIXEL
	@ 63,33  MSGet cSubject Size 233,10           OF oDlgMail PIXEL
	DEFINE SBUTTON FROM 85,100 TYPE 1 ACTION (If(!Empty(cTo),If(oDlgMail:End(),nOp:=1,),Help("",1,"AVG0001054"))) ENABLE OF oDlgMail PIXEL
	DEFINE SBUTTON FROM 85,140 TYPE 2 ACTION (oDlgMail:End()) ENABLE OF oDlgMail PIXEL
	
	ACTIVATE MSDIALOG oDlgMail CENTERED
Else
	nOp:=1
EndIf

If nOp = 1
	MsAguarde({||PLGeraMail()},OemtoAnsi(STR0023),OemtoAnsi(STR0024))      //"Aguarde......."###" Enviando Email"
EndIf

Return Nil

/*/{Protheus.doc} PLGeraMail
(long_description)
@type function
@author TOTVS
@since 20/10/04
@version 1.0
/*/
Function PLGeraMail()
Local cSequencia	:= "", X
Local cAnexos     	:= ""
Local lOk       	:= .T.
Private cBody:=""

cDiretorio	:= GetSrvProfString("Startpath","")

cSequencia := substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)

SetMV("MV_SEQAVP",cSequencia)

If ! oPrint:SaveAllAsJPEG( cDiretorio+Alltrim(cSequencia),1120,840,140) // Passar o diretório abaixo do root path + as 3 primeiras letras do nome do arquivo a ser gerado
	Help("",1,"AVG0001055")
	Return .F.
EndIf

If !lDiret
	MsProcTxt(OemtoAnsi(STR0025)) //"Processando"
	cBody  := OemtoAnsi(STR0026) + cDocument //"Arquivo "
	
	aFiles := Directory( cDiretorio+Alltrim(cSequencia)+"*.jpg" )
	
	For X:= 1 to Len(aFiles)
		cAnexos += cDiretorio+aFiles[X,1] + "; "
	Next X
	
	cTo := PLLeGrpMail(cTo)
	cCC := PLLeGrpMail(cCC)
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
	If lOk
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				MSGINFO(OemtoAnsi(STR0027),OemtoAnsi(STR0028)) //"Falha na Autenticação do Usuário"###"Atenção"
				DISCONNECT SMTP SERVER RESULT lOk
				IF !lOk
					GET MAIL ERROR cErrorMsg
					MSGINFO(OemtoAnsi(STR0029)+cErrorMsg,OemtoAnsi(STR0028)) //"Erro na Desconexão: "###"Atenção"
				ENDIF
				Return .F.
			EndIf
		EndIf
		If !Empty(cCC)
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk
		Else
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk
		EndIf
		If !lOk
			GET MAIL ERROR cErrorMsg
			Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
		EndIf
	Else
		GET MAIL ERROR cErrorMsg
		Help("",1,"AVG0001057",,"Error: "+cErrorMsg,2,0)
	EndIf
	DISCONNECT SMTP SERVER RESULT lOk
	IF !lOk
		GET MAIL ERROR cErrorMsg
		MSGINFO(OemtoAnsi(STR0029)+cErrorMsg,OemtoAnsi(STR0028)) //"Erro na Desconexão: "###"Atenção"
	ENDIF
	
	For X:= 1 to Len(aFiles)
		FErase(cDiretorio+aFiles[X,1])
	Next X
	
EndIf
	
Return .T.

/*/{Protheus.doc} PLLeGrpMail
Leitura do grupo de e-mail.
@type function
@author TOTVS
@since 20/10/04
@version 1.0
/*/
Function PLLeGrpMail(cEmail)
	Local  cPart,nAt,cSend:=""
	IF Empty(cEmail)
		Return cEmail
	EndIf
	cEmail := Alltrim(cEmail)
	IF RIGHT(cEmail,1) # ";"
		cEmail += ";"
	ENDIF
	DO While (nAt := AT(";",cEmail)) > 0
		cPart := Subs(cEmail,1,nAT-1)
		If !Empty(cPart)
			If !Empty(cSend)
				cSend += ";"
			EndIf
			If !("@"$cPart)
				cSend += Lower(Alltrim(RetProfDef(cUserName,"AP5WAB","GROUP",cPart)))
			Else
				cSend += Lower(cPart)
			EndIf
		Endif
		cEmail := Subs(cEmail,nAT+1)
	EndDO
RETURN cSend

/*/{Protheus.doc} PLRELRDA
Retorna array com prestadores cadastrados para utilizar determinado equipamento (pos/cpu)
@type function
@author TOTVS
@since 04/11/04
@version 1.0
/*/
Function PLRELRDA(cCodUsr)
LOCAL cRegAte 	:= ""
LOCAL cSql 	  	:= ""
LOCAL aRet    	:= {}
LOCAL aMatEsp 	:= {}
Local aArea   	:= GetArea()
Local dBloqueio	:= FsDateConv(dDataBase,"YYYYMMDD")
Local lCred		:= !(P813VerCRED())

// Indices
BAX->( DbSetOrder(1) ) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
BAQ->( DbSetOrder(1) ) //BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP

// Nome das Tabelas
cBSO := BSO->(RetSQLName("BSO"))
cBAU := BAU->(RetSQLName("BAU"))
cBB8 := BB8->(RetSQLName("BB8"))
cBC1 := BC1->(RetSQLName("BC1"))
cBAX := BAX->(RetSQLName("BAX"))
cBC4 := BC4->(RetSQLName("BC4"))

cSql := " SELECT BC4_DTBLQ, BAU_DATBLO, BC4_DATA, BC4_DTBLQ, BB8_DATBLO,BSO_CODINT,BSO_CODLOC,BSO_CODIGO,BSO_CODLOC, "
cSql += "		 BAU_TIPPRE,BAU_SIGLCR,BAU_CONREG,BAU_ESTCR,BAU_TIPPE,BAU_CODBB0, "
cSql += "		 BAU_CODIGO,BAU_NOME,BAU_TIPPRE,BAU_CPFCGC,"+cBAU+".R_E_C_N_O_ AS RECNOBAU, "
cSql += "        BAU_TISVER, BB8_CNES,BB8_TIPLOG,BB8_NR_END,BB8_COMEND,BB8_CARSOL, "
cSql += "		 BB8_END,BB8_CODMUN,BB8_BAIRRO,BB8_EST,BB8_CODMUN,BB8_CEP,BB8_TEL "

cSql += "  FROM " + cBSO + "," + cBAU + "," + cBB8 + " ," + cBC4 + " BC4 "

cSql += " WHERE BSO_FILIAL = '" + xFilial("BSO") + "' "
cSql += "  	AND BSO_CODUSR = '" + cCodUsr + "' "
cSql += "	AND " + cBSO + ".D_E_L_E_T_ = ' ' "

cSql += "	AND BAU_FILIAL = '" + xFilial("BAU") + "' "
cSql += "	AND BAU_CODIGO = BSO_CODIGO "

cSql += "   AND BC4_FILIAL = '" + xFilial("BC4") + "' "
cSql += "   AND BC4_CODCRE = BAU_CODIGO "
cSql += "	AND BC4.D_E_L_E_T_ = ' ' "

cSql += " AND BC4.R_E_C_N_O_ = ( SELECT MAX(R_E_C_N_O_)  FROM " + cBC4 + "  WHERE BC4_FILIAL = '" + xFilial("BC4") + "' AND BC4_CODCRE = BAU_CODIGO AND BC4_CODCRE = BAU_CODIGO ) "

if lCred
	cSql += " AND (BC4_DTBLQ > '" + dBloqueio + "' AND BC4_TIPO = '0' ) "
EndIf

cSql += "	AND " + cBAU + ".D_E_L_E_T_ = ' ' "

cSql += "	AND BB8_FILIAL = '" + xFilial("BB8") + "' "
cSql += "	AND BB8_CODIGO = BSO_CODIGO "
cSql += "	AND BB8_CODINT = BSO_CODINT "
cSql += "	AND BB8_CODLOC = BSO_CODLOC "
if lCred
	cSql += "	AND (BB8_DATBLO = '' Or '" + dBloqueio + "' < BB8_DATBLO )"
EndIf
cSql += "	AND " + cBB8 + ".D_E_L_E_T_ = ' ' "

PLRELRDAExe(cSql,@aRet)

cSql := ""

// Checa se existe registro de RDA liberadas sem considerar a BC4
cSql := " SELECT BAU_DATBLO, BB8_DATBLO,BSO_CODINT,BSO_CODLOC,BSO_CODIGO,BSO_CODLOC, "
cSql += "		 BAU_TIPPRE,BAU_SIGLCR,BAU_CONREG,BAU_ESTCR,BAU_TIPPE,BAU_CODBB0, "
cSql += "		 BAU_CODIGO,BAU_NOME,BAU_TIPPRE,BAU_CPFCGC,"+cBAU+".R_E_C_N_O_ AS RECNOBAU, "
cSql += "        BAU_TISVER,BB8_CNES,BB8_TIPLOG,BB8_NR_END,BB8_COMEND,BB8_CARSOL, "
cSql += "		 BB8_END,BB8_CODMUN,BB8_BAIRRO,BB8_EST,BB8_CODMUN,BB8_CEP,BB8_TEL "
cSql += "  FROM " + cBSO + "," + cBAU + "," + cBB8
cSql += " WHERE BSO_FILIAL = '" + xFilial("BSO") + "' "
cSql += "  	AND BSO_CODUSR = '" + cCodUsr + "' "
cSql += "	AND "+cBSO+".D_E_L_E_T_ = ' ' "

cSql += "	AND BAU_FILIAL = '"+xFilial("BAU")+"' "
cSql += "	AND BAU_CODIGO = BSO_CODIGO "
if lCred
	cSql += " AND (BAU_CODBLO = ' ' Or ('"+ dBloqueio +"' < BAU_DATBLO OR BAU_DATBLO = ' ' )) "
EndIf

cSql += "	AND "+cBAU+".D_E_L_E_T_ = ' ' "

cSql += "	AND BB8_FILIAL = '"+xFilial("BB8")+"' "
cSql += "	AND BB8_CODIGO = BSO_CODIGO "
cSql += "	AND BB8_CODINT = BSO_CODINT "
cSql += "	AND BB8_CODLOC = BSO_CODLOC "
if lCred
	cSql += "	AND (BB8_DATBLO = '' Or '" + dBloqueio + "' < BB8_DATBLO )"
EndIf
cSql += "	AND "+cBB8+".D_E_L_E_T_ = ' ' "

PLRELRDAExe(cSql,@aRet)

Return(aRet)

/*/{Protheus.doc} PLRELCOS
Retorna array com contrato subcontrato para usuario web
@type function
@author TOTVS
@since 04/02/12
@version 1.0
/*/
Function PLRELCOS(cCodUsr)
LOCAL cSql 	  	:= ""
LOCAL aRetOpe   := {}
LOCAL aRetEmp   := {}
LOCAL aRetCon   := {}
LOCAL aRetSub   := {}
LOCAL aRetBen   := {}
LOCAL aArea   	:= GetArea()
LOCAL dBloqueio	:= FsDateConv(dDataBase,"YYYYMMDD")

// Indices
B40->( DbSetOrder(1) ) //B40_FILIAL + B40_CODUSR + B40_CODEMP + B40_NUMCON + B40_VERCON + B40_SUBCON + B40_VERSUB + B40_CODINT

// Nome das Tabelas
cB40 := B40->(RetSQLName("B40"))
cBA0 := BA0->(RetSQLName("BA0"))
cBG9 := BG9->(RetSQLName("BG9"))
cBT5 := BT5->(RetSQLName("BT5"))
cBQC := BQC->(RetSQLName("BQC"))

cSql := " SELECT B40_CODUSR,B40_CODINT,B40_CODEMP,B40_NUMCON,B40_VERCON,B40_SUBCON,B40_VERSUB, "
cSql += "		 BA0_NOMINT, "
cSql += "		 BG9_DESCRI, "
cSql += "		 BT5_CODIGO,BT5_NUMCON,BT5_VERSAO,BT5_NOME,BT5_DATCON,BT5_TIPCON, "
cSql += "		 BQC_SUBCON,BQC_VERSUB,BQC_DESCRI,BQC_VALID "
cSql += "  FROM " + cB40 + "," + cBA0 + "," + cBG9 + "," + cBT5 + "," + cBQC

cSql += " WHERE B40_FILIAL = '" + xFilial("B40") + "' "
cSql += "  	AND B40_CODUSR = '" + cCodUsr + "' "
cSql += "	AND " + cB40 + ".D_E_L_E_T_ = ' ' "

// Operadora
cSql += "	AND BA0_FILIAL = '" + xFilial("BA0") + "' "
cSql += "	AND BA0_CODIDE||BA0_CODINT = B40_CODINT "
cSql += "	AND " + cBA0 + ".D_E_L_E_T_ = ' ' "

// Empresa
cSql += "	AND BG9_FILIAL = '" + xFilial("BG9") + "' "
cSql += "	AND BG9_CODINT = B40_CODINT "
cSql += "	AND BG9_CODIGO = B40_CODEMP "
cSql += "	AND " + cBG9 + ".D_E_L_E_T_ = ' ' "

// Contrato
cSql += "	AND BT5_FILIAL = '" + xFilial("BT5") + "' "
cSql += "	AND BT5_CODINT = B40_CODINT "
cSql += "	AND BT5_CODIGO = B40_CODEMP "
cSql += "	AND BT5_NUMCON = B40_NUMCON "
cSql += "	AND BT5_VERSAO = B40_VERCON "
cSql += "	AND " + cBT5 + ".D_E_L_E_T_ = ' ' "

// SubContrato
cSql += "	AND BQC_FILIAL = '" + xFilial("BQC") + "' "
cSql += "	AND BQC_CODIGO = BT5_CODINT||BT5_CODIGO "
cSql += "	AND BQC_NUMCON = BT5_NUMCON "
cSql += "	AND BQC_VERCON = BT5_VERSAO "
cSql += "	AND (BQC_CODBLO = '' OR '" + dBloqueio + "' < BQC_DATBLO )"

cSql += "   AND (B40_SUBCON = '" + Space( TamSx3("B40_SUBCON")[1] ) + "' OR ( B40_SUBCON <> '" + Space( TamSx3("B40_SUBCON")[1] ) + "' AND B40_SUBCON = BQC_SUBCON AND B40_VERSUB = BQC_VERSUB )) "
cSql += "	AND " + cBQC + ".D_E_L_E_T_ = ' ' "

cSql += "	ORDER BY B40_CODINT,B40_CODEMP,B40_NUMCON,B40_VERCON,B40_SUBCON,B40_VERSUB "

// Execute
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSql)),"TRBBE",.F.,.T.)

// Monta matriz de retorno
While !TRBBE->( eof() )

	// Somente registros validos operadora, empresa, contrato, subcontrato ou todos
	If B40->( MsSeek( xFilial("B40") + TRBBE->(B40_CODUSR + B40_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO + B40_SUBCON + B40_VERSUB) ) )

		// Matriz Operadora
		If Len(aRetOpe) == 0 .or. ascan( aRetOpe, {|x| x[2] == TRBBE->B40_CODINT } ) == 0
			
			aRetEmp := {}
			aRetCon := {}
			aRetSub := {}
			AaDd(aRetOpe,{	{}, TRBBE->B40_CODINT, TRBBE->BA0_NOMINT } )
		EndIf
		
		// Matriz Empresa
		If Len(aRetEmp) == 0 .or. ascan( aRetEmp, {|x| x[2] == TRBBE->(B40_CODINT+B40_CODEMP) } ) == 0
			
			aRetCon := {}
			aRetSub := {}
			AaDd(aRetEmp,{	{}, TRBBE->(B40_CODINT+B40_CODEMP), TRBBE->BG9_DESCRI })
		EndIf
		
		// Matriz Contrato
		If Len(aRetCon) == 0 .or. ascan( aRetCon, {|x| x[2] == TRBBE->(B40_CODINT+B40_CODEMP+BT5_NUMCON+BT5_VERSAO) } ) == 0
			
			aRetSub := {}
			AaDd(aRetCon,{	{}, TRBBE->(B40_CODINT+B40_CODEMP+BT5_NUMCON+BT5_VERSAO),;		
								TRBBE->B40_CODINT+"."+TRBBE->B40_CODEMP+" ( "+TRBBE->BT5_NUMCON+"-"+TRBBE->BT5_VERSAO+" )",; 					//Para montagem do combo no portal
								TRBBE->BT5_TIPCON,;
								TRBBE->BT5_NUMCON,;
								TRBBE->BT5_VERSAO,;
								AllTrim(TRBBE->BT5_NOME),;
								CtoD(TRBBE->BT5_DATCON) })
			
		EndIf
		
		// Matriz SubContrato
		If Len(aRetSub) == 0 .or. ascan( aRetSub, {|x| x[2] == TRBBE->(B40_CODINT+B40_CODEMP+BT5_NUMCON+BT5_VERSAO+BQC_SUBCON+BQC_VERSUB) } ) == 0
			
			// Familia implementacao futura
			AaDd(aRetSub,{	{}, TRBBE->(B40_CODINT+B40_CODEMP+BT5_NUMCON+BT5_VERSAO+BQC_SUBCON+BQC_VERSUB),;			//Para montagem do combo no portal
								TRBBE->B40_CODINT+"."+TRBBE->B40_CODEMP+"."+TRBBE->BT5_NUMCON+"-"+TRBBE->BT5_VERSAO+" ( "+TRBBE->BQC_SUBCON+"-"+TRBBE->BQC_VERSUB+" ) ",; //Para montagem do combo no portal
								TRBBE->BQC_SUBCON,;
								TRBBE->BQC_VERSUB,;
								allTrim(TRBBE->BQC_DESCRI),;
								ctod(TRBBE->BQC_VALID) })
		EndIf
		
		// Amarra subcontrato, contrato e empresa a operadora
		aRetCon[Len(aRetCon),1] := aClone(aRetSub)
		aRetEmp[Len(aRetEmp),1] := aClone(aRetCon)
		aRetOpe[Len(aRetOpe),1] := aClone(aRetEmp)
		
	EndIf
	
TRBBE->( DbSkip() )
EndDo

TRBBE->( DbCloseArea() )

RestArea(aArea)

Return(aRetOpe)

/*/{Protheus.doc} PLRELBEN
Retorna array com beneficiario para usuario web
@type function
@author TOTVS
@since 04/02/12
@version 1.0
/*/
Function PLRELBEN(cCodUsr)
	LOCAL cSql 	  	:= ""
	LOCAL cCodPla 	:= ""
	LOCAL cVerPla 	:= ""
	LOCAL cDesPla 	:= ""
	LOCAL aRetOpe   := {}
	LOCAL aRetEmp   := {}
	LOCAL aRetCon   := {}
	LOCAL aRetSub   := {}
	LOCAL aRetBen   := {}
	LOCAL aArea   	:= GetArea()
	LOCAL dBloqueio	:= FsDateConv(dDataBase,"YYYYMMDD")
	LOCAL lJuridico := .T.
	// Nome das Tabelas
	cB49 := B49->(RetSQLName("B49"))
	cBA1 := BA1->(RetSQLName("BA1"))
	cBA3 := BA1->(RetSQLName("BA3"))
	cBA0 := BA0->(RetSQLName("BA0"))
	cBG9 := BG9->(RetSQLName("BG9"))
	cBT5 := BT5->(RetSQLName("BT5"))
	cBQC := BQC->(RetSQLName("BQC"))
	// Verifica se e pessoa fisica ou juridica
	BA1->( DbSetOrder(2) ) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	B49->( DbSetOrder(1) ) //B49_FILIAL + B49_CODUSR + B49_BENEFI
	
	If B49->( MsSeek( xFilial("B49") + cCodUsr) )
		lJuridico := BA1->( MsSeek( xFilial("BA1") + B49->B49_BENEFI ) ) .And. !Empty(BA1->BA1_CONEMP)
	EndIf
	// Query
	cSql := " SELECT B49_CODUSR,B49_BENEFI, "
	cSql += "		 BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB, "
	cSql += "		 BA1_NOMUSR,BA1_DATNAS,BA1_SEXO,BA1_TIPUSU,BA1_ESTCIV,BA1_GRAUPA,BA1_DATINC, "
	cSql += "		 BA1_CODPLA,BA1_VERSAO,BA1_DATCAR, "
	if BA1->(FieldPos("BA1_RESFAM")) > 0
		cSql += "	BA1_RESFAM AS RESFAM, "
	else
		cSql += "	'0' AS RESFAM, "
	endif
	cSql += "		 BA3_CODPLA,BA3_VERSAO, "
	cSql += "		 BA0_NOMINT, "
	cSql += "		 BG9_DESCRI, "
	
	If lJuridico
		cSql += "		 BT5_NOME,BT5_DATCON,BT5_TIPCON, "
		cSql += "		 BQC_DESCRI,BQC_VALID "
	Else
		cSql += "		 '' AS BT5_NOME,'' AS BT5_DATCON,'' AS BT5_TIPCON, "
		cSql += "		 '' AS BQC_DESCRI,'' AS BQC_VALID "
	EndIf
	
	cSql += "  FROM "+cB49+","+cBA1+","+cBA3+","+cBA0+","+cBG9
	
	If lJuridico
		cSql += ","+cBT5+","+cBQC
	EndIf
	
	cSql += " WHERE B49_FILIAL = '"+xFilial("B49")+"' "
	cSql += "  	AND	B49_CODUSR = '"+cCodUsr+"' "
	cSql += "	AND "+cB49+".D_E_L_E_T_ = ' ' "
	// Beneficiario
	cSql += "	AND BA1_FILIAL = B49_FILIAL "
	cSql += "	AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = B49_BENEFI "
	cSql += "	AND (BA1_DATBLO = ' ' OR BA1_MOTBLO = ' ' OR '" + dBloqueio + "' < BA1_DATBLO )"
	cSql += "	AND "+cBA1+".D_E_L_E_T_ = ' ' "
	// Familia
	cSql += "	AND BA3_FILIAL = BA1_FILIAL "
	cSql += "	AND BA3_CODINT = BA1_CODINT "
	cSql += "	AND BA3_CODEMP = BA1_CODEMP "
	cSql += "	AND BA3_MATRIC = BA1_MATRIC "
	cSql += "	AND (BA3_DATBLO = ' ' OR BA3_MOTBLO = ' ' OR '" + dBloqueio + "' < BA3_DATBLO )"
	cSql += "	AND "+cBA3+".D_E_L_E_T_ = ' ' "
	// Operadora
	cSql += "	AND BA0_FILIAL = BA1_FILIAL "
	cSql += "	AND BA0_CODIDE||BA0_CODINT = BA1_CODINT "
	cSql += "	AND "+cBA0+".D_E_L_E_T_ = ' ' "
	// Empresa
	cSql += "	AND BG9_FILIAL = BA1_FILIAL "
	cSql += "	AND BG9_CODINT = BA1_CODINT "
	cSql += "	AND BG9_CODIGO = BA1_CODEMP "
	cSql += "	AND "+cBG9+".D_E_L_E_T_ = ' ' "
	// Verifica se e fisica ou juridica
	If lJuridico
		// Contrato
		cSql += "	AND BT5_FILIAL = BA1_FILIAL "
		cSql += "	AND BT5_CODINT = BA1_CODINT "
		cSql += "	AND BT5_CODIGO = BA1_CODEMP "
		cSql += "	AND BT5_NUMCON = BA1_CONEMP "
		cSql += "	AND BT5_VERSAO = BA1_VERCON "
		cSql += "	AND "+cBT5+".D_E_L_E_T_ = ' ' "
		// SubContrato
		cSql += "	AND BQC_CODIGO = BA1_CODINT||BA1_CODEMP "
		cSql += "	AND BQC_NUMCON = BA1_CONEMP "
		cSql += "	AND BQC_VERCON = BA1_VERCON "
		cSql += "	AND BQC_SUBCON = BA1_SUBCON "
		cSql += "	AND BQC_VERSUB = BA1_VERSUB "
		cSql += "	AND (BQC_CODBLO = '' Or '" + dBloqueio + "' < BQC_DATBLO )"
		cSql += "	AND "+cBQC+".D_E_L_E_T_ = ' ' "
	EndIf
	// Order
	cSql += " ORDER BY B49_BENEFI "
	// Execute
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBE",.F.,.T.)
	// Monta matriz de retorno
	While !TRBBE->( Eof() )
		// Matriz Operadora
		If Len(aRetOpe)==0 .Or. Ascan( aRetOpe, {|x| x[2] == TRBBE->BA1_CODINT } ) == 0
			
			aRetEmp := {}
			aRetCon := {}
			aRetSub := {}
			AaDd(aRetOpe,{	{},;
				TRBBE->BA1_CODINT,;
				TRBBE->BA0_NOMINT } )
		EndIf
		// Matriz Empresa
		If Len(aRetEmp)==0 .Or. Ascan( aRetEmp, {|x| x[2] == TRBBE->(BA1_CODINT+BA1_CODEMP) } ) == 0
			
			aRetCon := {}
			aRetSub := {}
			AaDd(aRetEmp,{	{},;
				TRBBE->(BA1_CODINT+BA1_CODEMP),;
				TRBBE->BG9_DESCRI })
		EndIf
		// Matriz Contrato
		If Len(aRetCon)==0 .Or. Ascan( aRetCon, {|x| x[2] == TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON) } ) == 0
			
			aRetSub := {}
			AaDd(aRetCon,{	{},;
				TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON),;		//Para montagem do combo no portal
			TRBBE->BA1_CODINT+"."+TRBBE->BA1_CODEMP+" ( "+TRBBE->BA1_CONEMP+"-"+TRBBE->BA1_VERCON+" )",; 					//Para montagem do combo no portal
			TRBBE->BT5_TIPCON,;
				TRBBE->BA1_CONEMP,;
				TRBBE->BA1_VERCON,;
				AllTrim(TRBBE->BT5_NOME),;
				CtoD(TRBBE->BT5_DATCON) })
			
		EndIf
		// Matriz SubContrato
		If Len(aRetSub)==0 .Or. Ascan( aRetSub, {|x| x[2] == TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) } ) == 0
			
			AaDd(aRetSub,{	{},;
				TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),;			//Para montagem do combo no portal
			TRBBE->BA1_CODINT+"."+TRBBE->BA1_CODEMP+"."+TRBBE->BA1_CONEMP+"-"+TRBBE->BA1_VERCON+" ( "+TRBBE->BA1_SUBCON+"-"+TRBBE->BA1_VERSUB+" ) ",; //Para montagem do combo no portal
			TRBBE->BA1_SUBCON,;
				TRBBE->BA1_VERSUB,;
				AllTrim(TRBBE->BQC_DESCRI),;
				CtoD(TRBBE->BQC_VALID) })
		EndIf
		// Matriz Familia
		If Len(aRetBen)==0 .Or. Ascan( aRetBen, {|x| x[2] == TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) } ) == 0
			// Se pega da familia ou do usuario
			cCodPla := Iif(Empty(TRBBE->BA3_CODPLA),TRBBE->BA1_CODPLA,TRBBE->BA3_CODPLA)
			cVerPla := Iif(Empty(TRBBE->BA3_VERSAO),TRBBE->BA1_VERSAO,TRBBE->BA3_VERSAO)
			cDesPla := AllTrim( Posicione("BI3",1,xFilial("BI3")+TRBBE->(BA1_CODINT) + cCodPla + cVerPla,"BI3_DESCRI") )
			// Matriz de Familia
			AaDd(aRetBen,{	TRBBE->B49_BENEFI,;							//01
							AllTrim(TRBBE->BA1_NOMUSR),;				//02
							TRBBE->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),;//03
							CtoD(TRBBE->BA1_DATNAS),;					//04
							cValToChar(DateDiffYear(dDataBase,BA1->BA1_DATNAS)),;//05
							TRBBE->BA1_SEXO,;							//06
							TRBBE->BA1_TIPUSU,;							//07
							AllTrim(Posicione("BIH",1,xFilial("BIH")+TRBBE->BA1_TIPUSU,"BIH_DESCRI")),;//08
							TRBBE->BA1_ESTCIV,;							//09
							TRBBE->BA1_GRAUPA,;							//10
							CtoD(TRBBE->BA1_DATINC),;					//11
							cCodPla,;									//12
							cDesPla,;									//13
							cVerPla,;									//14
							CtoD(TRBBE->BA1_DATCAR),;					//15
							TRBBE->RESFAM })						//16
		EndIf
		// Amarra Familia, subcontrato, contrato e empresa a operadora
		aRetSub[Len(aRetSub),1] := aClone(aRetBen)
		aRetCon[Len(aRetCon),1] := aClone(aRetSub)
		aRetEmp[Len(aRetEmp),1] := aClone(aRetCon)
		aRetOpe[Len(aRetOpe),1] := aClone(aRetEmp)
		
		TRBBE->( DbSkip() )
	EndDo
	// Fechamento da area de trabalho
	TRBBE->( DbCloseArea() )
	// Retorna area corrente
	RestArea(aArea)
Return(aRetOpe)

/*/{Protheus.doc} PLPROFSAUD
Retorna array com profissionais de saude
@type function
@author TOTVS
@since 01/03/07
@version 1.0
/*/
Function PLPROFSAUD(cCodRda,cCodLoc,cBusca,cTipoBusca,nTp, cTipGui)
LOCAL nII		:= 0
LOCAL aRet      := {}
LOCAL cSQL      := ""
LOCAL cNameBC1  := BC1->(RetSQLName("BC1"))
LOCAL cNameBB0  := BB0->(RetSQLName("BB0"))
LOCAL cOldAlias := Alias()

local aAreaBAU	:= {}
local aAreaBB0	:= {}

LOCAL cCodProf  := ""
LOCAL cTipoRda  := ""
LOCAL lFiltPRFS := GetNewPar("MV_PLSPRFS",.T.)// .T. filtra solicitantes - .F.  lista todos
LOCAL nQtdProf  := GetNewPar("MV_PLSQTPF",50)
LOCAL lLsEspBAQ := GetNewPar("MV_PLSESPP",.T.) //Lista as especialidades da BAX com DESC da BAQ
LOCAL aEspeci   := {}
LOCAL nPos		:= 0
LOCAL cIntPad 	:= PLSINTPAD()
Local cSQL1		:= ""
Local cSQL2     := ""
Local aAreaBAX := BAX->(GetArea())
Local aAreaBAQ := BAQ->(GetArea())

DEFAULT cCodLoc 	:= ""
DEFAULT cCodRda 	:= ""
DEFAULT cBusca		:= ""
DEFAULT cTipoBusca 	:= "1"
DEFAULT nTp			:= 1 //Determina se irá validar o parametro MV_PLSPRFS ou o MV_PLSPRFX : 1 - Solicitante 2 - Executante
DEFAULT cTipGui 	:= ""

If BAU->BAU_CODIGO <> cCodRda
	
	aAreaBAU := BAU->(getArea())
	
	BAU->(DbSetOrder(1))
	if BAU->(DbSeek(xFilial("BAU")+cCodRda))
		cTipoRda := BAU->BAU_TIPPE
		cCodProf := BAU->BAU_CODBB0
	endIf
	
	BAU->(restArea(aAreaBAU))
	
Else
	cTipoRda := BAU->BAU_TIPPE
	cCodProf := BAU->BAU_CODBB0
Endif

//para guia de SADT posso selecionar outros profissionais mesmo que seja PF
If cTipoRda == "J"  .or. cTipGui == "2"
	
	// Pega os profissionais de saude que nao estao bloqueados
	//Verifica se os dois parâmetros de filtro de profissionais estão ativos, se pelo menos 1 deles estiver .F., carrega todos os profissionais na session PROSAUD.
	lFiltPRFS := IIf((nTp == 2 .AND. GetNewPar("MV_PLSPRFX",.T.)), .T., IIf(nTp == 1 .AND. GetNewPar("MV_PLSPRFS",.T.), .T., .F.))
	
	// Não faz sentido filtrar corpo clinico para RDA pessoa F
	If lFiltPRFS .and. cTipoRda == "J"
		
		cSQL := " SELECT DISTINCT BB0_FILIAL,BB0_NOME NOME,BB0_CGC CGC,BB0_CODOPE CODOPE,BC1_CODPRF CODPRF,BC1_SIGLCR SIGLCR,BC1_NUMCR NUMCR ,BC1_ESTCR ESTCR"
		cSQL += "   FROM " + cNameBB0 + "," + cNameBC1
		cSQL += "  WHERE BC1_FILIAL = '" + xFilial("BC1") + "' "
		cSQL += "    AND BC1_CODIGO = '" + cCodRda + "' "
		cSQL += "    AND BC1_CODINT = '" + cIntPad + "' "
		
		If ! empty(cCodLoc)
			cSQL += " AND BC1_CODLOC = '" + cCodLoc + "' "
		EndIf
		
		cSQL += " AND BB0_FILIAL = '" + xFilial("BB0") + "' "
		cSQL += " AND BB0_CODIGO = BC1_CODPRF "
		cSQL += " AND (BC1_DATBLO = ''  OR BC1_DATBLO > '" + dtos(dDataBase) + "' ) "
		cSQL += " AND " + cNameBB0 + ".D_E_L_E_T_ = ' ' "
		cSQL += " AND " + cNameBC1 + ".D_E_L_E_T_ = ' ' "
		
		If ExistBlock("PLFILBC1")
			cSQl += ExecBlock("PLFILBC1",.F.,.F.)
		EndIf
		
		If ! Empty(cBusca)
			
			If cTipoBusca == "1"
				cSQL += " AND BB0_NOME LIKE '" + Upper(cBusca) + "%' "
			elseif cTipoBusca == "2"
				cSQL += " AND BB0_CODIGO = '" + AllTrim(cBusca) + "' "
			endif
			
		EndIf
		
		cSQL += " ORDER BY BB0_NOME "
		
	else
		
		cSQL := " SELECT DISTINCT BB0_FILIAL,BB0_NOME NOME,BB0_CGC CGC,BB0_CODOPE CODOPE,BB0_CODIGO CODPRF,BB0_CODSIG SIGLCR ,BB0_NUMCR NUMCR,BB0_ESTADO ESTCR "
		cSQL += "   FROM " + retSqlName("BB0") + "  "
		cSQL += "  WHERE BB0_FILIAL = '" + xFilial("BB0") + "' "
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		
		If ! Empty(cBusca)
			
			If cTipoBusca == "1"
				cSQL += " AND BB0_NOME LIKE '" + Upper(cBusca) + "%' "
			elseif cTipoBusca == "2"
				cSQL += " AND BB0_CODIGO = '" + AllTrim(cBusca) + "' "
			endif
			
		EndIf
		
		cSQL += " ORDER BY BB0_NOME "
		
	endIf
	
	// Verifica se tem query a ser executada
	If ! empty(cSQL)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),"TrbBC1Prof",.T.,.F.)
		
		BQ1->(DbSetORder(1))
		
		While ! TrbBC1Prof->(Eof())
			
			// Checa se esta bloqueado
			If A090CHEBLO(TrbBC1Prof->CODPRF,dDataBase,.F.)  .And. ! Empty(TrbBC1Prof->CODPRF)
				
				nII++
				// Controla a quantidade de registro que deve ser retornado
				If nQtdProf > 0 .And. nII > nQtdProf
					Exit
				EndIf
				
				aEspeci := {}
				
				//Utiliza a mesma consulta ao banco caso atenda as duas condições.
				If BQ1->(MsSeek(xFilial("BQ1")+TrbBC1Prof->CODPRF)) .And. lLsEspBAQ
					
					cSQL1 := "SELECT BAQ_CODESP, BAQ_DESCBO "
					cSQL1 += "  FROM " + retSqlName("BQ1")
					
					cSQL1 += " INNER JOIN " + retSqlName("BAQ")
					cSQL1 += "         ON BAQ_FILIAL = '" + xFilial("BAQ")  + "' "
					cSQL1 += "        AND BAQ_CODINT = BQ1_CODINT "
					cSQL1 += "        AND BAQ_CODESP = BQ1_CODESP "
					cSQL1 += "        AND " + retSqlName("BAQ") + ".D_E_L_E_T_ = ' ' "
					
					cSQL1 += " WHERE BQ1_FILIAL = '" + xFilial("BQ1")  + "' "
					cSQL1 += "   AND BQ1_CODIGO = '" + TrbBC1Prof->CODPRF + "' "
					cSQL1 += "   AND " + retSqlName("BQ1") + ".D_E_L_E_T_ = ' ' "
					
					If !lFiltPRFS
						
						BAX->(DbSetOrder(1)) //BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODSUB
						If BAX->( MsSeek( xFilial("BAX")+ cCodRda + cIntPad + cCodLoc ) )
							
							cSQL1 += "UNION ALL "
							
							cSQL1 += "SELECT BAQ_CODESP, BAQ_DESCBO "
							cSQL1 += "  FROM " + retSqlName("BAX")
							
							cSQL1 += " INNER JOIN " + RetSqlName("BAQ")
							cSQL1 += "         ON BAQ_FILIAL = '" + xFilial("BAQ")  + "' "
							cSQL1 += "        AND BAQ_CODINT = BAX_CODINT "
							cSQL1 += "        AND BAQ_CODESP = BAX_CODESP "
							cSQL1 += "        AND " + retSqlName("BAQ") + ".D_E_L_E_T_ = ' ' "
							
							cSQL1 += "      WHERE BAX_FILIAL = '" + xFilial("BAX")  + "' "
							cSQL1 += "        AND BAX_CODIGO = '" + cCodRda + "' "
							cSQL1 += "        AND BAX_CODINT = '" + cIntPad + "' "
							cSQL1 += "        AND BAX_CODLOC = '" + cCodLoc + "' "
							cSQL1 += "        AND ( BAX_DATBLO > '" + dtos(dDataBase) + "' OR  BAX_DATBLO = '' ) "
							cSQL1 += "        AND " + retSqlName("BAX") + ".D_E_L_E_T_ = ' ' "
							
							cSQL1 += " ORDER BY BAQ_DESCBO "
							
						EndIf
						
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSQL1)),"TrbBQ1",.T.,.F.)
					
					While !TrbBQ1->(Eof())
						
						nPos := AScan(aEspeci, {|x|AllTrim(x[2]) == AllTrim(TrbBQ1->BAQ_DESCBO)})
						
						If nPos == 0
							aadd(aEspeci,{TrbBQ1->BAQ_CODESP,TrbBQ1->BAQ_DESCBO})
						EndIf
						
						TrbBQ1->(DbSkip())
					EndDo
					
					TrbBQ1->(DbCloseArea())
					
				Else
					
					If lFiltPRFS .And. lLsEspBAQ
						
						If BAX->( MsSeek( xFilial("BAX")+ cCodRda + cIntPad+ cCodLoc ) )
							
							cSQL2 := "SELECT BAQ_CODESP, BAQ_DESCBO "
							cSQL2 += "  FROM " + retSqlName("BAX")
							
							cSQL2 += "  INNER JOIN " + retSqlName("BAQ")
							cSQL2 += "          ON BAQ_FILIAL = '" + xFilial("BAQ")  + "' "
							cSQL2 += "         AND BAQ_CODINT = BAX_CODINT "
							cSQL2 += "         AND BAQ_CODESP = BAX_CODESP "
							cSQL2 += "         AND " + retSqlName("BAQ") + ".D_E_L_E_T_ = ' ' "
							
							cSQL2 += "       WHERE BAX_FILIAL = '" + xFilial("BAX")  + "' "
							cSQL2 += "         AND BAX_CODIGO = '" + cCodRda + "' "
							cSQL2 += "         AND BAX_CODINT = '" + cIntPad + "' "
							cSQL2 += "         AND BAX_CODLOC = '" + cCodLoc + "' "
							cSQL2 += "         AND (BAX_DATBLO > '" + dtos(dDataBase) + "' OR  BAX_DATBLO = '') "
							cSQL2 += "         AND " + retSqlName("BAX") + ".D_E_L_E_T_ = ' ' "
							
							cSQL2 += " ORDER BY BAQ_DESCBO "
							
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSQL2)),"TrbBAX",.T.,.F.)
							
							While !TrbBAX->(Eof())
								
								nPos := AScan(aEspeci, {|x|AllTrim(x[2]) == AllTrim(TrbBAX->BAQ_DESCBO)})
								
								If nPos == 0
									AaDd( aEspeci,{TrbBAX->BAQ_CODESP,TrbBAX->BAQ_DESCBO} )
								EndIf
								
							TrbBAX->(DbSkip())
							EndDo
							
							TrbBAX->(DbCloseArea())
						Endif
						
					Else
						
						BAX->( DbSetOrder(1) ) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
						BAQ->( DbSetOrder(1) ) //BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
						
						If BAX->( MsSeek( xFilial("BAX")+ cCodRda + cIntPad+ cCodLoc ) )
							
							If BAQ->( MsSeek( xFilial("BAQ")+BAX->BAX_CODINT) ) .And. (Empty(BAX->BAX_DATBLO) .Or. dDataBase < BAX->BAX_DATBLO)
								
								While ! BAQ->( Eof() )
									
									If ! Empty(BAQ->BAQ_CBOS)
										
										nPos := AScan( aEspeci, {|x|AllTrim(x[2]) == AllTrim(BAQ->BAQ_DESCBO)})
										
										If nPos == 0
											AaDd(aEspeci,{BAQ->BAQ_CODESP,BAQ->BAQ_DESCBO})
											
										EndIf
									EndIf
									
								BAQ->( DbSkip() )
								EndDo
								
							EndIf
							
						EndIf
						
					EndIf
					
				EndIf
				
				// Monta array de retorno
				AaDd( aRet,{ 	TrbBC1Prof->CODPRF,;
								TrbBC1Prof->NOME,;
								TrbBC1Prof->SIGLCR,;
								TrbBC1Prof->NUMCR,;
								TrbBC1Prof->ESTCR,;
								TrbBC1Prof->CGC,;
								TrbBC1Prof->CODOPE,;
								BAU->BAU_CODIGO,;
								BAU->BAU_NREDUZ,;
								BAU->BAU_CPFCGC,;
								BAU->BAU_CNES,;
								aEspeci} )
			EndIf
			
			TrbBC1Prof->( DbSkip() )
		EndDo
		
		TrbBC1Prof->( DbCloseArea() )
	EndIf
	
Else
	
	If cCodProf <> BB0->BB0_CODIGO .OR. BB0->BB0_FILIAL <> xFilial("BB0")
		
		aAreaBB0 := BB0->(getArea())
		
		BB0->( DbSetOrder(1) )
		if ! BB0->( DbSeek(xFilial("BB0") + cCodProf) )
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0050 + cCodProf + STR0051+cCodRda , 0, 0, {})//"Prof. de Saude não encontrado ->"###" Rda -> "
		EndIf
		
	Endif
	
	aEspeci := {}
	
	If ! lLsEspBAQ
		
		BAQ->( DbSetOrder(1) )
		If BAQ->( MsSeek( xFilial("BAQ")+cIntPad) )
			
			While !BAQ->( Eof() )
				
				If ! Empty(BAQ->BAQ_CBOS)
					
					nPos := AScan( aEspeci, {|x|AllTrim(x[2]) == AllTrim(BAQ->BAQ_DESCBO)})
					
					If nPos == 0
						AaDd(aEspeci,{BAQ->BAQ_CODESP,BAQ->BAQ_DESCBO})
					EndIf
					
				EndIf
				
			BAQ->( DbSkip() )
			EndDo
			
		EndIf
		
	Else
		
		// Conforme parametro MV_PLSESPP ativado o sistema devera seguir as tabelas abaixo para carregar as especialidades.
		
		BAX->( DbSetOrder(1) ) //BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
		BAQ->( DbSetOrder(1) ) //BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
		BQ1->( DbSetORder(1) )

		if  BB0->( DbSeek(xFilial("BB0") + cCodProf) )
							
			If BAX->( MsSeek( xFilial("BAX")+ cCodRda + cIntPad+ cCodLoc ) )
			
				If BAQ->( MsSeek( xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP) ) ) .And. (Empty(BAX->BAX_DATBLO) .Or. dDataBase < BAX->BAX_DATBLO)
					If ! Empty(BAQ->BAQ_CBOS)
											
						nPos := AScan( aEspeci, {|x|AllTrim(x[2]) == AllTrim(BAQ->BAQ_DESCBO)})
											
						If nPos == 0
							AaDd(aEspeci,{BAQ->BAQ_CODESP,BAQ->BAQ_DESCBO})
						EndIf
					EndIf
									
				EndIf
								
			EndIf
		Endif
		
	EndIf
	
	AaDd( aRet,{ 	BB0->BB0_CODIGO,;
					BB0->BB0_NOME,;
					BB0->BB0_CODSIG,;
					BB0->BB0_NUMCR,;
					BB0->BB0_ESTADO,;
					BB0->BB0_CGC,;
					BB0->BB0_CODOPE,;
					BAU->BAU_CODIGO,;
					BAU->BAU_NREDUZ,;
					BAU->BAU_CPFCGC,;
					BAU->BAU_CNES,;
					aEspeci} )
	BB0->(restArea(aAreaBB0))
	
Endif

RestArea(aAreaBAX)
RestArea(aAreaBAQ)

Return(aRet)

/*/{Protheus.doc} PROFALL
Retorna array com profissionais de saude
@type function
@author TOTVS
@since 30/07/13
@version 1.0
/*/
Function PROFALL(cBusca)
LOCAL nII		:= 0
LOCAL aRet      := {}
LOCAL cSQL      := ""
LOCAL cOldAlias := Alias()
LOCAL nOrdBAU   := BAU->(IndexOrd())
LOCAL nRecBAU   := BAU->(Recno())
LOCAL nOrdBB0   := BB0->(IndexOrd())
LOCAL nRecBB0   := BB0->(Recno())
LOCAL cCodProf  := ""
LOCAL cTipoRda  := ""
LOCAL nQtdProf  := GetNewPar("MV_PLSQTPF",50)
LOCAL aEspeci   := {}
DEFAULT cBusca	:= ""


cSQL := " SELECT DISTINCT BB0_FILIAL,BB0_NOME NOME,BB0_CGC CGC,BB0_CODOPE CODOPE,BB0_CODIGO CODPRF,BB0_CODSIG SIGLCR ,BB0_NUMCR NUMCR,BB0_ESTADO ESTCR "
cSQL += " FROM "+RetSqlName("BB0")+"  "
cSQL += " WHERE BB0_FILIAL = '"+xFilial("BB0")+"' "
cSQL += " AND D_E_L_E_T_ = ' ' "

If !Empty(cBusca)
	cSQL += " AND BB0_NOME LIKE '" + Upper(cBusca) + "%' "
EndIf
cSQL += " ORDER BY BB0_FILIAL, BB0_NOME "
// Verifica se tem query a ser executada
If !Empty(cSQL)
	
	PLSQuery(cSQL,"TrbBC1Prof")
	
	While ! TrbBC1Prof->(Eof())
		// Checa se esta bloqueado
		If A090CHEBLO(TrbBC1Prof->CODPRF,dDataBase,.F.)  .And. !Empty(TrbBC1Prof->CODPRF)
			
			nII++
			// Controla a quantidade de registro que deve ser retornado
			If nQtdProf > 0 .And. nII > nQtdProf
				Exit
			EndIf
			
			aEspeci := {}
			BQ1->(DbSetORder(1))
			If BQ1->(MsSeek(xFilial("BQ1")+TrbBC1Prof->CODPRF))
				While !BQ1->(Eof()) .and. alltrim(xFilial("BQ1")+TrbBC1Prof->CODPRF) == alltrim(BQ1->(BQ1_FILIAL+BQ1_CODIGO))
					aadd(aEspeci,{BQ1->BQ1_CODESP,BQ1->BQ1_DESCRI})
					BQ1->(DbSkip())
				Enddo
			Endif

			// Monta array de retorno
			AaDd( aRet,{ TrbBC1Prof->CODPRF,;
				TrbBC1Prof->NOME,;
				TrbBC1Prof->SIGLCR,;
				TrbBC1Prof->NUMCR,;
				TrbBC1Prof->ESTCR,;
				TrbBC1Prof->CGC,;
				TrbBC1Prof->CODOPE,;
				BAU->BAU_CODIGO,;
				BAU->BAU_NREDUZ,;
				BAU->BAU_CPFCGC,;
				BAU->BAU_CNES,;
				aEspeci} )
		EndIf
		TrbBC1Prof->( DbSkip() )
	EndDo
	TrbBC1Prof->( DbCloseArea() )
EndIf

If ! Empty(cOldAlias)
	DbSelectArea(cOldAlias)
Endif
Return(aRet)

/*/{Protheus.doc} PLVLDREQ
Valida o REQUISITANTE. Verifica se o requisitante esta cadastrado
em BB0-Profissionais de Saude
@type function
@author TOTVS
@since 04/11/04
@version 1.0
/*/
Function PLVLDREQ(cNumReq)
LOCAL lRet := .T.
LOCAL cMsg := ""
LOCAL cNom := ""
// Verifica parametro recebido
If  cNumReq == nil
	cMsg := STR0038 //"Requisitante nao informado"
	lRet := .F.
Else
	// Ponto de entrada para validacao do requisitante
	// Regra especifica do cliente
	If  ExistBlock("PLVLDREQ")
		Return(ExecBlock("PLVLDREQ",.F.,.F.,cNumReq))
	Else
		// Valida Equipamento x Local x RDA
		BB0->(dbSetOrder(5)) // CODIGO ORIGINAL (ANTERIOR)
		If  ! BB0->(MsSeek(xFilial("BB0")+cNumReq))
			cMsg := STR0039 //"Requisitante nao cadastrado"
			lRet := .F.
		Else
			cNom := BB0->BB0_NOME
			If BB0->(FieldPos("BB0_CODBLO")) > 0
				lRet := A090CHEBLO(BB0->BB0_CODIGO,Date(),.F.)
				If ! lRet
					cMsg := STR0040 //"Requisitante Bloqueado"
				EndIf
			EndIf
		EndIf
	Endif
Endif
Return({lRet,cMsg,cNom})

/*/{Protheus.doc} PLVLDUSRW
Valida o usuario web. Verifica se o usuario/senha informados estao corretos
@type function
@author TOTVS
@since 04/11/04
@version 1.0
/*/
Function PLVLDUSRW(cLogUsr,cSenhaPLS)
LOCAL aArea		:= getArea()
LOCAL lRet    	:= .T.
LOCAL cMsg    	:= ""
LOCAL nTam    	:= TamSx3("BSW_LOGUSR")[1]
LOCAL nIndDat 	:= GetNewPar("MV_INTDAT",30)
LOCAL nTp		:= 1
LOCAL cCodUsr 	:= ""
LOCAL cCodAce 	:= ""
LOCAL cEMail  	:= ""
LOCAL cTipCar 	:= "0"
LOCAL cBiomet	:= "0"
LOCAL cBioCad	:= "0|"+GetNewPar("MV_BIOVMD","0")
LOCAL lTret		:= .F.
LOCAL cModBio	:= GetNewPar("MV_BIOVLDR","1") //1=NitGen / 2=BioTouch / 3=DigitalPersona / 4=Griaule
LOCAL aRet	  	:= {}
LOCAL aAtalhos 	:= {}
LOCAL cCaminho	:= ""
LOCAL cCodMnu	:= ""
LOCAL lAchou 	:= .F.
LOCAL cCodPor	:= ""

// Tipo de Drive conforme parametro
Do Case
	Case cModBio == '1'
		cModBio = "NITGEN"
	Case cModBio == '2'
		cModBio = "BIOTOUCH"
	Case cModBio == '3'
		cModBio = "DIGITALPERSONA"
	Case cModBio == '3'
		cModBio = "GRIAULE"
EndCase

// Como nao e garantido que o usuario efetue o logoff limpo as sessoes no login
HttpFreeSession()

// Criptograva a senha
If FindFunction("PLSCRIDEC")
	cSenhaPLS := PLSCRIDEC(1,AllTrim(cSenhaPLS))
EndIf

// Ponto de entrada para tratamento do login diferenciado
If ExistBlock("PLLOGDIF")
	cLogUsr := ExecBlock("PLLOGDIF",.F.,.F.,cLogUsr)
EndIf

// Atribui valor
cLogUsr := AllTrim(cLogUsr)
cLogUsr := cLogUsr + Space( nTam - Len(cLogUsr) )

// Valida usuario/senha
BSW->( DbSetOrder(1) ) //BSW_FILIAL + BSW_LOGUSR
If  BSW->(MsSeek(xFilial("BSW")+cLogUsr))

	cCodUsr := BSW->BSW_CODUSR

	// Verifica se a Senha gravada utiliza Hash MD5
	If Len(AllTrim(BSW->BSW_SENHA)) = 32
		cSenhaBSW := BSW->BSW_SENHA
	Else
		cSenhaBSW := PLSCRIDEC(2,AllTrim(BSW->BSW_SENHA))
	Endif

	If AllTrim(cSenhaBSW) == Alltrim(cSenhaPLS)

		lRet := .T.

		aRetSen := PLVLDSDT()
		
		If aRetSen[1]
			cMsg := "Senha expirada, favor procurar o administrador do sistema para cadastrar uma nova senha"
			lRet := .F.
		Else
			
			lTret	:= PLSVlTNT()
			
			IF 	lTret
				cMsg	:= "Tentativa de login ultrapassou o limite permitido, favor tentar após 5 minutos...!!!"
				lRet    := .F.
			Else
				lRet := .T.
			EndIf
			
		EndIf
		
	Endif
	
	If  !(AllTrim(cSenhaBSW) == Alltrim(cSenhaPLS))
		
		lTret := PLSVlTNT()
		
		IF 	lTret
			cMsg	:= "Tentativa de login ultrapassou o limite permitido, favor tentar após 5 minutos...!!!"
			lRet    := .F.
		Else
			cMsg    := STR0041 //"Senha invalida"
			lRet    := .F.
		EndIf
		
	ElseIf Empty(BSW->BSW_CODACE)
		
		lTret	:= PLSVlTNT()
		
		IF 	lTret
			cMsg	:= "Tentativa de login ultrapassou o limite permitido, favor tentar após 5 minutos...!!!"
			lRet    := .F.
		Else
			cMsg    := STR0050 //"Não foi definido direito para este usuário"
			lRet    := .F.
		EndIf
		
	Else
	
		// Codigo do usuario
		cCodUsr := BSW->BSW_CODUSR
		
		// Codigo de acesso para montar menus
		cCodAce := BSW->BSW_CODACE
		
		// E-mail para o caso de esquecer a senha
		cEMail := BSW->BSW_EMAIL
		
		// Tipo de acesso Cartao ou Matricula
		cTipCar := BSW->BSW_TIPCAR
		
		// Validacao Biometrica
		cBiomet := BSW->BSW_BIOMET
		
		// Permite cadastrar biometria via portal
		If BSW->( FieldPos("BSW_BIOCAD") ) > 0
			cBioCad :=  StrTran(cBioCad,SubStr(cBioCad,0,1),BSW->BSW_BIOCAD,1,1)
		EndIf
		
		// Verifica o tipo do portal
		nTp := Val(BSW->BSW_TPPOR)
		
		// Monta retorno conforme o tipo do portal
		Do Case
			// Verifica se tem algum prestador para o usuario
			Case nTp == 1
			
				aRet := PLRELRDA(cCodUsr)
			
				If Empty(aRet)
					cMsg := STR0051 //"Não encontrado prestador para este usuário"
					lRet := .F.
				ElseIf !VldBlqFut(cCodUsr)
					cMsg := "A Rede de Atendimento está Bloqueada/Suspensa"
					lRet := .F.
				EndIf
				
			// Verifica se tem operadora empresa contrato subcontrato para o usuario
			Case nTp == 2
			
				aRet := PLRELCOS(cCodUsr)
				
				If Empty(aRet)
					cMsg := "Não encontrado contrato/sub-contrato para este usuário"
					lRet := .F.
				EndIf
				
			// Verifica se tem algum beneficiario para o usuario
			Case nTp == 3
				
				B49->(DbSetOrder(1))
				if B49->(DbSeek(xFilial("B49")+cCodUsr))
				
					If !Len(AllTrim(B49->B49_BENEFI)) == 11 //CPF
					
						aRet := PLRELBEN(cCodUsr)
					
						If empty(aRet)
							cMsg := "Não encontrado beneficiário para este usuário"
							lRet := .F.
						endIf
						
					endIf
					
				endIf	
				
		EndCase
		
	EndIf
	
Else
	cMsg := STR0052 //"Usuário não cadastrado"
	lRet := .F.
EndIf

If lRet .and. PLSALIASEXI("B95") 
	
	B95->( DbSetOrder(1) )
	B95->(DBGoTop())
	
	While B95->(! Eof() )
		
		If(B95->B95_CODUSR == cCodUsr)
		
			cCaminho := AllTrim(B95->B95_IMG)

			If !(("HTTP" $ Upper(cCaminho)) .or. ("WWW." $ Upper(cCaminho)) .or. (".COM" $ Upper(cCaminho)))
				cCaminho := SUBSTR(cCaminho, 9)
			EndIf

			cCodMnu := B95->B95_CODMNU
			cCodPor := B95->B95_CODPOR
			
			AI8->(DBGoTop())
			
			While (AI8->( ! Eof() ) .and. lAchou == .F.)
				
				If(AI8->AI8_CODMNU == cCodMnu .and. AI8->AI8_PORTAL == cCodPor)
					Aadd(aAtalhos, { B95->B95_CODMNU, B95->B95_DESCRI, cCaminho, AI8->AI8_WEBSRV, AI8->AI8_ROTINA })
					lAchou := .T.
				EndIf
				
			AI8->(dbSkip())
			EndDo
			
			lAchou := .F.
		EndIf
		
	B95->(dbSkip())
	EndDo
	
EndIf

RestArea(aArea)

Return( {lRet,cCodUsr,cMsg,cCodAce,cEMail,aRet,nIndDat,cTipCar,cBiomet,cModBio,nTp, aAtalhos, lTRet, cBioCad} )

/*/{Protheus.doc} PLSVlTNT
Valida o numero de tentativa de acesso ao portal
@type function
@author TOTVS
@since 16/10/14
@version 1.0
/*/
Function PLSVlTNT()
Local nQtds	:= 0
Local lTret	:= .F.
Local nTent	:= getNewPar("MV_PLSTENT",5)
Local cSQL	:= ""

cSQL := "SELECT MAX(R_E_C_N_O_) BX1_RECNO"
cSQL += " FROM " + RetSqlName("BX1")
cSQL += " WHERE BX1_FILIAL = '" + xFilial("BX1") + "' "
cSQL += " AND BX1_CODUSR = '" + BSW->BSW_CODUSR + "' "
cSQL += " AND BX1_ALIAS = 'BSW' "
cSQL += " AND D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSQL)),"BX1MAX",.F.,.T.)

If BX1MAX->(!EOF()) .And. BX1MAX->BX1_RECNO > 0

	BX1->(dbGoTo(BX1MAX->BX1_RECNO))

	If BX1->BX1_QTACES < nTent

		nQtds := BX1->BX1_QTACES+1
		
		BX1->(RecLock("BX1",.F.))
			BX1->BX1_DATA     := Date()
			BX1->BX1_HORA     := Time()
			BX1->BX1_QTACES	  := nQtds
		BX1->(MsUnLock())
	Endif
	
	If  BX1->BX1_QTACES >= nTent
	
		lTret 	:= .T.
		nTime 	:= Time()
		nResulHs:= ELAPTIME(BX1->BX1_HORA,nTime)
		
		IF nResulHs >= "00:05:00"
		
			cSeq := PLBX1NEW()
			
			BX1->(RecLock("BX1",.T.))
				BX1->BX1_FILIAL   := xFilial("BX1")
				BX1->BX1_SEQUEN   := cSeq
				BX1->BX1_ALIAS    := "BSW"
				BX1->BX1_RECNO    := StrZero(Recno(),Len(BX1->BX1_RECNO))
				BX1->BX1_TIPO     := "W"
				BX1->BX1_USUARI   := BSW->BSW_CODUSR
				BX1->BX1_DATA     := Date()
				BX1->BX1_HORA     := Time()
				BX1->BX1_ESTTRB   := GetComputerName()
				BX1->BX1_ROTINA := 'PRTLOGIN'
				BX1->BX1_CODUSR		:= BSW->BSW_CODUSR
				BX1->BX1_QTACES		:= 1
			BX1->(MsUnLock())
			
			lTret := .F.
		EndIf
		
	Else
		lTret := .F.
	EndIf
Endif

BX1MAX->(DbCloseArea())

Return(lTret)

/*/{Protheus.doc} PLVLDSDT
Valida a data da criacao de acesso ao portal. Verifica se o usuario esta sem trocar a senha a quase 1 ano
@type function
@author TOTVS
@since 15/10/14
@version 1.0
/*/
Function PLVLDSDT()
Local nMaxDias  := getNewPar("MV_PLMDSEN",365)// Quantidade dias para troca senha
Local nDiasAvis := getNewPar("MV_PLDASEN",30) // Quantidade de dias para Aviso Expiracao Senha
Local cData		:= DATE()
Local nDtResult	:= 1
Local lBloq     := .F.
Local lMens     := .F.
Local ndiaRes   := 0 // Dias restante

If cData > BSW->BSW_DTSEN
	nDtResult := cData - BSW->BSW_DTSEN
EndIf

// Usuario Bloqueado
If nDtResult >= nMaxDias
	lBloq := .T.
Endif

// Usuario envia Mensagem
If !lBloq .And. (nDtResult >=(nMaxDias-nDiasAvis) .And. nDtResult < nMaxDias)
	lMens := .T.
	ndiaRes := nMaxDias- nDtResult
EndIf
	
Return({lBloq,lMens,ndiaRes})

/*/{Protheus.doc} PLVLDUSRP
Valida o usuario do plano de saude (BA1)
Verifica se o usuario esta cadastrado no BA1
@type function
@author TOTVS
@since 04/11/04
@version 1.0
/*/
Function PLVLDUSRP(cCodUsr,cViaCar,cNomeCar,cLocalExec,cAreaAbr,cTpLocExec,cTipo, cTipAtd,DatGuia,BloqGui, cTriCar)
LOCAL nI			:= 0
LOCAL lIntercambio	:= .F.
LOCAL lRet     		:= .T.
LOCAL cMatric   	:= ""
LOCAL cMsg    		:= ""
LOCAL cCodCon 		:= ""
LOCAL dData 	    := dDataBase
LOCAL aMatUsu		:= {}
LOCAL aRetFun 		:= {}
LOCAL aRetCri  		:= {}
LOCAL aCodUsuario	:= {}
local aRet			:= {}
LOCAL cAlias 		:= ""
LOCAL lPacInt		:= .F.

DEFAULT cNomeCar    := ""
DEFAULT cLocalExec  := ""
DEFAULT cAreaAbr	:= ""
DEFAULT cTpLocExec  := ""
DEFAULT cTipo		:= "0"
DEFAULT cTipAtd 	:= ""
DEFAULT DatGuia		:= ""
DEFAULT BloqGui		:= .F.
DEFAULT cTriCar	:= ""
// ponto de entrada para manipular dados antes da validacao da carteirinha no portal
if existBlock("PLSRDUSR")
	aRet 		:= execBlock("PLSRDUSR",.f.,.f.,{cCodUsr,cViaCar,cNomeCar,cLocalExec,cAreaAbr,cTpLocExec,cTipo,cTipAtd, cTriCar})
	cCodUsr 	:= aRet[1]
	cViaCar 	:= aRet[2]
	cNomeCar 	:= aRet[3]
	cLocalExec	:= aRet[4]
	cAreaAbr 	:= aRet[5]
	cTpLocExec	:= aRet[6]
	cTipo 		:= aRet[7]
	cTipAtd 	:= aRet[8]
	If (len(aRet) > 8)
		cTriCar:=aRet[9]
	EndIf
endIf

// Valida usuario/senha
BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
If  !BA1->( MsSeek( xFilial("BA1")+AllTrim(cCodUsr) ) )
	
	BA1->( DbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
	If !BA1->( MsSeek( xFilial("BA1")+AllTrim(cCodUsr) ) )
		
		If  SubStr(cCodUsr,1,4) <> PLSINTPAD() .And. !Empty(cNomeCar)
			lIntercambio := .T.
		Else
			If SubStr(cCodUsr,1,4) <> PLSINTPAD() .And. AllTrim( GETNEWPAR("MV_PLSUNI","0") ) == "1"
				cMsg := STR0057 //"Usuario de intercambio nao cadastrado"
			Else
				cMsg := STR0043 //"Usuario nao cadastrado"
			EndIf
			lRet := .F.
		Endif
		
	Endif
	
EndIf

// Se achou o usuario
If lRet
	// Matricula
	cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	If Empty(cMatric)
		cMatric := cCodUsr
	Else
		lIntercambio := PLSINTPAD() <> BA1->BA1_OPEORI
		// Se nao for de intercambio pega a data de nascimento do usuario
		If !lIntercambio
			dData := BA1->BA1_DATNAS
		EndIf
	EndIf
	
	// Ponto de entrada para identificar se o usuario e de intercambio
	// O BA1 tem que estar posicionado
	If  ExistBlock("PLSUSUINT")
		lIntercambio := ExecBlock("PLSUSUINT",.F.,.F.,cCodUsr)
		If !lIntercambio
			dData := BA1->BA1_DATNAS
		EndIf
	EndIf
	
	// Checa Intercambio
	If !lIntercambio
		BA3->(DbSetOrder(01)) //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
		If !BA3->( MsSeek( xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ) )
			cMsg := STR0047 //"Familia nao cadastrada"
			lRet := .F.
		EndIf
	EndIf
	
	// PE para identificar se o usuario digitou o cogido corretamente
	// O BA1 tem que estar posicionado
	If  ExistBlock("PLSUSUCOD")
		aCodUsuario := ExecBlock("PLSUSUCOD",.F.,.F.,cCodUsr)
		
		If Valtype(aCodUsuario)="A"
			lRet 	:= aCodUsuario[1]
			cMsg 	:= aCodUsuario[2]
			cMatric := aCodUsuario[3]
		Endif
		
	EndIf
	
	// Se ok
	If lRet
	
		// Regras e inclui usuario de intercambio se nao existir
		If lIntercambio .And. len(cNomeCar) > 1 .And. Substr(cNomeCar,1,1) == "%"
			cNomeCar := Substr(cNomeCar,2,len(cNomeCar))
		EndIf
		
		// Validação de atendimento pelo produto do beneficiário
		If  cTipAtd == "1" .OR. cTipAtd == "2"

			cAlias = "BE1"
			
		ElseIf cTipAtd == "3"

			cAlias = "BE4"
			
		ElseIf cTipAtd == "4"

			cAlias = "B01"
			
		Else
			cAlias = "BE1"
		EndIf
		
		aRetFun := PLSA090USR(cMatric,dDataBase,SubStr(Time(),1,5),cAlias,.F.,.T.,Nil,cLocalExec,Nil,Nil,cViaCar,"1",.T.,cNomeCar,dData,lIntercambio,nil,nil,nil,nil,cTpLocExec,cTipAtd,.F.,BloqGui)
		
		If Len(aRetFun) >= 5 .and. !aRetFun[5]
			
			If cTipAtd == "4"
				lRet := .F.
				cMsg := "O beneficiário não possui plano odontológico, verifique a segmentação do produto do beneficiário."
			ElseIf cTipAtd == "1" .OR. cTipAtd == "2" .OR. cTipAtd == "3"
				lRet := .F.
				cMsg := "O beneficiário não possui plano médico, verifique a segmentação do produto do beneficiário."
			EndIf
			
		EndIf
		
		// Retorno
		If ! aRetFun[1]
			aRetCri := aClone(aRetFun[2])
		EndIf
		
		// Retorno Paciente Internado mas Bloqueado Liberar a Digitação
		If(Len(aRetFun) > 5)
			lPacInt := aRetFun[6]
		EndIf
		
		// Dados do usuario
		aDadUsr := PLSGETUSR()
		
		// Verifica carencia para consulta
		If cTipo == '1'
		
			cCodCon := GETMV("MV_PLSCDCO")
			
			aRetFun := PLSAUTP(	Date(),;
								StrTran(Time(),":",""),;
								Subs(cCodCon,1,2),;
								Subs(cCodCon,3,16),;
								1,;
								aDadUsr,;
								0,;
								{},;
								"1",;
								.F.,;
								"",;
								.T.,;
								"1",;
								.F.,;
								"",;
								"",;
								Subs(dtoc(Date()),1,4),;
								Subs(dtoc(Date()),5,2))
								
			// Verifica se tem criticas
			If !aRetFun[1]
				
				If Len(aRetCri) == 0
					aRetCri := aClone(aRetFun[2])
				Else
					For nI := 1 To Len(aRetFun[2])
						AaDd(aRetCri, aRetFun[2,nI] )
					Next
				EndIf
				
				lRet := .F.
			EndIf
			
		EndIf
		
		// Tratamento da abrangencia										   	    |
		PLSABRANG(cAreaAbr,cLocalExec,cTpLocExec,"","",aDadUsr,{},@aRetCri)
		
		// Matriz com informações do usuarios
		AaDd(aMatUsu,{	Iif(Len(aDadUsr)>=2,aDadUsr[2],cMatric),;			//01-Numero do cartao
						Iif(Len(aDadUsr)>=3,aDadUsr[3],""),;			    //02-Matricula Antiga
						Iif(Len(aDadUsr)>=6,aDadUsr[6],""),;				//03-Nome do usuario
						lIntercambio,;										//04-se e de intercambio
						Iif(Len(aDadUsr)>=45,aDadUsr[45],PlsIntPad()),;	//05-Operadora origem
						Iif(Len(aDadUsr)>=73,aDadUsr[73],""),;			//06-Nome do produto do usuario
						Iif(Len(aDadUsr)>=74,aDadUsr[74],StoD("")),;		//07-Data da Validade Carteir.
						Iif(Len(aDadUsr)>=77,aDadUsr[77],""),;	 		//08-Nr Cartao Nacional Saude
						Iif(Len(aDadUsr)>=53,aDadUsr[53],0),;				//09-Via do cartao
						Iif(Len(aDadUsr)>=65,aDadUsr[65],""),;    		//10-Local de Cobranca
						Iif(Len(aDadUsr)>=65,aDadUsr[65],""),;			//11-Abrangencia
						Iif(Len(aDadUsr)>=45,aDadUsr[45],""),;			//12-Naturesa juridica
						Iif(Len(aDadUsr)>=79,aDadUsr[79],""),;			//13-Telefone do Usuario
						Iif(Len(aDadUsr)>=40,aDadUsr[40],""),;			//14-Nome Titular
						Iif(Len(aDadUsr)>=7,aDadUsr[7],""),;				//15-Nome Empresa
						Iif(Len(aDadUsr)>=5,aDadUsr[5],""),;				//16-Vida do Usuario
						Iif(Len(aDadUsr)>=80,aDadUsr[80],""),;			//17-String Biometrica 1
						Iif(Len(aDadUsr)>=81,aDadUsr[81],""),;			//18-String Biometrica 2
						Iif(Len(aDadUsr)>=17,aDadUsr[17],""),;			//19-Tipo de Acomodacao
						Iif(Len(aDadUsr)>=20,aDadUsr[20],""),;			//20-Padrao de Conforto
						Iif(Len(aDadUsr)>=21,aDadUsr[21],""),;			//21-Descricao do Tipo de Acomodacao
						Iif(Len(aDadUsr)>=88,aDadUsr[88],""),;  //22-Data de bloqueio
						lPacInt			} )         //Paciente Bloqueado mas que está internado
	EndIf
	
EndIf

IF lPacInt
	cMsg := aRetFun[7]
Endif

Return( { lRet,cMsg,aMatUsu,aRetCri } )

/*/{Protheus.doc} PLIMPWEB
Rotina para impressao de guias via web
@type function
@author TOTVS
@since 29/03/05
@version 1.0
/*/
Function PLIMPWEB(lImpGui,cGuia)

// Parametros de entrada
// 1) lImpGui
//    .T. = indica que deve gerar relatorio em disco
//    .F. = indica que dever retornar array com dados da guia
// 2) cGuia (numero da guia)
//    Se estiver informado, indica que eh para processar apenas este
//    numero de guia informada
//    Se nao estiver informado, devera ser aberto uma janela de perguntas
//    solicitando os parametros para processamento
// Parametros de saida
// 1) Status
//    .T. = processamento ok   .F. = houve algum erro
// 2) Mensagem de erro
//    Caso o parametro 1 seja .F., havera mensagem de erro
// 3) Array com dados da guia
// Inicializa variaveis
Local   aRetorno := {.F.,STR0044,{}} //"Programa de impressao nao encontrado"
Default lImpGui  := .F.
Default cGuia    := ""
// Chama ponto de entrada impressao
If  ExistBlock("PLIMPWEB")
	aRetorno := ExecBlock("PLIMPWEB",.F.,.F.,{lImpGui,cGuia})
Endif
Return(aRetorno)

/*/{Protheus.doc} PlsUsrBkp
Funcao para armazenar dados dos usuarios em diversas tab.
@type function
@author TOTVS
@since 03.05.05
@version 1.0
/*/
Function PlsUsrBkp(cMatricula,dData,aTabelas)
Local aArea := sGetArea()
Local nI
Local cAlias
Local cWhile
Local nJ
Local nSeqReg
Local nSeqCam
Local cVal
Local cHora := time()
For nI := 1 to Len(aTabelas)
	sGetArea(aArea,aTabelas[nI,1])
Next
For nI := 1 to Len(aTabelas)
	cAlias := aTabelas[nI,1]
	cWhile := aTabelas[nI,4]
	DbSelectArea(cAlias)
	DbSetOrder(aTabelas[nI,3])
	msSeek(xFilial()+cMatricula)
	nSeqReg := 0
	While (cAlias)->(!Eof()) .and. xFilial(cAlias) == (cAlias)->&(cAlias+"_FILIAL") .and. cMatricula == (cAlias)->&cWhile
		nSeqReg++
		nSeqCam := 0
		For nJ := 1 to FCount()
			cVal := ConvDad((cAlias)->(FieldGet(nJ)))
			If  ! empty(cVal)
				nSeqCam++
				BQY->(RecLock("BQY",.T.))
				BQY->BQY_FILIAL := xFilial("BQY")
				BQY->BQY_MATRIC := cMatricula
				BQY->BQY_DATA   := dData
				BQY->BQY_HORA   := cHora
				BQY->BQY_ALIAS  := cAlias
				BQY->BQY_SEQUEN := StrZero(nSeqReg,4)+StrZero(nSeqCam,3)
				BQY->BQY_CAMPO  := (cAlias)->(FieldName(nJ))
				BQY->BQY_CONTEU := cVal
				BQY->(MsUnlock())
			Endif
		Next
		(cAlias)->(DbSkip())
	EndDo
Next
sRestArea(aArea)
Return .t.

/*/{Protheus.doc} ConvDad
Funcao que converte qualquer tipo de variavel p/ caracter
@type function
@author TOTVS
@since 03.05.05
@version 1.0
/*/
Static Function ConvDad(uVal)
Local cVal := ""

If     ValType(uVal)=="C"
	cVal := uVal
ElseIf ValType(uVal)=="N"
	If  uVal == 0
		cVal := ""
	Else
		cVal := AllTrim(cValToChar(uVal))
	Endif
ElseIf ValType(uVal)=="D"
	If  empty(uVal)
		cVal := ""
	Else
		cVal := DtoS(uVal)
	Endif
EndIf
If  Len(cVal) > 250
	cVal := PadR(cVal,250)
EndIf

Return cVal

/*/{Protheus.doc} PLSHISPAG
Grava historico de processamento
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSHISGRV(cIdeRot,cCodCha,cSeq,cHistor,lHist)

DEFAULT lHist := .T.

// Grava registro
If  PLSALIASEX("B03")
	B03->(dbSetOrder(1))
	If lHist
		If  B03->(msSeek(xFilial("B03")+cIdeRot+cCodCha+cSeq))
			B03->(RecLock("B03",.F.))
		Else
			B03->(RecLock("B03",.T.))
			B03->B03_FILIAL := xFilial("B03")
			B03->B03_ROTINA := cIdeRot
			B03->B03_CHAVE  := cCodCha
			B03->B03_SEQ    := cSeq
		Endif
		B03->B03_HISTOR := cHistor
		B03->(msUnLock())
	EndIf
Endif
Return()

/*/{Protheus.doc} PLSHISDEL
Exclui historico de processamento
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSHISDEL(cIdeRot,cCodCha)
	
// Grava registro
If  PLSALIASEX("B03")
	B03->(dbSetOrder(1))
	While B03->(msSeek(xFilial("B03")+cIdeRot+cCodCha))
		B03->(RecLock("B03",.F.))
		B03->(dbDelete())
		B03->(msUnLock())
	Enddo
Endif
Return()

/*/{Protheus.doc} PLSHISCON
Consulta historico de processamento
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSHISCON(cIdeRot,cCodCha,cTitulo)

// Inicializa variaveis
Local aHistorico := {}
Local aCabec     := { {"Seq","@!",20},{STR0045,"@!",200} } //"Descricao"
Local nTamanho
cCodCha  := alltrim(cCodCha)
nTamanho := len(cCodCha)
If  ! PLSALIASEX("B03")
	Return()
Endif
// Monta array com historico de processamento
B03->(dbSetOrder(1))
B03->(msSeek(xFilial("B03")+cIdeRot+cCodCha))
While ! B03->(eof()) .and. B03->B03_FILIAL+B03->B03_ROTINA+substr(B03->B03_CHAVE,1,nTamanho) == ;
		xFilial("B03")+cIdeRot+cCodCha
	aadd(aHistorico,{B03->B03_SEQ,B03->B03_HISTOR})
	B03->(dbSkip())
Enddo
// Exibe tela com inconsistencias encontradas durante o processo...
If  Len(aHistorico) > 0
	PlsCriGen(aHistorico, aCabec, cTitulo,,,,,,,,,,,,,,,,,,,,TFont():New("Courier New",7,14,,.F.,,,,.F.,.F.))
Else
	msgAlert(STR0046 + cIdeRot + " " + alltrim(cCodCha)) //"Nao existe historico para esta chave: "
Endif
Return()

/*/{Protheus.doc} PLVLDPFS
Valida pessoa fisica
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLVLDPFS(cAlias, cChave, nOrdem, dDatPro)
	LOCAL lRet
	Local cCampo
	If ReadVar() $ "M->BE4_SIGLA" .or. ReadVar() $ "M->BE4_REGSOL"
		If len(M->BE4_SIGLA) == 3
			M->BE4_SIGLA := M->BE4_SIGLA + Space(4)
		EndIf
		cCampo := Alltrim(M->BE4_REGSOL)
		M->BE4_REGSOL := cCampo + (Space((TamSX3("BB0_NUMCR")[1])-(Len(cCampo))))
		If !Empty(BB0->BB0_CODSIG)
			If M->BE4_SIGLA != BB0->BB0_CODSIG
				M->BE4_SIGLA := BB0->BB0_CODSIG
				cChave := M->BE4_ESTSOL+M->BE4_REGSOL+M->BE4_SIGLA//+M->BE4_OPESOL
			Else
				cChave := M->BE4_ESTSOL+M->BE4_REGSOL+M->BE4_SIGLA+M->BE4_OPESOL
			Endif
			
			if M->BE4_ESTSOL != BB0->BB0_ESTADO
				M->BE4_ESTSOL := BB0->BB0_ESTADO
				cChave := M->BE4_ESTSOL+M->BE4_REGSOL+M->BE4_SIGLA//+M->BE4_OPESOL
			Else
				cChave := M->BE4_ESTSOL+M->BE4_REGSOL+M->BE4_SIGLA+M->BE4_OPESOL
			Endif			

		Else
			cChave := M->BE4_ESTSOL+M->BE4_REGSOL+M->BE4_SIGLA+M->BE4_OPESOL
		EndIf
	EndIf
	
	If ReadVar() $ "M->BD5_REGSOL"
		If len(M->BD5_SIGLA) == 3
			M->BD5_SIGLA := M->BD5_SIGLA + Space(4)
		EndIf
		If !Empty(BB0->BB0_CODSIG) .and. M->BD5_SIGLA != BB0->BB0_CODSIG
			M->BD5_SIGLA := BB0->BB0_CODSIG
		EndIf
		cCampo := Alltrim(M->BD5_REGSOL)
		M->BD5_REGSOL := cCampo + (Space((TamSX3("BB0_NUMCR")[1])-(Len(cCampo))))
		cChave := M->BD5_ESTSOL+M->BD5_REGSOL+M->BD5_SIGLA
	EndIf

	If ReadVar() $ "M->BE4_REGSOL"
		&(cAlias + "->(DbSetOrder(4))") //Faz o seek pela ordem 4 primeiro para buscar o solicitante de acordo com a chave.
		lRet := &(cAlias + '->(MsSeek(xFilial("BB0")+"' + cChave + '"))')
		If lRet	
			M->BE4_ESTSOL := BB0->BB0_ESTADO
			M->BE4_SIGLA  := alltrim(BB0->BB0_CODSIG)
			M->BE4_NOMSOL := BB0->BB0_NOME
			M->BE4_CDPFSO := BB0->BB0_CODIGO
		endif		
		
		&(cAlias + "->(DbSetOrder(" + Str(nOrdem) + "))") // Volta a ordem para busca pelo Numero do conselho caso ainda não tenha encontrado.
		
	else
		&(cAlias + "->(DbSetOrder(" + Str(nOrdem) + "))")
		lRet := &(cAlias + '->(MsSeek(xFilial("BB0")+"' + cChave + '"))')
	endif
	
	If ReadVar() $ "M->BE4_SIGLA"
		M->BE4_REGSOL := PADR("",Len(BE4_REGSOL))
		M->BE4_NOMSOL := PADR("",Len(BE4_NOMSOL))
		lRet = .T.
	EndIf
	
	If ReadVar() $ "M->BE4_REGSOL" .and. !lRet
		If lRet := BB0->( MsSeek(xFilial("BB0")+M->BE4_REGSOL) )
			If lRet
				M->BE4_ESTSOL := BB0->BB0_ESTADO
				M->BE4_SIGLA := alltrim(BB0->BB0_CODSIG)
				M->BE4_NOMSOL := BB0->BB0_NOME
				M->BE4_CDPFSO := BB0->BB0_CODIGO
				lRet := .T.
			Else
				M->BE4_REGSOL := PADR("",Len(BE4_REGSOL))
				M->BE4_NOMSOL := PADR("",Len(BE4_NOMSOL))
				M->BE4_CDPFSO := PADR("",Len(BE4_CDPFSO))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If !lRet .AND. cAlias == 'BB0' .AND. ReadVar() $ "M->BD5_REGEXE,M->BD7_REGPRE,M->BD5_REGSOL"
		// Para este caso iremos preencher o estado como gatilho e validar corretamente.
		// Nao basta inserir no (SX7) pois o gatilho preenche o campo apenas após a validação.
		BB0->( DbSetOrder(7) )
		
		If ReadVar() $ "M->BD5_REGEXE"
			lRet := BB0->( MsSeek(xFilial("BB0")+Ltrim(M->BD5_REGEXE)) )
			If lRet
				cCampo := Alltrim(M->BD5_REGEXE)
				M->BD5_REGEXE := cCampo + (Space((TamSX3("BB0_NUMCR")[1])-(Len(cCampo))))
				M->BD5_ESTEXE := BB0->BB0_ESTADO
				M->BD5_NOMEXE := BB0->BB0_NOME
				If M->BD5_SIGEXE != BB0->BB0_CODSIG
					M->BD5_SIGEXE := BB0->BB0_CODSIG
					cChave := M->BD5_ESTEXE+M->BD5_REGEXE+M->BD5_SIGEXE
				Else
					cChave := M->BD5_ESTEXE+M->BD5_REGEXE+M->BD5_SIGEXE
				EndIf
			EndIf
		ElseIf ReadVar() $ "M->BD5_REGSOL"
			lRet := BB0->( MsSeek(xFilial("BB0")+Ltrim(M->BD5_REGSOL)) )
			If lRet
				M->BD5_ESTSOL := BB0->BB0_ESTADO
				M->BD5_NOMSOL := BB0->BB0_NOME
				If M->BD5_SIGLA != BB0->BB0_CODSIG
					M->BD5_SIGLA := BB0->BB0_CODSIG
					cChave := M->BD5_ESTSOL+M->BD5_REGSOL+M->BD5_SIGLA
				Else
					cChave := M->BD5_ESTSOL+M->BD5_REGSOL+M->BD5_SIGLA
				EndIf
			EndIf
		ElseIf ReadVar() $ "M->BD7_REGPRE"
			cCampo := Alltrim(M->BD7_REGPRE)
			M->BD7_REGPRE := cCampo + (Space((TamSX3("BB0_NUMCR")[1])-(Len(cCampo))))
			lRet := BB0->( MsSeek(xFilial("BB0")+M->BD7_REGPRE) )
			If lRet
				M->BD7_ESTPRE := BB0->BB0_ESTADO
				If M->BD7_SIGLA != BB0->BB0_CODSIG
					M->BD7_SIGLA := BB0->BB0_CODSIG
					cChave := M->BD7_ESTPRE+M->BD7_REGPRE+IIf(Empty(M->BD7_SIGLA),Iif(BCL->BCL_ALIAS='BD5',M->BD5_SIGLA,M->BE4_SIGLA),M->BD7_SIGLA)
				Else
					cChave := M->BD7_ESTPRE+M->BD7_REGPRE+IIf(Empty(M->BD7_SIGLA),Iif(BCL->BCL_ALIAS='BD5',M->BD5_SIGLA,M->BE4_SIGLA),M->BD7_SIGLA)
				EndIf
			EndIf
		EndIf
		
		BB0->( DbSetOrder(nOrdem) )
		lRet := BB0->( MsSeek(xFilial("BB0")+cChave) )
		
	EndIf
	
	If ! lRet
		Help("",1,"REGNOIS")
	Else
		If BB0->(FieldPos("BB0_CODBLO")) > 0
			lRet := A090CHEBLO(BB0->BB0_CODIGO,dDatPro)
		EndIf
	Endif
Return lRet

/*/{Protheus.doc} PLVLDPRE
Inclusao do pre-atendimento
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
Function PLVLDPRE(aMat, cTpAca, cOrdDesc)
LOCAL nCont	    	:= 0
LOCAL nPeriod   	:= 0
LOCAL cCodCon   	:= ""
LOCAL cMsg 			:= ""
LOCAL lAtu 			:= .T.
LOCAL lCritPer 		:= .T.
LOCAL lJaTaPre 		:= .F.
LOCAL aRetFun  		:= {}
LOCAL aRetPer		:= {}
LOCAL aRet 			:= {}
LOCAL aDadUsr		:= {}
LOCAL cCritXAUT		:= ""
LOCAL lPLSPREAT 	:= ExistBlock("PLSPREAT")
LOCAL lContinua 	:= .T.
LOCAL lAbrang 		:= ""
LOCAL aArea 		:= {}
LOCAL lPosici 		:= .F.
LOCAL lMatrAnt  	:= GetNewPar("MV_PLMATAP","0") == "1" //Mostra Matricula Antiga Portal   
local nMV_PLDTPRE 	:= GetNewPar("MV_PLDTPRE",365)
LOCAL aAreaBA1  	:= {} 

default cOrdDesc := ""

If cTpAca == 'I'

	lAbrang := PLSA090LOC(aMat[4],aMat[5],aMat[7],dDataBase,"PORTAL")
	
	If !lAbrang
	
		cMsg := "O produto do beneficiário não atende a esta cidade ou estado, verifique a área de abrangência do plano."
		
		AaDd(aRet,{"","","","","",ctod(""),""} )
		
		Return( {cMsg,aRet} )
	EndIf
	
EndIf

If lMatrAnt .And. Len(aMat[1]) > 0
 
	aAreaBA1 := BA1->(GetArea())

	BA1->( DbSetOrder(5) )
	If BA1->( MsSeek( xFilial("BA1")+AllTrim(aMat[1]) ) )

		aMat[1] := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO

	EndIf
	
	BA1->(RestArea(aAreaBA1))
	
EndIf

// Se nao for informado a rda mostra todos conforme usuario
If cTpAca <> 'M'

	// Na inclusao Verifica se o usuario ja esta no pre-atendimento
	BZI->( DbSetOrder(2) ) //BZI_FILIAL + BZI_CODINT + BZI_CODEMP + BZI_MATRIC + BZI_TIPREG + BZI_DIGITO + BZI_CODRDA + BZI_CODLOC + BZI_HORTER
	If cTpAca == 'I' .OR. cTpAca == 'A'
		
		cSQL := " SELECT R_E_C_N_O_ REC FROM " + RetSQLName("BZI")
		cSQL += " WHERE BZI_FILIAL = '" + xFilial("BZI") + "' "
		cSQL += "   AND BZI_CODINT = '" + substr(aMat[1],1,4) + "' "
		cSQL += "   AND BZI_CODEMP = '" + substr(aMat[1],5,4) + "' "
		cSQL += "   AND BZI_MATRIC = '" + substr(aMat[1],9,6) + "' "
		cSQL += "   AND BZI_TIPREG = '" + substr(aMat[1],15,2) + "' "
		cSQL += "   AND BZI_DIGITO = '" + substr(aMat[1],17,1) + "' "
		cSQL += "   AND BZI_CODRDA = '" + aMat[5] + "' "
		cSQL += "   AND BZI_CODLOC = '" + aMat[7] + "' "
		cSQL += "   AND BZI_HORTER = ' ' "
		cSQL += "   AND BZI_DATCHE >= '" + dtos(dDataBase - nMV_PLDTPRE) + "' " //1 ano
		cSQL += "   AND D_E_L_E_T_ = ' ' "
		
		If (cOrdDesc = "1")
			cSQL += " ORDER BY BZI_FILIAL,BZI_DATCHE DESC,BZI_HORCHE DESC"
		Else
			cSQL += " ORDER BY BZI_FILIAL,BZI_DATCHE ,BZI_HORCHE "
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSQL)),"TrbBZI",.T.,.F.)
		
		If ! TrbBZI->(Eof())
			
			BZI->( dbGoTo(TrbBZI->REC) )
			
			cMsg := 'Usuario já esta no Pré-atendimento'
			
		ElseIf cTpAca == 'I'
		
			aRetFun := PLSDADUSR(aMat[1],"1",.F.,dDataBase)
		
			If ! aRetFun[1]
			
				aRetFun := PLSDADUSR(aMat[1],"2",.F.,dDataBase)
			
				If ! aRetFun[1]
					cMsg := "Matricula do beneficiário não reconhecida pela operadora nesta data"
				Endif
				
			Endif
			
			If aRetFun[1]
			
				aDadUsr := PLSGETUSR()
			
				PLSDADRDA(aMat[4],aMat[5],nil,dDataBase,aMat[7])
			
				aRetRDA := PLSVLDRDA()
				
				If ! aRetRDA[1]
					cMsg := '038 - Produto do usuario nao permite atendimento por esta Rede de Atendimento.'
				Endif
				
			Endif
		EndIf
		
		TrbBZI->(DbCloseArea())
		
	EndIf
	
	If cTpAca <> 'I'
	
		If cTpAca == 'C'
	
			If !BZI->( MsSeek( xFilial("BZI")+aMat[1]+aMat[5]+aMat[7]+'     ') )
				cMsg := 'Usuario não esta no Pré-atendimento'
			EndIf
			
		Else
			
			BZI->( DbSetOrder(5) ) //BZI_FILIAL + BZI_CODINT + BZI_CODEMP + BZI_MATRIC + BZI_TIPREG + BZI_DIGITO + BZI_CODUSR + BZI_HORTER
			If !BZI->( MsSeek( xFilial("BZI")+aMat[1]+aMat[2]+'     ') )
				cMsg := 'Usuario não esta no Pré-atendimento'
			EndIf
			
		EndIf
		
		lAtu := .F.
		
	EndIf
	
	// Testa periodicidade ou nao
	If cTpAca == 'I' .And. Empty(cMsg) .and. GetNewPar('MV_PLVDTPO','1') == '1'
		
		aRetFun := PLSA090USR(aMat[1],Date(),StrTran(Time(),":",""),"BE1",.F.,.T.)
		aDadUsr := PLSGETUSR()
		
		If ValType(aDadUsr) == "A" .And. Len(aDadUsr) >= 1 .And. aDadUsr[1]
			
			If Len(aDadUsr) > 0 .And. aDadUsr[1]
			
				cCodCon := GETMV("MV_PLSCDCO")
				nPeriod := GetMV("MV_PLDSCAG")
		
				// Verifica o codigo da consulta
				If ! Empty(cCodCon)
					BR8->( DbSetOrder(1) )
					BR8->( MsSeek( xFilial("BR8")+cCodCon ) )
				Else

					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0056 , 0, 0, {})//"Conteudo não informado MV_PLSCDCO"		
					
				EndIf

				// Checa algumas regras
				aRetPer := PLSAUTP(Date(),;
									StrTran(Time(),":",""),;
									Subs(cCodCon,1,2),;
									Subs(cCodCon,3,16),;
									1,;
									aDadUsr,;
									0,;
									{},;
									"1",;
									.F.,;
									"",;
									.T.,;
									"1",;
									.F.,;
									"",;
									"",;
									subs(dtoc(Date()),1,4),;
									subs(dtoc(Date()),5,2))
				
				lCritPer := aRetPer[1]
				
				If ! lCritPer
				
					aAuxCri := aRetPer[2]
					For nCont := 1 To Len(aAuxCri)
						if !Empty(aAuxCri[nCont,1])
							if !Empty(aAuxCri[nCont,3])
								cCritXAUT += "  "+aAuxCri[nCont,1]+" - "+aAuxCri[nCont,2]+" - "+aAuxCri[nCont,3]+CRLF+"  "
							else
								cCritXAUT += "  "+aAuxCri[nCont,1]+" - "+aAuxCri[nCont,2]+CRLF+"  "
							endif
							cCritXAUT += " <br>"
						endif

					Next
					
				Endif
				
			Endif
			
		Endif
		
		If lPLSPREAT .And. cTpAca == "I"
		
			aRetPtoEnt := ExecBlock("PLSPREAT",.F.,.F.,{cCritXAUT,aMat[1],aMat[5],aMat[7]})
			cMsgEsp    := aRetPtoEnt[1]
			lContinua  := aRetPtoEnt[2]
			
			If ! lContinua
				cCritXAUT := cMsgEsp
				cMsg      := cMsgEsp
			Endif
		Endif
		
	Endif
	
	// Grava ou atualiza
	If cTpAca <> 'I' .and. cTpAca <> 'C'
	
		aArea := GetArea()
	
		//POSICIONO NO REGISTRO QUE SERÁ ALTERADO COM BENEFICIARIO + RDA + LOCAL DE ATENDIMENTO
		BZI->(dbSetOrder(2)) //BZI_FILIAL, BZI_CODINT, BZI_CODEMP, BZI_MATRIC, BZI_TIPREG, BZI_DIGITO, BZI_CODRDA, BZI_CODLOC, BZI_HORTER
		
		If cTpAca == 'A' .AND. !(Empty(aMat[9]) .AND. Empty(aMat[10]))
		
			lPosici := BZI->(MsSeek(xFilial("BZI") + aMat[1] + aMat[9] + aMat[10]))
		
		ElseIf cTpAca == 'E'
		
			lPosici := BZI->(MsSeek(xFilial("BZI") + aMat[1] + aMat[5] + aMat[7]))
		
		EndIf
		
		restArea(aArea)
		
	EndIf
	
	If Empty(cMsg)
	
		BZI->( RecLock("BZI",lAtu) )
	
		// Inclusao
		If cTpAca == 'I'
	
			BZI->BZI_FILIAL := xFilial("BZI")
			BZI->BZI_CODINT := SubStr(aMat[1],1,4)
			BZI->BZI_CODEMP := SubStr(aMat[1],5,4)
			BZI->BZI_MATRIC := SubStr(aMat[1],9,6)
			BZI->BZI_TIPREG := SubStr(aMat[1],15,2)
			BZI->BZI_DIGITO := SubStr(aMat[1],17,1)
			BZI->BZI_CODUSR := aMat[2]
			BZI->BZI_NOMUSR := aMat[3]
			BZI->BZI_OPERDA := aMat[4]
			BZI->BZI_CODRDA := aMat[5]
			BZI->BZI_NOMRDA := aMat[6]
			BZI->BZI_CODLOC := aMat[7]
			
			BZI->BZI_TRILHA := aMat[8]
			BZI->BZI_DATCHE := Date()
			BZI->BZI_HORCHE := SubStr(Time(),1,5)
			
			If !lCritPer
				cMsg := cCritXAUT
			Endif
			
			// Ponto de entrada para validar regras especificas no pre-atendimento
			If lPLSPREAT .And. lContinua
				cMsg := cMsgEsp
			Endif
			
		// Alterar
		ElseIf cTpAca == 'A'
		
			BZI->BZI_OPERDA := aMat[4]
			BZI->BZI_CODRDA := aMat[5]
			BZI->BZI_NOMRDA := aMat[6]
			BZI->BZI_CODLOC := aMat[7]
			
		// Concluir
		ElseIf cTpAca == 'C'
		
			BZI->BZI_HORTER := SubStr(Time(),1,5)
		// Excluir
		ElseIf cTpAca == 'E'
			BZI->( DbDelete() )
		EndIf
		
		BZI->( MsUnLock() )
		
	EndIf
	
EndIf

// Monta pre-atendimento
cSQL := " SELECT BZI_CODINT, BZI_CODEMP, BZI_MATRIC, BZI_TIPREG, BZI_DIGITO, BZI_NOMUSR, BZI_CODRDA, "
cSQL += "        BZI_NOMRDA, BZI_CODLOC, BZI_DATCHE, BZI_HORCHE "
cSQL += "   FROM " + RetSQLName("BZI")
cSQL += "  WHERE BZI_FILIAL = '" + xFilial("BZI") + "' "

If (cTpAca == 'M' .And. !Empty(aMat[5])) .or. (cTpAca == 'I' .And. Len(aMat) >=5 .and. !Empty(aMat[5]) .and. !Empty(aMat[7]) .and. lJaTaPre)

	cSQL += "   AND BZI_CODRDA = '" + aMat[5] + "' "
	cSQL += "   AND BZI_CODLOC = '" + aMat[7] + "' "

Else

	If ! Empty(aMat[5]) .and. getNewPar("MV_PLSBZIA","0") == "1"
		cSQL += " AND (BZI_CODUSR = '"+aMat[2]+"' "
		cSQL += "  OR (BZI_CODRDA = '"+aMat[5]+"' AND BZI_CODLOC = '"+aMat[7]+"') ) "
	else
		cSQL += " AND BZI_CODUSR = '"+aMat[2]+"' "
	endIf
	
EndIf

cSQL += "   AND BZI_HORTER = '' "
cSQL += "   AND BZI_DATCHE >= '" + dtos(dDataBase - nMV_PLDTPRE) + "' "//3 anos
cSQL += "   AND D_E_L_E_T_ = ' ' "

If (cOrdDesc = "1")
	cSQL += " ORDER BY BZI_FILIAL,BZI_DATCHE DESC,BZI_HORCHE DESC"
Else
	cSQL += " ORDER BY BZI_FILIAL,BZI_DATCHE,BZI_HORCHE "
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSQL)),"TrbBZI",.T.,.F.)

if ! TrbBZI->( Eof() )
	plsTField("TrbBZI",.f.,{ "BZI_DATCHE" } )
endIf	

// Monta retorno
Do While !TrbBZI->( Eof() )

	AaDd(aRet,{	TrbBZI->(BZI_CODINT+BZI_CODEMP+BZI_MATRIC+BZI_TIPREG+BZI_DIGITO),;//Matricula
				TrbBZI->BZI_NOMUSR,;//Nome usuario
				TrbBZI->BZI_CODRDA,;//Codigo da Rda
				TrbBZI->BZI_NOMRDA,;//Nome da Rda
				TrbBZI->BZI_CODLOC,;//Local de Atendimento
				TrbBZI->BZI_DATCHE,;//Data de Chegada
				TrbBZI->BZI_HORCHE} )//Hora de Chegada
				
TrbBZI->( DbSkip() )
EndDo

If ! Empty(cMsg) .And. Len(aRet) == 0

	AaDd(aRet,{	"",;
				"",;
				"",;
				"",;
				"",;
				ctod(""),;
				""} )
				
Endif

// Fecha area
TrbBZI->( DbCloseArea() )
	
Return( {cMsg,aRet} )

/*/{Protheus.doc} PLSATUSS
Atualiza saldo e stalib
@type function
@author TOTVS
@since 09.10.08
@version 1.0
/*/
Function PLSATUSS(naoUsado,lSaldo,lStaLib,nSaldo,cStaLib,lInter,cChkLib,nIdx,lChkBE2,nRecno,nIdxBe2,nIncre,cCodPad,cCodPro,cDente,cFace,cOffline)
LOCAL aAreaBD6 		:= BD6->(GetArea())
LOCAL aAreaBE2 		:= BE2->(GetArea())
Local cCompchvOd		:= ""
Local lSeq          := .F.
Local cChkItens     := ""
Local cChkSeq       := ""
DEFAULT lSaldo 		:= .T.
DEFAULT lStaLib		:= .T.
DEFAULT lInter		:= .F.
DEFAULT lChkBE2 	:= .F.
DEFAULT nSaldo 		:= 0
DEFAULT cStaLib 	:= "2"
DEFAULT nIdx		:= 1
DEFAULT cChkLib		:= ""
DEFAULT nRecno		:= 0
DEFAULT nIdxBe2		:= nIdx
DEFAULT nIncre		:= 0
DEFAULT cCodPro		:= ''
DEFAULT cCodPad     := ''
Default cDente		:= ''
Default cFace			:= ''
Default cOffline    := ''
// Ajusta o Item
If ! lInter
	
	//neste if aqui a variavel cChkLib vem sem o Sequen
	//o tratamento do saldo tem q ser sempre pelo codpro e codpad
	//igual esta definido aqui embaixo
	if ! empty(cCodPro) .and. ! empty(cCodPad)
		
		If ! empTy(cDente)
			cCompchvOd += AllTrim(cDente)
			If ! empTy(cFace)
				cCompchvOd += AllTrim(cFace)
			EndIf
		EndIf
		
		// Necessario realizar um tratamento para considerado a chave + seq do item nas exclusões de guias odonto quando a origem seja das guias offiline.
		// e considere um dente que tenha varias regiões diferente dessa maneira seja atualizado o saldo corretamente.
        cChkSeq := substr(cChkLib,19,22)
		If(!empty(cChkSeq) .And. !empty(cOffline))
		     cChkLib := substr(cChkLib,1,22)
		     lSeq = .T.
		else
			 cChkLib := substr(cChkLib,1,18)
		EndIf
		
			
		BE2->( DbSetOrder(1) ) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
		BD6->( dbSetOrder(1) ) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
		
		If BE2->( MsSeek( xFilial("BE2") + cChkLib ) )
			
			IIF(lSeq, cChkItens  := BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN), cChkItens:= BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT))
			
			While !BE2->(Eof()) .and. xFilial("BE2") + cChkLib == cChkItens
				
				If alltrim(cCodPad + cCodPro) == alltrim(BE2->(BE2_CODPAD + BE2_CODPRO)) .AND. (empTy(cCompchvOd) .OR. AllTrim(BE2->(BE2_DENREG)) + Alltrim(BE2->(BE2_FADENT)) == cCompchvOd)
					
					BE2->( RecLock("BE2",.F.) )
					
					If lSaldo
						
						//se ele entrar aqui significa que existem duas ou mais vezes o mesmo procedimento na guia
						If nSaldo > BE2->BE2_SALDO
							nSaldo -= BE2->BE2_SALDO
							BE2->BE2_SALDO  := 0
						Else
							BE2->BE2_SALDO  := nSaldo
							lSaldo := .F.
						Endif
						
					EndIf
					
					If BE2->BE2_STATUS == "1" .and. nIncre > 0
						BE2->BE2_SALDO  += nIncre
						nIncre 			:= 0
					Endif
					
					If BE2->BE2_SALDO == 0
						cStaLib := '2'//finalizada
					elseIf BE2->BE2_SALDO >= 0
						cStaLib := '1'//em aberto
					endIf
					
					BE2->BE2_STALIB := cStaLib
					
					if BE2->BE2_SALDO > BE2->BE2_QTDPRO
						BE2->BE2_SALDO := BE2->BE2_QTDPRO
					endIf
					
					BE2->( MsUnLock() )
					
					if ( BD6->( msSeek( xFilial("BD6") + BE2->(BE2_OPEMOV+BE2_CODLDP+BE2_CODPEG+BE2_NUMERO) + BEA->BEA_ORIMOV + BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO) ) ) )
						
						BD6->( RecLock("BD6",.F.) )
						
						BD6->BD6_SALDO  := BE2->BE2_SALDO
						
						BD6->( msUnLock() )
						
					endIf
					
				Endif
				
			BE2->(DbSkip())
			Enddo
			
		Endif
		
	Else
		
		If ! empty(cChkLib)
			BE2->( DbSetOrder(nIdxBe2) )
			BE2->( MsSeek( xFilial("BE2") + cChkLib ) )
		EndIf
		
		If BE2->( Found() ) .Or. BE2->( Recno() ) == nRecno
			
			BE2->( RecLock("BE2",.F.) )
			
			If lStaLib
				BE2->BE2_STALIB := cStaLib
			EndIf
			
			If lSaldo
				BE2->BE2_SALDO  := nSaldo
			EndIf
			
			If nIncre > 0
				BE2->BE2_SALDO  += nIncre
			Endif
			
			if BE2->BE2_SALDO > BE2->BE2_QTDPRO
				BE2->BE2_SALDO := BE2->BE2_QTDPRO
				nIncre := 0
				nSaldo := BE2->BE2_SALDO
			endIf			
			 
			BE2->( MsUnLock() )
			
			BD6->( dbSetOrder(1) ) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
			if ( BD6->( msSeek( xFilial("BD6") + BE2->(BE2_OPEMOV+BE2_CODLDP+BE2_CODPEG+BE2_NUMERO) + BEA->BEA_ORIMOV + BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO) ) ) )
				
				BD6->( RecLock("BD6",.F.) )
				if lSaldo
					BD6->BD6_SALDO := nSaldo
				endIf
				if nIncre > 0
					BD6->BD6_SALDO  += nIncre
				endif
				if BD6->BD6_SALDO > 0
					BD6->BD6_SITUAC := '1'//em aberto
				endif
				BD6->( msUnLock() )
				
			endIf
			
		EndIf
	Endif
EndIf

BE2->( RestArea(aAreaBE2) )
BD6->( RestArea(aAreaBD6) )
	
Return

/*/{Protheus.doc} PLSATUCS
Atualiza stalib do cabecalho
@type function
@author TOTVS
@since 09.10.08
@version 1.0
/*/
Function PLSATUCS(cStaLib,cAliCab)
	LOCAL nRecBD5 	:= BD5->( Recno() )
	DEFAULT cStaLib := "2"
	DEFAULT cAliCab := "BEA"
	
	If &( cAliCab+"->( FieldPos('"+cAliCab+"_STALIB') )" ) > 0
		// Ajusta cabecalho da guia BEA
		&(cAliCab+"->(RecLock('"+cAliCab+"',.F.))")
		&(cAliCab+"->"+cAliCab+"_STALIB") := cStaLib
		&( cAliCab+"->( MsUnlock() )" )
		// Ajusta cabecalho da guia BE5
		If cAliCab == "BEA"
			If BD5->( IndexOrd() ) <> 1
				BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
			EndIf
			If BD5->( MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
				BD5->( RecLock("BD5",.F.) )
				BD5->BD5_STALIB := cStaLib
				BD5->( MsUnLock() )
			EndIf
			// Volta o recno
			BD5->( DbGoTo(nRecBD5) )
		EndIf
	EndIf
Return

/*/{Protheus.doc} PLIDSALD
Retorna Saldo de COntas Para Idade de Saldo DIOPS
@type function
@author TOTVS
@since 03.06.09
@version 1.0
/*/
Function PLIDSALD(dDatsld,cTpProc)
	Local cQuery, cForn, cIndex, cLog, cTitulo
	Local nVenc, nCateg, nData, nSaldo, nVez, nVlrBM1, nPos
	Local lPassivo	:= .T.
	Local lAtivo	:= .T.
	Local aVlrBM1, aVlrAt	:= {}
	Local cCod1	:= '104,127,134,137,138,139,140,141,142,143,144,145,116,121,124,147,148,149,150,151,152,153,154,155'		// Lancamentos de Custo Operacional
	Local cCod2	:= '117,122,125,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177'	// Lancamento de Faturamento de Taxa Administrativa
	Local lDiold:= GetNewPar('MV_PLDIOLD', .F.)
	Local cDir  := Alltrim(MV_PAR16)
	Local lPLDIOP01  := ExistBlock("PLDIOP01")
	Local lPLDIOP02  := ExistBlock("PLDIOP02")
	/*
	Array aRetAtivo:
	
	Vencimento      				   							Creditos de Operações com Planos de Saúde																																																		Outros Créditos Não Relacionados com Planos
	Financeiro
	PF Preco Pre				PF Preco Pos 					PJ Preco Pre				PJ Preco Pos				Convenios			Tx Adm				Participacao				Crd.Operadoras				Outros Crd Plano			Outros Crd Nao Planos
	
	[1,1]	  0 (a Vencer)										[1,2]						[1,3]							[1,4]						[1,5]						[1,6]				[1,7]				[1,8]						[1,9]						[1,10]						[1,11]
	[2,1]	 30 (Vencidos de 1 a 30 dias)
	[3,1]	 60 (Vencidos de 31 a 60 dias)
	[4,1]	 90 (Vencidos de 61 a 90 dias)
	[5,1]	999 (Vencidos a mais de 90 dias)
	*/
	
	
	Local aRetAtivo		:= {;
		{000,0,0,0,0,0,0,0,0,0,0},;
		{030,0,0,0,0,0,0,0,0,0,0},;
		{060,0,0,0,0,0,0,0,0,0,0},;
		{090,0,0,0,0,0,0,0,0,0,0},;
		{999,0,0,0,0,0,0,0,0,0,0},;
		{120,0,0,0,0,0,0,0,0,0,0},;
		{365,0,0,0,0,0,0,0,0,0,0}}
	
	
	/*
	Array aRetPassivo:
	
	Vencimento      				   				Débitos de Operações com Planos de Saúde																																									Outros Débitos Não Relacionados com Planos
	Financeiro
	Eventos/ Sinistros a Liquidar		Comercialização sobre Operações			Débitos com Operadoras			Outros Débitos de Operações com Planos		Dep.Beneficiario Contrap/Seg.Recebidos				Prestadores de Serv. de Assistência a Sáude			Deb.Aquisicao Carteira				Outros Débitos a Pagar
	
	[1,1]	  0 (a Vencer)							[1,2]								[1,3]									[1,4]							[1,5]										[1,6]												[1,7]												[1,8]								[1,9]
	[2,1]	 30 (Vencidos de 1 a 30 dias)
	[3,1]	 60 (Vencidos de 31 a 60 dias)
	[4,1]	 90 (Vencidos de 61 a 90 dias)
	[5,1]	120 (Vencidos de 91 a 120 dias)
	[6,1]	365 (Vencidos a mais de 120 dias)
	*/
	Local aRetPassivo	:= {;
		{  0,0,0,0,0,0,0,0,0,0,0 },;
		{ 30,0,0,0,0,0,0,0,0,0,0,0},;
		{ 60,0,0,0,0,0,0,0,0,0,0,0},;
		{ 90,0,0,0,0,0,0,0,0,0,0,0},;
		{120,0,0,0,0,0,0,0,0,0,0,0},;
		{999,0,0,0,0,0,0,0,0,0,0,0},;
		{-30,0,0,0,0,0,0,0,0,0,0,0},;
		{-60,0,0,0,0,0,0,0,0,0,0,0}}
	
	
	Local cxFilial   := nil
	Local cProcedure := 'FIN002'
	Local cTiPoData  := "0"
	Local cAliasTit
	Local nHandle	 := 0
	
	Local lPCCBaixa := getNewPar("MV_BX10925","2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
		!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
	
	Local cPCCBaixa   := iif(lPCCBaixa,"1","0")
	Local cAdiant	:= ''
	Local nVlrDes		:= 0
	Local	nVlrDesA	:= 0
	
	Local	nVlrPAA		:= 0
	Local	nVlrPA 		:= 0
	Local	nVlrJd 		:= 0
	Local	nVlrBx 		:= 0
	Local	nVlrAberto	:= 0
	Local	nVlrBxAnt	:= 0
	Local	nVlrPAAnt	:= 0
	Local	nVlrJdAnt	:= 0
	Local	dDatBxAnt	:= cTod('')
	Local	nDtBx		:= cTod('')
	Local	nVlrbxPar	:= 0
	Local	nVlrPAPar 	:= 0
	Local	nVlrJdPar 	:= 0
	Local cBanco := Alltrim(Upper(TCGetDb()))
	
	// Checa se existe variável para log
	If ValType(MV_PAR17) == 'U'
		MV_PAR17	:= 2
	EndIf
	
	
	nTxMoeda := 0
	
	// Tipo de Processamento: 0 - Nao processa, 1 - Ativo, 2 - Passivo
	Default cTpProc	:= '0'
	
	If cTpProc == '1'
		//	lAtivo		:= .T.
	ElseIf cTpProc == '2'
		lPassivo	:= .T.
	EndIf
	
	// PASSIVO
	If lPassivo
		
		// Seleciona todos os titulos que poderiam estar abertos na data final da apuracao da DIOPS
		cQuery	:= "SELECT SE2.R_E_C_N_O_ REGNUM, E2_FILIAL, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VALOR, E2_SALDO SALDO, "
		cQuery	+= "SE2.E2_VALOR+SE2.E2_ISS+SE2.E2_IRRF+SE2.E2_COFINS+SE2.E2_PIS+SE2.E2_CSLL+SE2.E2_INSS VALBRUT FROM "
		cQuery	+= RetSqlName("SE2")+" SE2, "+RetSqlName("SA2")+" SA2 "
		
		// Nova query conforme instruções da Caberj - Produção
		cQuery	+= "WHERE SE2.E2_FILIAL = '"+Xfilial("SE2")+"' AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
		cQuery	+= "SE2.E2_CODRDA <> ' ' AND "
		cQuery	+= "SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA AND "
		cQuery	+= "( SE2.E2_BAIXA = ' ' OR SE2.E2_BAIXA > '"+DTOS(MV_PAR03)+"' ) AND "
		cQuery	+= "(SE2.E2_ANOBASE || SE2.E2_MESBASE) >= ' ' AND (SE2.E2_ANOBASE || SE2.E2_MESBASE) <= '"+STRZERO(YEAR(MV_PAR03),4)+STRZERO(MONTH(MV_PAR03),2)+"' AND "
		cQuery	+= "SE2.E2_ORIGEM = 'PLSMPAG' AND "
		// Desconsiderar estes tipos de titulos
		// MVABATIM   AB-|FB-|FC-|IR-|IN-|IS-|PI-|CF-|CS-|FU-|FE-
		// MVPROVIS   PR
		// MVPAGANT   PA
		// MV_CPNEG   NDF
		//	cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TX ','TXA','ISS','INS') AND "
		cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TXA') AND "
		cQuery	+= "SE2.D_E_L_E_T_ = ' ' AND "
		cQuery	+= "SA2.D_E_L_E_T_ = ' ' "
		//	cQuery	+= "ORDER BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
		
		
		// Nova query conforme instruções da Caberj - OPME
		cQuery	+= "UNION "
		
		cQuery	+= "SELECT SE2.R_E_C_N_O_ REGNUM, E2_FILIAL, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VALOR, E2_SALDO SALDO, "
		cQuery	+= "SE2.E2_VALOR+SE2.E2_ISS+SE2.E2_IRRF+SE2.E2_COFINS+SE2.E2_PIS+SE2.E2_CSLL+SE2.E2_INSS VALBRUT "
		cQuery	+= "FROM "+RetSqlName("SE2")+" SE2,"+RetSqlName("SF1")+" SF1,"+RetSqlName("SA2")+" SA2 WHERE "
		cQuery	+= "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
		cQuery	+= "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
		cQuery	+= "SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
		cQuery	+= "SF1.F1_SERIE = SE2.E2_PREFIXO AND "
		cQuery	+= "SF1.F1_DOC = SE2.E2_NUM AND "
		cQuery	+= "SF1.F1_FORNECE = SE2.E2_FORNECE AND "
		//	--OPME
		cQuery	+= "SE2.E2_NATUREZ = 'OPME' AND "
		cQuery	+= "SE2.E2_FORNECE = SA2.A2_COD AND "
		cQuery	+= "SE2.E2_LOJA = SA2.A2_LOJA AND "
		If cBanco=="ORACLE"
			cQuery	+= "SUBSTR(SE2.E2_EMISSAO, 1, 6) <= '"+STRZERO(YEAR(MV_PAR03),4)+STRZERO(MONTH(MV_PAR03),2)+"' AND "
		Else
			cQuery	+= "SUBSTRING(SE2.E2_EMISSAO, 1, 6) <= '"+STRZERO(YEAR(MV_PAR03),4)+STRZERO(MONTH(MV_PAR03),2)+"' AND "
		Endif
		cQuery	+= "( SE2.E2_BAIXA = ' ' OR SE2.E2_BAIXA > '"+DTOS(MV_PAR03)+"' ) AND "
		// Desconsiderar estes tipos de titulos
		// MVABATIM   AB-|FB-|FC-|IR-|IN-|IS-|PI-|CF-|CS-|FU-|FE-
		// MVPROVIS   PR
		// MVPAGANT   PA
		// MV_CPNEG   NDF
		//	cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TX ','TXA','ISS','INS') AND "
		cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TXA') AND "
		cQuery	+= "SE2.D_E_L_E_T_ = ' ' AND "
		cQuery	+= "SF1.D_E_L_E_T_ = ' ' AND "
		cQuery	+= "SA2.D_E_L_E_T_ = ' ' "
		//	cQuery	+= "ORDER BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
		
		// Nova query conforme instruções da Caberj - Reembolso
		cQuery	+= "UNION "
		
		cQuery	+= "SELECT SE2.R_E_C_N_O_ REGNUM, E2_FILIAL, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VALOR, E2_SALDO SALDO, "
		cQuery	+= "SE2.E2_VALOR+SE2.E2_ISS+SE2.E2_IRRF+SE2.E2_COFINS+SE2.E2_PIS+SE2.E2_CSLL+SE2.E2_INSS VALBRUT "
		cQuery	+= "FROM "+RetSqlName("SE2")+" SE2,"+RetSqlName("SE1")+" SE1 WHERE "
		cQuery	+= "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
		cQuery	+= "SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
		cQuery	+= "SE2.E2_PREFIXO = 'RLE' AND "
		cQuery	+= "SE1.E1_PREFIXO = SE2.E2_PREFIXO AND "
		cQuery	+= "SE1.E1_TIPO = 'NCC' AND "
		cQuery	+= "SE1.E1_NUM = SE2.E2_NUM AND "
		If cBanco=="ORACLE"
			cQuery	+= "SUBSTR(SE1.E1_EMISSAO,1,6) >= ' ' AND SUBSTR(SE1.E1_EMISSAO,1,6) <= '"+STRZERO(YEAR(MV_PAR03),4)+STRZERO(MONTH(MV_PAR03),2)+"' AND "
		Else
			cQuery	+= "SUBSTRING(SE1.E1_EMISSAO,1,6) >= ' ' AND SUBSTRING(SE1.E1_EMISSAO,1,6) <= '"+STRZERO(YEAR(MV_PAR03),4)+STRZERO(MONTH(MV_PAR03),2)+"' AND "
		Endif
		//	cQuery	+= "( SE2.E2_BAIXA = ' ' OR SE2.E2_BAIXA > '"+DTOS(MV_PAR03)+"' ) AND "
		// Desconsiderar estes tipos de titulos
		// MVABATIM   AB-|FB-|FC-|IR-|IN-|IS-|PI-|CF-|CS-|FU-|FE-
		// MVPROVIS   PR
		// MVPAGANT   PA
		// MV_CPNEG   NDF
		//	cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TX ','TXA','ISS','INS') AND "
		cQuery	+= "SE2.E2_TIPO NOT IN ('AB-','FB-','FC-','IR-','IN-','IS-','PI-','CF-','CS-','FU-','FE-','PR ','PA ','NDF','TXA') AND "
		cQuery	+= "SE1.D_E_L_E_T_ = ' ' AND "
		cQuery	+= "SE2.D_E_L_E_T_ = ' ' "
		//ORDER BY E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
		
		cQuery	+= "ORDER BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO "
		
		cAlias	:= "TRBPAS"
		cQuery	:= ChangeQuery(cQuery)
		If Select(cAlias) > 0
			TRBPAS->(dbCloseArea())
		EndIf
		
		nHandle := FCREATE("\QRYDIOP.SQL")
		If nHandle = -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - logquery " + Str(Ferror()) , 0, 0, {})	
		Else
			FWrite(nHandle, cQuery + CRLF)
			FClose(nHandle)
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.F.)

		If TRBPAS->(Eof())
			TRBPAS->(dbCloseArea())
			lPassivo	:= .F.
		Else
			// Se deve gerar o arquivo espeolho
			If MV_PAR15 == 1
				
				// criar arquivo texto vazio a partir do root path no servidor
				nHandle := FCREATE(cDir+"\TRBPAS.txt")
				If nHandle = -1

					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})	
					
				EndIf
				
			EndIf
		EndIf
		
		If lPassivo
			SA2->(dbSetOrder(1))
			
			TRBPAS->(dbGoTop())
			While TRBPAS->(!Eof())
				cForn	:= TRBPAS->(E2_FORNECE+E2_LOJA)
				While TRBPAS->(!Eof()) .and. cForn == TRBPAS->(E2_FORNECE+E2_LOJA)
					SE2->(dbGoTo(TRBPAS->REGNUM))
					If SA2->(dbSeek(xFilial("SA2")+TRBPAS->(E2_FORNECE+E2_LOJA), .F.))
						
						// Executa classificação padrão
						// 2- Eventos/ Sinistros a Liquidar - Contas 2111791 / 2111792 / 2112791 / 2112792
						If (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='02').OR. lDiold .and. Subs(SA2->A2_CONTA,1,7) $ '2111791/2111792/2112791/2112792'
							nCateg	:= 2
							// 3- Comercialização sobre Operações - Conta 2134
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='03') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,4) $ '2134'
							nCateg	:= 3
							// 4- Débitos com Operadoras - Conta 2135
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='04') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,4) $ '2135'
							nCateg	:= 4
							// 5- Outros Débitos de Operações com Planos - Contas 2131 / 2133 / 2138
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='05') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,4) $ '2131/2133/2138'
							nCateg	:= 5
							
							// 6 - Depósitos de Beneficiários - Contraprest/ Seguros Recebidos - Conta 218519310
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='06') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,9) $ '218519310'
							nCateg	:= 6
							
							// 7- Prestadores de Serv. de Assistência a Sáude - Subgrupo 214
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='07') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,3) $ '214'
							nCateg	:= 7
							
							// 8- Débitos com Aquisição de Carteira - Conta 2186
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='08') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,4) $ '2186'
							nCateg	:= 8
							// 10 - Eventos Sinistros a liquidar Sus
						ElseIf (SA2->(Fieldpos("A2_CLASDIO"))> 0 .AND. SA2->A2_CLASDIO=='09') .OR. lDiold .and. Subs(SA2->A2_CONTA,1,7) $ '2111902/21112902'
							nCateg	:= 10
							//11- Tributos e encargos
						ElseIf  SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"+"/"+"CID" //SE2->E2_TIPO $"INS/ISS/TX "
							nCateg	:= 11
						Else
							nCateg	:= 9
							If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
								PlGrvlog('Conta do Fornecedor '+SA2->A2_COD+'/'+SA2->A2_LOJA+' nao atendeu a classificacao do DIOPS. Verifique.', 'DIOPS-IDSLD-P')
							EndIf
						EndIf
						
						//Ponto de entrada para regra especifica do usuario na
						//classificacao do Passivo no DIOPS
						If lPLDIOP01
							nNewCat:= ExecBlock("PLDIOP01",.F.,.F.,{TRBPAS->REGNUM, TRBPAS->(E2_FORNECE+E2_LOJA), nCateg } )
							nCateg := IIf(nNewCat >= 2 .and. nNewCat <= 9, nNewCat, nCateg)
						Endif
						
						//Analisa data de vencimento do titulo em relacao a
						//competencia emitida para classificar na linha correta
						nData	:= ( MV_PAR03 - IIf(MV_PAR08==1, SE2->E2_VENCTO, SE2->E2_VENCREA) )
						If nData <= 0
							nVenc	:= 1		// Se ainda não venceu
							/*
							If nData >= -30 .and. nData <=-1
								nVenc:= 7
							ElseIf nData >= -60 .and. nData <=-31
								nVenc:= 8
							Endif
							*/
						ElseIf nData <= 30 .and. nData >= 1
							nVenc	:= 2		// Vencidos de 1 a 30 dias
						ElseIf nData <= 60 .and. nData >= 31
							nVenc	:= 3		// Vencidos de 31 a 60 dias
						ElseIf nData <= 90 .and. nData >= 61
							nVenc	:= 4		// Vencidos de 61 a 90 dias
						ElseIf nData <= 120 .and. nData >= 91
							nVenc	:= 5		// Vencidos de 91 a 120 dias
						ElseIf nData >= 121
							nVenc 	:= 6		// Vencidos a mais de 120 dias
						EndIf
						
						// COLOCAR TRATAMENTO PARA SALDO DO TITULO CFE RELATÓRIO
						
						nVlrDes		:= 0
						nVlrDesA	:= 0
						
						nVlrPAA		:= 0
						nVlrPA 		:= 0
						nVlrJd 		:= 0
						nVlrBx 		:= 0
						nVlrAberto	:= 0
						nVlrBxAnt	:= 0
						nVlrPAAnt	:= 0
						nVlrJdAnt	:= 0
						dDatBxAnt	:= cTod('')
						nDtBx		:= cTod('')
						nVlrbxPar	:= 0
						nVlrPAPar 	:= 0
						nVlrJdPar 	:= 0
						
						
						If SE5->( MsSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA) )
							
							While !SE5->( Eof() ) .and. SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA ==;
									SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
								
								// Ignora descontos, juros, cancelamentos, recebimentos e outros tipos...
								If SE5->E5_RECPAG == 'R' .or.;
										SE5->E5_SITUACA == 'C' .or. (SE5->E5_TIPODOC $ "D2, JR, J2, TL, MT, M2, CM, C2, TR, TE")
									//	SE5->E5_MOTBX == GetNewPar("MV_PLMOTBC","CAN") .or.;  EM 06/09/2009 ATENDER AO TITULO 2719 BAXADO POR CAN
									//(SE5->E5_TIPODOC $ "DC, D2, JR, J2, TL, MT, M2, CM, C2, TR, TE") EM 06/09/2009
									
									SE5->( dbSkip() )
									Loop
								Endif
								
								// Processa os estornos das baixas... se houverem.
								cQuery := "SELECT Sum(E5_VALOR) ESTORNO FROM "+RetSqlName("SE5")+" WHERE "
								cQuery += "E5_FILIAL='"+xFilial("SE5")+"' AND "
								cQuery += "E5_PREFIXO='"+SE5->E5_PREFIXO+"' AND "
								cQuery += "E5_NUMERO='"+SE5->E5_NUMERO+"' AND "
								cQuery += "E5_PARCELA='"+SE5->E5_PARCELA+"' AND "
								cQuery += "E5_TIPO='"+SE5->E5_TIPO+"' AND "
								cQuery += "E5_CLIFOR='"+SE5->E5_CLIFOR+"' AND "
								cQuery += "E5_LOJA='"+SE5->E5_LOJA+"' AND "
								cQuery += "E5_SEQ='"+SE5->E5_SEQ+"' AND "
								cQuery += "E5_TIPODOC='ES' AND "
								cQuery += "E5_DATA < '"+DtoS(dDataAte)+"' AND "
								cQuery += "D_E_L_E_T_<>'*'"
								
								dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),"EST",.T.,.F.)
								
								nVlrEst := EST->ESTORNO
								
								EST->( dbCloseArea() )
								
								// Filtra datas dos parametros...
								If !(dTos(SE5->E5_DATA) >=  dTos(dDataDe) .and. dTos(SE5->E5_DATA) <=  dTos(dDataAte))
									
									// Se a data da baixa for posterior a data final do relatorio, o titulo sera considerado como em aberto.
									If SE5->E5_DATA > dDataAte //.and. SE2->E2_EMISSAO <= dDataAte
										nVlrAberto += SE5->E5_VALOR
										nVlrAberto -= nVlrEst
									Endif
									
									
									//Jean - Criado novo trecho para permitir obter valores anteriores as datas
									// Se for PA, acumular na matriz neste ponto e descarregar depois...
									If SE5->E5_DATA < dDataDe
										If Alltrim(SE5->E5_TIPODOC) == 'CP' .and. Alltrim(SE5->E5_MOTBX) == 'CMP'
											nVlrPAAnt += SE5->E5_VALOR
											nVlrPAAnt -= nVlrEst // Diminui o valor do estorno se houver
											nVlrPA    += SE5->E5_VALOR
											//Somar valor desconto  parcial, caso ocorra...
										Elseif Alltrim(SE5->E5_TIPODOC) == 'DC'
											nVlrDesA += SE5->E5_VALOR
											nVlrDesA -= nVlrEst //' Diminui o valor do estorno se houve
											nVlrDes  += SE5->E5_VALOR
											// Desconto por motivo judicial..
										Elseif Alltrim(SE5->E5_MOTBX) == 'DPJ'
											nVlrJdAnt += SE5->E5_VALOR
											nVlrJdAnt -= nVlrEst //' Diminui o valor do estorno se houver
											nVlrJd    += SE5->E5_VALOR
											//Somar valor desconto  parcial, caso ocorra...
										Elseif Alltrim(SE5->E5_MOTBX) == 'DC'
											nVlrDesA += SE5->E5_VALOR
											nVlrDesA -= nVlrEst //' Diminui o valor do estorno se houve
											nVlrDes  += SE5->E5_VALOR
											//Somar valor baixado parcial, caso ocorra...
										Else
											nVlrBxAnt += SE5->E5_VALOR
											nVlrBxAnt -= nVlrEst
											dDatBxAnt := Iif(dDatBxAnt <= SE5->E5_DATA .And. SE5->E5_DATA <= dDataAte,SE5->E5_DATA,dDatBxAnt)
											nVlrBx    += SE5->E5_VALOR
										Endif
									Endif
									
									SE5->( dbSkip() )
									nVlrEst:=0
									Loop
									
								Endif
								
								// Se for PA, acumular na matriz neste ponto e descarregar depois...
								If Alltrim(SE5->E5_TIPODOC) == 'CP' .and. Alltrim(SE5->E5_MOTBX) == 'CMP'
									nVlrPA += SE5->E5_VALOR
									nVlrPA -= nVlrEst // Diminui o valor do estorno se houver
								Elseif Alltrim(SE5->E5_TIPODOC) == 'DC'
									nVlrDes += SE5->E5_VALOR
									nVlrDes -= nVlrEst //' Diminui o valor do estorno se houve
									// Desconto por motivo judicial..
								Elseif Alltrim(SE5->E5_MOTBX) == 'DPJ'
									nVlrJd += SE5->E5_VALOR
									nVlrJd -= nVlrEst // Diminui o valor do estorno se houver
								Else
									nVlrBx += SE5->E5_VALOR
									nVlrBx -= nVlrEst // Diminui o valor do estorno se houver
								Endif
								if (nVlrBx <> 0 .or. nVlrJd <> 0 .or. nVlrPA <> 0 ) .AND. ;
										((Alltrim(SE5->E5_TIPODOC) <> 'CP'  .or. Alltrim(SE5->E5_TIPODOC) <> 'DC')  .and.;
										Alltrim(SE5->E5_MOTBX) <> 'CMP' .and. ;
										Alltrim(SE5->E5_MOTBX)   <> 'BNF' .and. Alltrim(SE5->E5_MOTBX) <> 'DPJ')
									nDtBx := SE5->E5_DATA
									// FGravaTrb()
									nVlrBx := (nVlrBx + nVlrJd + nVlrPA + nVlrDes )
									if  (nVlrBx + SE2->E2_DECRESC) < se2->e2_valor
										nVlrPA := (nVlrBx - nVlrJd )
										nVlrBx := 0
										nVlrAberto := 0
									endif
								Endif
								SE5->( dbSkip() )
								nVlrEst:=0
							Enddo
							
						Else
							
							nVlrAberto += SE2->(E2_VALOR)
							
							
						Endif
						nSaldo := nVlrAberto
						
						//TRIBUTOS E ENCARGOS (VALOR DOS IMPOSTOS)
						
						
						nSaldo := TRBPAS->VALBRUT
						If nSaldo > 0
							aRetPassivo[nVenc,nCateg] += nSaldo
						EndIf
						
						
						// Se deve atualizar o arquivo
						If MV_PAR15 == 1 .and. nHandle > 0
							cStr := Str(TRBPAS->REGNUM,20,0)+';'+TRBPAS->E2_FILIAL+';'+TRBPAS->E2_VENCREA+';'+TRBPAS->E2_FORNECE+';'+TRBPAS->E2_LOJA+';'+TRBPAS->E2_PREFIXO+';'
							cStr += TRBPAS->E2_NUM+';'+TRBPAS->E2_PARCELA+';'+TRBPAS->E2_TIPO+';'+Str(TRBPAS->E2_VALOR,20,2)+';'+Str(nCateg,20,0)+';'+Str(nVenc,20,0)+';'+Str(nSaldo,20,2)
							FWrite(nHandle, cStr + CRLF)
						EndIf
						
					EndIf
					TRBPAS->(dbSkip())
				EndDo
			EndDo
			TRBPAS->(dbCloseArea())
			// Se optou por gerar o arquivo espelho
			If MV_PAR15 == 1 .and. nHandle > 0
				FClose(nHandle)
				//			TRBPS2->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	
	
	
	// ATIVO
	If lAtivo
		
		// Seleciona todos os titulos que poderiam estar abertos na data final da apuração da DIOPS
		If "ORACLE" $ AllTrim(TCGetDB())
			cQuery	:= "SELECT /*+ INDEX_ASC(SE1 "+RetSqlName('SE1')+"7)*/ SE1.R_E_C_N_O_ REGNUM, SE1.E1_FILIAL, SE1.E1_VENCREA, SE1.E1_CLIENTE, SE1.E1_LOJA,  "
		Else
			cQuery	:= "SELECT SE1.R_E_C_N_O_ REGNUM, SE1.E1_FILIAL, SE1.E1_VENCREA, SE1.E1_CLIENTE, SE1.E1_LOJA, "
		EndIf
		cQuery	+= "SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_ORIGEM, SE1.E1_VALOR FROM "+RetSqlName('SE1')+" SE1 WHERE "
		cQuery	+= "SE1.D_E_L_E_T_ <> '*' AND ( SE1.E1_SALDO > 0 OR SE1.E1_BAIXA >= '"+DTOS(MV_PAR02)+"' ) AND "
		// Filtro da emissao
		cQuery  += "SE1.E1_EMISSAO <= '"+ DTOS(MV_PAR03)+"' AND "
		// Se considera o vencimento nominal do titulo
		If MV_PAR08 == 1
			cQuery	+= "SE1.E1_VENCTO >= '"+  DTOS(MV_PAR09)+"' AND "
		Else
			cQuery	+= "SE1.E1_VENCREA >= '"+ DTOS(MV_PAR09)+"' AND "
		EndIf
		cQuery	+= "SE1.E1_FILIAL = '"+xFilial('SE1')+"' "
		cQuery	+= "ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
		
		cAlias	:= "TRBATV"
		cQuery	:= ChangeQuery(cQuery)
		If Select(cAlias) > 0
			TRBATV->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.F.)
		//cIndex	:= CriaTrab(NIL,.F.)
		//IndRegua(cAlias, cIndex, "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO", , , , .T. )
		
		If TRBATV->(Eof())
			TRBATV->(dbCloseArea())
			lAtivo	:= .F.
		Else
			If MV_PAR15 == 1
			
				// criar arquivo texto vazio a partir do root path no servidor
				nHandle := FCREATE(cDir+"\TRBATF.txt")
				
				If nHandle = -1
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})
				EndIf
				
			EndIf
			
		EndIf
		
		SA1->(dbSetOrder(1))
		BM1->(dbSetOrder(4))
		BI3->(dbSetOrder(1))
		
		If lAtivo
			TRBATV->(dbGoTop())
			While TRBATV->(!Eof())
				cForn	:= TRBATV->(E1_CLIENTE+E1_LOJA)
				If SA1->(dbSeek(xFilial("SA1")+cForn, .F.))
					
					While TRBATV->(!Eof()) .and. cForn == TRBATV->(E1_CLIENTE+E1_LOJA)
						
						SE1->(dbGoTo(TRBATV->REGNUM))
						cAdiant		:= IIF( (SE1->E1_TIPO $ MVRECANT+"/"+MVPAGANT+"/"+MV_CRNEG+"/"+MV_CPNEG), "1","0")
						
						// Nao considera titulos com emissao futura...
						If SE1->E1_EMISSAO > MV_PAR03
							TRBATV->(dbSkip())
							Loop
						Endif
						
						//Verifico se o titulo esta totalmente baixado, e  se a baixa
						//foi realizada antes da data de competencia do diops
						IF !Empty(SE1->E1_BAIXA) .and. (SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= MV_PAR03)
							TRBATV->(dbSkip())
							Loop
						EndIF
						
						
						// Busca o saldo do titulo na data da competencia da DIOPS
						// nSaldo	:= SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, 'R', SE1->E1_CLIENTE, 1, ,MV_PAR03,SE1->E1_LOJA,,Nil,1)
						// Chamada da funcao SaldoTiT() resultou problema de performance, modificado para execucao do conteudo da funcao na rotina
						// Function SaldoTit(cPrefixo,cNumero,cParcela,cTipo,cNatureza,cCart,cCliFor,nMoeda,dData,dDataBaixa,cLoja,cFilTit,nTxMoeda,nTipoData)
						cPrefixo	:= SE1->E1_PREFIXO
						cNumero		:= SE1->E1_NUM
						cParcela	:= SE1->E1_PARCELA
						cTipo		:= SE1->E1_TIPO
						cNatureza	:= SE1->E1_NATUREZ
						cCart		:= 'R'
						cCliFor		:= SE1->E1_CLIENTE
						nMoeda		:= 1
						dData       := dDataBase
						dDataBaixa	:= MV_PAR03
						cLoja		:= SE1->E1_LOJA
						// cFilTit		:=
						// nTxMoeda	:=
						nTipoData	:= 1
						nSaldo     := 0
						
						If nTipoData == 1
							cTipoData := "0"  // E5_DATA
						ElseIf nTipodata == 2
							cTipoData := "1"  // E5_DTDISPO
						Else
							cTipoData := "2"  // E5_DTDIGIT
						Endif
						
						
						If ExistProc( cProcedure, VerIDProc() ) .and. ( TcSrvType() <> "AS/400" )
							aResult := {}
							
							cAliasTit := "SE1"
							dbSelectArea("SE1")
							nSaldo    := SE1->E1_VALOR+SE1->E1_SDACRES-SE1->E1_SDDECRE
							nMoedaTit := SE1->E1_MOEDA
							cCliFor   := Iif(Empty(cCliFor),SE1->E1_CLIENTE,cCliFor)
							cLoja     := Iif(Empty(cLoja  ),SE1->E1_LOJA,cLoja)
							
							nMoeda    := ((nMoeda+1.00)-1.00)
							nMoedaTit := ((nMoedaTit+1.00)-1.00)
							
							aResult := TCSPEXEC( xProcedures(cProcedure),;
								cPrefixo,                cNumero,;
								cParcela,                cTipo,;
								cCliFor,                 DTOS(dData),;
								DTOS(dDataBaixa),        cLoja,;
								DTOS(dDataBase),         cFilAnt,;
								nSaldo,                  nMoedaTit,;
								cPaisLoc,                cTipoData,;
								cPCCBaixa,               cCart, cAdiant )
							
							nSaldo := aResult[1]
							// Zera o Saldo devido problema de arredondamento nos juros, ou seja, o valor dos juros que eh gravado com
							// 2 casas decimais, gera diferena na recomposicao do saldo no titulo
							// Exemplo: Titulo com valor de 24.450, com E1_PORCJUR de 0.13 e tres dias de atraso, grava em E5_JUROS o valor
							// de 95.36, sendo que o valor dos juros seria 95.355
							// Movimentacao no SE5:
							//	      Baixa	Juros	       Saldo
							//		 		            24.450,00
							//-------------------------------
							//		4.001,04	95,36 	20.544,32 3 dias apos vencto.
							//		2.100,95		      18.443,37 mesma data
							//		3.474,23		      14.969,14 mesma data
							//		6.000,00		       8.969,14 5 dias apos vencto
							//		5.060,00		       3.909,14 10 dias apos vencto
							//		3.919,29	10,16	        0,01 12 dias apos vencto
							If Empty(SE1->E1_SALDO) .And. Abs(nSaldo) <= 0.009
								nSaldo := 0
							EndIf
						Elseif ExistProc( cProcedure, VerIDProc() ) .and. ( TcSrvType() == "AS/400" )
							aResult := {}
							cxFilial := BuildStrFil("SE5")
							
							dbSelectArea("SE1")
							nSaldo    := SE1->E1_VALOR+SE1->E1_SDACRES-SE1->E1_SDDECRE
							nMoedaTit := SE1->E1_MOEDA
							
							nMoeda    := ((nMoeda+1.00)-1.00)
							nMoedaTit := ((nMoedaTit+1.00)-1.00)
							
							aResult := TCSPEXEC( xProcedures(cProcedure), cxFilial,;
								cPrefixo,                cNumero,;
								cParcela,                cTipo,;
								cNatureza,               cCart,;
								cCliFor,                 nMoeda,;
								DTOS(dData),             DTOS(dDataBaixa),;
								cLoja,                   DTOS(dDataBase),;
								cFilAnt,                 '',;
								nSaldo,                  nMoedaTit, cTipoData)
							
							nSaldo := aResult[1]
							// Zera o Saldo devido problema de arredondamento nos juros, ou seja, o valor dos juros que eh gravado com
							// 2 casas decimais, gera diferena na recomposicao do saldo no titulo
							// Exemplo: Titulo com valor de 24.450, com E1_PORCJUR de 0.13 e tres dias de atraso, grava em E5_JUROS o valor
							// de 95.36, sendo que o valor dos juros seria 95.355
							// Movimentacao no SE5:
							//	      Baixa	Juros	       Saldo
							//		 		            24.450,00
							//-------------------------------
							//		4.001,04	95,36 	20.544,32 3 dias apos vencto.
							//		2.100,95		      18.443,37 mesma data
							//		3.474,23		      14.969,14 mesma data
							//		6.000,00		       8.969,14 5 dias apos vencto
							//		5.060,00		       3.909,14 10 dias apos vencto
							//		3.919,29	10,16	        0,01 12 dias apos vencto
							If Empty(SE1->E1_SALDO) .And. Abs(nSaldo) <= 0.009
								nSaldo := 0
							Endif
						Else
							nSaldo	:= xSaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, 'R', SE1->E1_CLIENTE, 1, ,MV_PAR03,SE1->E1_LOJA,,Nil,1)
						Endif
						
						// Final da Funcao SaldoTIT()
						If nSaldo > 0
							aVlrAt	:= {}
							aVlrBM1	:= {}
							nVlrBM1	:= 0
							
							/*
							CLASSIFICACAO DAS CATEGORIAS CONFORME DIVISAO ABAIXO
							+-----------------------------------------------------------+-----------------------------------------------------------+
							|									Contraprestacao Pecuniaria/Premios a Receber                                        |
							|									Mensalidades/Faturas/Seguros a Receber												|
							+-----------------------------------------------------------+-----------------------------------------------------------+
							|Planos Individuais/Familiares Mensalidades (Pess. Fisica)	|	Planos Coletivos Faturas (Pessoa Juridica)				|
							+---------------------------+-------------------------------+-------------------------------+---------------------------+
							|2-Preco Pre-estabelecido	| 3-Preço Pos-estabelecido		|	4- Preco Pre-estabelecido	| 5- Preco Pos-estabelecido	|
							+-----------------------------------------------------------+-----------------------------------------------------------+
							
							+-----------------------------------------------------------------------------------------------------------------------+
							|6-Convenios a Receber / Outras                                        													|
							+-----------------------------------------------------------------------------------------------------------------------+
							+-----------------------------------------------------------------------------------------------------------------------+
							|7-Créditos de Operações de Administração de Benefícios		            												|
							+-----------------------------------------------------------------------------------------------------------------------+
							+-----------------------------------------------------------------------------------------------------------------------+
							|8-Participacao dos beneficiarios em eventos / sinistros                      											|
							+-----------------------------------------------------------------------------------------------------------------------+
							+-----------------------------------------------------------------------------------------------------------------------+
							|9-Creditos de Operadoras	                                        													|
							+-----------------------------------------------------------------------------------------------------------------------+
							+-----------------------------------------------------------------------------------------------------------------------+
							|10-Outros Creditos de Operacoes com Planos                                        										|
							+-----------------------------------------------------------------------------------------------------------------------+
							+-----------------------------------------------------------------------------------------------------------------------+
							|11-Outros Creditos Nao Relacionados com Planos                                        									|
							+-----------------------------------------------------------------------------------------------------------------------+
							*/
							
							// 11- Outros Creditos nao Relacionados com Planos
							// E1_ORIGEM sem preenchimento em compras de procedimentos pagas no ato via PLS
							If !Subs(TRBATV->E1_ORIGEM,1,3) $ 'PLS' .and. !Empty(TRBATV->E1_ORIGEM)
								nCateg	:= 11
								aAdd( aVlrAt, { nCateg, nSaldo } )
								nVlrBM1	+= nSaldo
								
							Else
								
								If BM1->(dbSeek(xFilial('BM1')+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO),.F.))
									
									cTitulo := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
									While !BM1->(Eof()) .and. BM1->(BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT) == cTitulo
										
										If !(BM1->BM1_TIPO == '1')
											BM1->(dbSkip())
											Loop
										EndIf
										nVlrBM1	+= BM1->BM1_VALOR
										
										// Mensalidade / Opcionais / Cartao / Taxa Inscricao
										If AllTrim(BM1->BM1_CODTIP) $ '101,103,107,110,118,102,133,146'
											
											BI3->(dbSeek(xFilial('BI3')+PLSINTPAD()+BM1->BM1_CODEVE))
											// Preco Pre-Estabelecido
											If BI3->BI3_MODPAG == '1'
												// 2- Preco Pre-estabelecido - Plano Familiar
												If !Empty(BM1->BM1_MATUSU) .and. Empty(BM1->(BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB))
													nCateg	:= 2
													// 4- Preco Pre-estabelecido - Plano Coletivo
												Else
													nCateg	:= 4
												EndIf
												// Preco Pos-Estabelecido
											Else
												// 3- Preco Pos-estabelecido - Plano Familiar
												If !Empty(BM1->BM1_MATUSU) .and. Empty(BM1->(BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB))
													nCateg	:= 3
													// 5- Preco Pos-estabelecido - Plano Coletivo
												Else
													nCateg	:= 5
												EndIf
											EndIf
											
											// 6- Convenios a Receber / Outras
										ElseIf AllTrim(BM1->BM1_CODTIP) $ ''
											nCateg	:= 6
											// 7- Taxa de administracao de Planos
										ElseIf AllTrim(BM1->BM1_CODTIP) $ cCod2
											nCateg	:= 7
											// 8- Participacao dos beneficiarios em eventos / sinistros
										ElseIf AllTrim(BM1->BM1_CODTIP) $ cCod1
											nCateg	:= 8
											// 10- Outros Creditos de Operacoes com Planos
										ElseIf AllTrim(BM1->BM1_CODTIP) $ '111,113,128,129,130,131,132,135,136,180'  .or. Subs(BM1->BM1_CODTIP,1,1) = '9'
											nCateg	:= 10
											
											// 9- Creditos de Operadoras
										ElseIf 1==2
											nCateg	:= 9
											// Se nao achou, classifica em 10- Outros Creditos de Operacoes com Planos
										Else
											nCateg	:= 10
											If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
												cLog	:= 'Cliente '+TRBATV->E1_CLIENTE+'/'+TRBATV->E1_LOJA+'- Composicao do Titulo'+TRBATV->E1_PREFIXO+'-'
												cLog	+= TRBATV->E1_NUM+'-'+TRBATV->E1_PARCELA+'-'+TRBATV->E1_TIPO+' com erro na classificacao. Verifique.'
												PlGrvlog(cLog, 'DIOPS-IDSLD-A')
											EndIf
										EndIf
										
										nPos := Ascan( aVlrAt, { |x| x[1] == nCateg } )
										If nPos > 0
											aVlrAt[nPos,2] += BM1->BM1_VALOR
										Else
											aAdd(aVlrAt, { nCateg, BM1->BM1_VALOR } )
										EndIf
										
										BM1->(dbSkip())
									EndDo
									
								Else
									nCateg	:= 10
									If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
										cLog	:= 'Cliente '+TRBATV->E1_CLIENTE+'/'+TRBATV->E1_LOJA+'- Composicao do Titulo'+TRBATV->E1_PREFIXO+'-'
										cLog	+= TRBATV->E1_NUM+'-'+TRBATV->E1_PARCELA+'-'+TRBATV->E1_TIPO+' nao encontrado. Verifique.'
										PlGrvlog(cLog, 'DIOPS-IDSLD-A')
									EndIf
									aAdd( aVlrAt, { nCateg, nSaldo } )
									nVlrBM1	+= nSaldo
									
								EndIf
								
							EndIf
							
							//Ponto de entrada para regra especifica do usuario na
							//classificacao do Ativo no DIOPS
							If lPLDIOP02

								aVlrAt := ExecBlock("PLDIOP02",.F.,.F.,{TRBATV->REGNUM, TRBATV->(E1_CLIENTE+E1_LOJA), nCateg, aVlrAt } )

								If !Valtype('aVlrAt') == 'A'
									
									FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01','Retorno invalido no ponto de entrada PLDIOP02, causando erro no valor do DIOPS.' , 0, 0, {})
									
									aVlrAt	:= { 11, nSaldo }

									If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
										cLog	:= 'Cliente '+TRBATV->E1_CLIENTE+'/'+TRBATV->E1_LOJA+'- Titulo'+TRBATV->E1_PREFIXO+'-'
										cLog	+= TRBATV->E1_NUM+'-'+TRBATV->E1_PARCELA+'-'+TRBATV->E1_TIPO+' - Retorno Invalido P.E. PLDIOP02. Verifique.'
										PlGrvlog(cLog, 'DIOPS-IDSLD-A')
									EndIf

								Else
									For nVez:= 1 to Len(aVlrAt)
										If aVlrAt[nVez,1] < 2 .or. aVlrAt[nVez,1] > 11
											aVlrAt[nVez,1] := 11
											If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
												cLog	:= 'Cliente '+TRBATV->E1_CLIENTE+'/'+TRBATV->E1_LOJA+'- Titulo'+TRBATV->E1_PREFIXO+'-'
												cLog	+= TRBATV->E1_NUM+'-'+TRBATV->E1_PARCELA+'-'+TRBATV->E1_TIPO+' - Retorno Invalido P.E. PLDIOP02. Verifique.'
												PlGrvlog(cLog, 'DIOPS-IDSLD-A')
											EndIf
										EndIf
									Next
								EndIf
							Endif
							
							//Analisa data de vencimento do titulo em relacao a
							//competencia emitida para classificar na linha correta
							nData	:= ( MV_PAR03 - IIf(MV_PAR08==1, SE1->E1_VENCTO, SE1->E1_VENCREA) )
							If nData <= 0
								nVenc	:= 1		// Se ainda não venceu
							ElseIf nData <= 30 .and. nData >= 1
								nVenc	:= 2		// Vencidos de 1 a 30 dias
							ElseIf nData <= 60 .and. nData >= 31
								nVenc	:= 3		// Vencidos de 31 a 60 dias
							ElseIf nData <= 90 .and. nData >= 61
								nVenc	:= 4		// Vencidos de 61 a 90 dias
							ElseIf nData >= 91.and. ndata <= 120
								nVenc	:= 6		// Vencidos de 91 a 120  dias
							ElseIf nData >= 121.and. nData <= 365
								nVenc	:= 7		// Vencidos a 121 a 365 dias
							ElseIf nData >= 365//.and. nData <= 365
								nVenc   := 5
								
							EndIf
							
							For nVez := 1 to Len(aVlrAt)
								aRetAtivo[ nVenc, aVlrAt[nVez,1] ] += ( ( aVlrAt[nVez,2] / nVlrBM1 ) * nSaldo )
							Next
							
						EndIf
						
						// Se deve atualizar o arquivo
						If MV_PAR15 == 1 .and. nHandle > 0
							cStr := Str(TRBATV->REGNUM,20,0)+';'+TRBATV->E1_FILIAL+';'+TRBATV->E1_VENCREA+';'+TRBATV->E1_CLIENTE+';'+TRBATV->E1_LOJA+';'+TRBATV->E1_PREFIXO+';'
							cStr += TRBATV->E1_NUM+';'+TRBATV->E1_PARCELA+';'+TRBATV->E1_TIPO+';'+Str(TRBATV->E1_VALOR,20,2)+';'+Str(nCateg,20,0)+';'+Str(nVenc,20,0)+';'+Str(nSaldo,20,2)
							FWrite(nHandle, cStr + CRLF)
						EndIf
						
						TRBATV->(dbSkip())
					EndDo
					
				Else
					If  PLSALIASEX("BB1") .and. SIX->(dbSeek("BB11",.F.))
						PlGrvlog('Codigo do cliente '+TRBATV->E1_CLIENTE+'/'+TRBATV->E1_LOJA+' nao encontrado. Verifique.', 'DIOPS-IDSLD-A')
					EndIf
					
					TRBATV->(dbSkip())
				EndIf
			EndDo
			TRBATV->(dbCloseArea())
			
			// Se optou por gerar o arquivo espelho
			If MV_PAR15 == 1 .and. nHandle > 0
				FClose(nHandle)
			EndIf
			
		EndIf
	EndIf
	
	// ponto de entrada para manipular dados do Saldo de contas para geração do DIOPS
	if existBlock("PLSIDSALDO")
		aRet := execBlock("PLSIDSALDO", .f., .f., {aRetPassivo, aRetAtivo})
		aRetPassivo := aRet[1]
		aRetAtivo   := aRet[2]
	endIf
Return({aRetPassivo,aRetAtivo})

/*/{Protheus.doc} PLSSolv
Retorna Margem de Solvencia DIOPS
@type function
@author TOTVS
@since 03.06.09
@version 1.0
/*/
Function PLSSolv(cCodInt,dDatsld)
	Local nFor 		:= 0
	Local aCPLPre 	:= {"311111","311121","311181","311191","311311","311321","311381","311391","311411","311421",;
		"311481","311491","311511","311521","311531","311541","311581","311591","311611","311621",;
		"311631","311641","311681","311691","311711","311721","311731","311781","311791","311811",;
		"311821","311831","311881","311891","311911","311921","311931","311951","311961","311971",;
		"311991"}
	Local aCPLPos 	:= {"311112","311122","311182","311192","311312","311322","311382","311392","311412","311422",;
		"311482","311492","311512","311522","311532","311542","311582","311592","311612","311622",;
		"311632","311642","311682","311692","311712","311722","311732","311782","311792","311812",;
		"311822","311832","311882","311892","311912","311922","311932","311952","311962","311972",;
		"311992"}
	Local aEILPre	:= {"411111","411121","411131","411141","411151","411161","411171","411181","411191","411211",;
		"411221","411231","411261","411271","411281","411291","411311","411361","411371","411381",;
		"411391","411411","411461","411471","411481","411491","411511","411521","411531","411541",;
		"411551","411561","411571","411581","411591","411611","411621","411631","411661","411671",;
		"411681","411691","411711","411761","411771","411781","411791","411811","411861","411871",;
		"411881","411891","412111","412112","412121","412131","412141","412151","412161","412171",;
		"412181","412191","412211","412221","412231","412261","412271","412281","412291","412311",;
		"412321","412331","412341","412351","412361","412371","412381","412391","412411","412421",;
		"412431","412461","412471","412481","412491","412511","412521","412531","412541","412551",;
		"412561","412571","412581","412591","412611","412621","412631","412661","412671","412681",;
		"412691","412711","412721","412731","412741","412751","412761","412771","412781","412791",;
		"412811","412821","412831","412861","412871","412881","412891","413111","413171","413181",;
		"413191","413211","413271","413281","413291","413811","413891","413911","413991"}
	Local aEILPos	:= {"411112","411122","411132","411142","411152","411162","411172","411182","411192","411212",;
		"411222","411232","411262","411272","411282","411292","411312","411362","411372","411382",;
		"411392","411412","411462","411472","411482","411492","411512","411522","411532","411542",;
		"411552","411562","411572","411582","411592","411612","411622","411632","411662","411672",;
		"411682","411692","411712","411762","411772","411782","411792","411812","411862","411872",;
		"411882","411892","412112","412112","412122","412132","412142","412152","412162","412172",;
		"412182","412192","412212","412222","412232","412262","412272","412282","412292","412312",;
		"412322","412332","412342","412352","412362","412372","412382","412392","412412","412422",;
		"412432","412462","412472","412482","412492","412512","412522","412532","412542","412552",;
		"412562","412572","412582","412592","412612","412622","412632","412662","412672","412682",;
		"412692","412712","412722","412732","412742","412752","412762","412772","412782","412792",;
		"412812","412822","412832","412862","412872","412882","412892","413112","413172","413182",;
		"413192","413212","413272","413282","413292","413812","413892","413912","413992"}
	Local nSoma 	:= 0
	DEFAULT dDatsld	:= dDataBase
	DEFAULT cCodInt := ""
	
	For nFor := 1 to Len(aCPLPre)
		nSoma += SaldoConta(aCPLPre[nFor],dDatsld,"01")
	Next
	aCPLPre := nSoma
	
	nSoma := 0
	For nFor := 1 to Len(aCPLPos)
		nSoma += SaldoConta(aCPLPos[nFor],dDatsld,"01")
	Next
	aCPLPos := nSoma
	
	nSoma := 0
	For nFor := 1 to Len(aEILPre)
		nSoma += SaldoConta(aEILPre[nFor],dDatsld,"01")
	Next
	aEILPre := nSoma
	
	nSoma := 0
	For nFor := 1 to Len(aEILPos)
		nSoma += SaldoConta(aEILPos[nFor],dDatsld,"01")
	Next
	aEILPos := nSoma
	
Return({aCPLPre,aCPLPos,aEILPre,aEILPos})

/*/{Protheus.doc} PLSTrbDiop
Retorna Alias de trabalho DIOPS
@type function
@author TOTVS
@since 03.06.09
@version 1.0
/*/
Function PLSTrbDiop(cTipo,cCodInt)
	Local cSQL 		:= ""
	Local aStru		:= {}
	Local cArqTemp	:= ""
	Local oTempTRB
	DEFAULT cTipo	:= ""
	DEFAULT cCodInt := ""
	
	If cTipo = "1"
		cSQL := "SELECT SUM(B07_VLRPAR) VLRPAR FROM "+RetSQLName("B07")+" "
	Else
		cSQL := "SELECT B07_NUMDOC NUMDOC, B07_VLRPAR VLRPAR FROM "+RetSQLName("B07")+" "
	EndIf
	cSQL += "WHERE B07_FILIAL = '"+xFilial("B07")+"' AND "
	cSQL += "B07_CODINT = '"+cCodInt+"' AND "
	cSQL += "B07_TIPO = '3' AND D_E_L_E_T_ = ' '"
	
	cSQL := ChangeQuery(cSQL)
	
	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
	
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	
	// Caso a query não retorne valor preencho as tags com valor DEFAULT
	If TRB->(Eof())  // .And. cTipo == "2"
		
		TRB->(dbCloseArea())
		
		aadd(aStru,{"CHAVE" ,"C",001,0})
		aadd(aStru,{"NUMDOC","C",014,0})
		aadd(aStru,{"VLRPAR","N",013,0})
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempTRB := FWTemporaryTable():New( "TRB" )
		oTempTRB:SetFields( aStru )
		oTempTRB:AddIndex( "INDTRB",{ "CHAVE" } )
		
		if( select( "TRB" ) > 0 )
			TRB->( dbCloseArea() )
		endIf
		
		oTempTRB:Create()

		dbSelectArea("TRB")
		TRB->( dbSetorder( 1 ) )

		TRB->(RecLock("TRB",.T.))
		TRB->NUMDOC := "00000000000000"
		TRB->VLRPAR := 0
		TRB->(MsUnlock())
		
	EndIF
	
Return

/*/{Protheus.doc} MaskDiops
Retorna o Valor com a mascara definida pela ANS
@type function
@author TOTVS
@since 03.06.09
@version 1.0
/*/
Function MaskDiops(cVlr)
	Local cVlrInt	:= ""
	Local cVlrDec	:= ""
	Local lNegat    := .F.
	DEFAULT cVlr 	:= 0
	
	cVlr 	:= AllTrim(cVlr)
	//cVlr    := Val(cVlr)
	
	If Val(cVlr) < 0
		cVlr:=Alltrim(Str(Val(cVlr)*(-1)))
		lNegat := .T.
	Endif
	
	cVlrInt := AllTrim(Str(Int(Val(cVlr))))
	
	
	If cVlrInt == cVlr
		cVlr += ".0"
	Else
		cVlrDec := Substr(cVlr,Len(cVlrInt)+2,2)
		If SubStr(cVlrDec,2,1) == "0"
			cVlr := cVlrInt +"."+ Substr(cVlrDec,1,1)
		Else
			cVlr := cVlrInt +"."+ cVlrDec
		EndIf
	EndIf
	
	If lNegat
		cVlr:= Val(cVlr)
		cVlr:= cVlr*(-1)
		cVlr:= Alltrim(Str(cVlr))
	Endif
Return(cVlr)

/*/{Protheus.doc} PLGRVLOG
Grava log contabil
@type function
@author TOTVS
@since 28/01/10
@version 1.0
/*/
Function PlGrvlog(cMsg, cTpLog , nTp)
local cLog      := '' 
local cLog1     := ''

default cMsg	:= ''
default cTpLog	:= ''
default nTp     := 1

if ! empty(cMsg) .and. ! empty(cTpLog)

    cLog	:= Subs(cTpLog+'|'+cMsg,001,254)
    cLog1	:= Subs(cTpLog+'|'+cMsg,255,254)
    
    //nao processados    
    if nTp == 1

        BB1->( recLock('BB1',.T.) )
            BB1->BB1_FILIAL	:= BB1->( xFilial('BB1') )
            BB1->BB1_DATA	:= Date()
            BB1->BB1_HORA	:= Subs(AllTrim(Time()),1,8)
            BB1->BB1_LOG	:= cLog
            BB1->BB1_LOG1	:= cLog1
        BB1->( msUnlock() )

    else

        BAD->( recLock('BAD',.T.) )
            BAD->BAD_FILIAL	:= BAD->( xFilial('BB1') )
            BAD->BAD_DATA	:= Date()
            BAD->BAD_HORA	:= Subs(AllTrim(Time()),1,8)
            BAD->BAD_LOG	:= cLog
            BAD->BAD_LOG1	:= cLog1
        BAD->( msUnlock() )

    endIf

endIf
	
Return

/*/{Protheus.doc} PLGRVLGB
Grava log contabil
@type function
@author TOTVS
@since 13/06/11
@version 1.0
/*/
Function PlGrvlgB(cMsg,cTpLog)
	Local cLog, cLog1
	Default cMsg	:= ''
	Default cTpLog	:= ''

	If !Empty(cMsg) .and. !Empty(cTpLog)

		cLog	:= Subs(cTpLog+'|'+cMsg,001,254)
		cLog1	:= Subs(cTpLog+'|'+cMsg,255,254)
		RecLock('BAD',.T.)
		BAD->BAD_FILIAL	:= xFilial('BAD')
		BAD->BAD_DATA	:= Date()
		BAD->BAD_HORA	:= Subs(AllTrim(Time()),1,8)
		BAD->BAD_LOG	:= cLog
		BAD->BAD_LOG1	:= cLog1
		msUnlock()
	EndIf
	
Return

/*/{Protheus.doc} PLRELRDA
Retorna rda por tipo (BAU_TIPRE)
@type function
@author TOTVS
@since 20/02/10
@version 1.0
/*/
Function PLRDATP()
	LOCAL cSql	:= ""
	LOCAL cTpPre:= GetNewPar("MV_PLSTPPR","HOS")
	LOCAL aRet	:= {}

	// Pega as especialidades do corpo clinico
	cSql := " SELECT BAU_CODIGO,BAU_CPFCGC,BAU_NOME,BAU_CNES,BAU_CODBB0, BAU_CODOPE"
	cSql += "   FROM "+BAU->( RetSQLName("BAU") )
	cSql += "  WHERE BAU_FILIAL = '"+xFilial("BAU")+"' "
	cSql += "    AND BAU_CODBLO = '"+Space( TamSx3("BAU_CODBLO")[1] )+"' "
	cSql += "    AND BAU_TIPPRE IN('"+cTpPre+"') "
	cSql += "	 AND D_E_L_E_T_ = ' ' "

	PLSQuery(cSql,"TRBBAU")

	// Monta matriz de retorno
	While !TRBBAU->( Eof() )
		AaDd( aRet,{TRBBAU->BAU_CODIGO,TRBBAU->BAU_NOME,TRBBAU->BAU_CPFCGC,TRBBAU->BAU_CNES,TRBBAU->BAU_CODBB0,Iif( Empty(TRBBAU->BAU_CODOPE),PlsIntPad(),TRBBAU->BAU_CODOPE) } )
		TRBBAU->( DbSkip() )
	EndDo
	TRBBAU->( DbCloseArea() )

Return(aRet)

/*/{Protheus.doc} PLSCARBD6
Carrega dados do bd6
@type function
@author TOTVS
@since 14.03.2010
@version 1.0
/*/
Function PLSCARBD6(cNumPeg)
	LOCAL lFindBD7	:= .F.
	LOCAL aMatBd6 	:= {}
	LOCAL aUnMed  	:= PLSXBKC()

	// Carrega dados do bd6
	BD7->( DbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
	BD6->( DbSetOrder(6) ) //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO
	BD6->( MsSeek(xFilial("BD6")+cNumPeg+"2") )

	While !BD6->( Eof() ) .And. xFilial("BD6")+cNumPeg+"2" == xFilial("BD6")+BD6->( BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV )

		// Procura participacao disponiviel
		lFindBD7 := .F.
		BD7->( MsSeek( xFilial("BD7")+cNumPeg+"2"+BD6->BD6_SEQUEN ) )

		While !BD7->( Eof() ) .And. xFilial("BD7")+cNumPeg+"2"+BD7->BD7_SEQUEN == xFilial("BD6")+cNumPeg+"2"+BD6->BD6_SEQUEN
			
			If ( Empty(BD7->BD7_CODTPA) .Or. ( BD7->(FieldPos("BD7_SALDO")) > 0 .And. BD7->BD7_SALDO > 0) ) .And. Ascan( aUnMed,{ |x| AllTrim(x[2]) == AllTrim(BD7->BD7_CODUNM) } ) > 0
				lFindBD7 := .T.
			exit
			EndIf
			
			BD7->( DbSkip() )
		EndDo
	
		// Se existir participacao
		If lFindBD7
	
			AaDd(aMatBd6,{"",BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,;
				BD6->BD6_ORIMOV,BD6->BD6_PROCCI,BD6->( Recno() ),BD6->BD6_DENREG,;
				BD6->BD6_FADENT,BD6->BD6_DATPRO })
			
		EndIf
		
		BD6->( DbSkip() )
	EndDo

Return aMatBd6

/*/{Protheus.doc} PLSXBKC
Carga inicial de dados
@type function
@author TOTVS
@since 08.11.2007
@version 1.0
/*/
Function PLSXBKC()
LOCAL nFor
LOCAL nAux
LOCAL aUnidades := {}
LOCAL aLista    := {}
// Quando for importacao Xml, carrega tambem, Taxas e Diarias
If IsInCallStack("PLSA973")
	aUnidades := { {"AUX","AUR"},{"HM ","HMR","PPM","RCC","CIR"},{"PA ","PAP","PAR"},{"DOP,CRR,INC"},{"VDI","VTX","COP"} }
Else
	aUnidades := { {"AUX","AUR"},{"HM ","HMR","PPM","RCC","CIR"},{"PA ","PAP","PAR"},{"DOP,CRR,INC"} }
EndIf
// For
BKC->(DbSetOrder(1)) //BKC_FILIAL+BKC_CODIGO+BKC_CODOPE+BKC_CODPAR
For nFor := 1 To Len(aUnidades)
	For nAux := 1 To Len(aUnidades[nFor])
		If BKC->(DbSeek(xFilial("BKC")+aUnidades[nFor,nAux]+PLSINTPAD()))
			While ! BKC->(Eof()) .And. BKC->(BKC_FILIAL+BKC_CODIGO+BKC_CODOPE) == xFilial("BKC")+aUnidades[nFor,nAux]+PLSINTPAD()
				AaDd(aLista,{ AllTrim(BKC->BKC_CODIGO)+AllTrim(BKC->BKC_CODPAR),AllTrim(BKC->BKC_CODIGO) } )
				BKC->(DbSkip())
			Enddo
		Endif
	Next
Next

Return(aLista)

/*/{Protheus.doc} PLSNEGCOM
Exclui composicao do procedimento (posibilita negar parte da composicao do procedimento)
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSNEGCOM(cSequen,cCodPad,cCodPro,cStatus,dDatPro,nOpc,cChave,lVisItens,cCodRda,cCodEsp,cCodLocal,cMatrUs,cAlias,lTela,lBD7)
	LOCAL nPos,nPos2	:= 0
	LOCAL nY			:= 0
	LOCAL nI			:= 0
	LOCAL bString		:= ""
	LOCAL cCodpla       := ""
	LOCAL cTipPre       := ""
	LOCAL aComEve		:= {}
	LOCAL aVetTab 		:= {}
	LOCAL aMatCol		:= {}
	LOCAL aMatLin  		:= {}
	LOCAL aRet			:= {}
	LOCAL oGEN			:= NIL
	DEFAULT nOpc		:= K_Incluir
	DEFAULT cChave		:= ""
	DEFAULT lVisItens	:= .F.// Somente Visual
	DEFAULT cCodRda     := ""
	DEFAULT cCodEsp     := ""
	DEFAULT cCodLocal   := ""
	DEFAULT cMatrUs   	:= ""
	DEFAULT cAlias		:= ""
	DEFAULT lTela		:= .T.
	DEFAULT lBD7		:= .F.
	// Colunas
	AaDd(aMatCol,{STR0068,'@!',80})//"Participação"
	AaDd(aMatCol,{STR0065,'@!',30})//'Unidade'
	AaDd(aMatCol,{STR0066,'@!',40})//"Descrição"
	// Verifica se o procedimento foi autorizado
	If cStatus == '0'
		lVisItens := .T.
	EndIf
	// Devolve a composicao
	aComEve	:= PLSRETCP( cMatrUs,cCodRda,cCodPad,cCodPro,dDatPro,Subs(cMatrUs,1,4),cCodLocal,cCodEsp)
	// Verifica se tem composicao
	If Len(aComEve) == 0 .And. lTela
		Aviso( 	STR0063,;//"Procedimento"
		STR0064,;//"Não é possivel mostrar a composição do procedimento informado."
		{ "Ok" }, 2 )
	Else
		// Monta matriz de linhas conforme as colunas
		For nY:= 1 To Len(aComEve)
			bString := "AaDd(aMatLin,{"
			bString += "'" + AllTrim(Posicione("BWT",1,xFilial("BWT") + Subs(cMatrUs,1,4) + aComEve[nY,16],"BWT_CODEDI")) + " - " + AllTrim(BWT->BWT_DESCRI) + "',"
			
			For nI:=1 To Len(aMatCol)
				
				Do Case
				Case ValType(aComEve[nY,nI])=='N'
					bString += "'" + AllTrim( Str(aComEve[nY,nI]) ) + "',"
				Case ValType(aComEve[nY,nI])=='D'
					bString += "'" + DToS(aComEve[nY,nI]) + "',"
				OtherWise
					bString += "'" + OemToAnsi( aComEve[nY,nI] ) + "',"
				EndCase
				// Descricao apos coluna selecionada
				If nI == 1
					bString += "'" + OemToAnsi( Posicione("BD3",1,xFilial("BD3")+aComEve[nY,nI],"BD3_DESCRI") ) + "',"
					nI++
				EndIf
			Next
			bString := "{||" + bString + ".F.}) }"
			Eval( &bString )
			// Seleciona os itens marcados anteriormente
			If Len(__aMatCom) > 0
				If (nPos := Ascan(__aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro}) ) > 0
					
					If (nPos2 := Ascan( __aMatCom[nPos,2],{|x| x[2] + AllTrim( Left( x[1], At('-',x[1]) -1) ) == aMatLin[Len(aMatLin),2] + AllTrim(Left(aMatLin[Len(aMatLin),1],At('-',aMatLin[Len(aMatLin),1])-1)) } ) ) > 0
						aMatLin[ Len(aMatLin),Len( aMatLin[Len(aMatLin)] ) ] := __aMatCom[nPos,2,nPos2,Len(__aMatCom[nPos,2,nPos2])]
					EndIf
				EndIf
			ElseIf !Empty(cAlias) .And. (cAlias)->( FieldPos(cAlias+"_COMPAR") ) > 0 .And. Type(cAlias+"_COMPAR") <> "U"
				
				If !Empty( M->&(cAlias+"_COMPAR") )
					oGEN := PLSCONTR():New()
					aRet := oGEN:Split(',', M->&( cAlias+"_COMPAR" ) )
					oGEN:Destroy()
					
					If Ascan( aRet,{|x| StrTran(x,'-','') == aMatLin[Len(aMatLin),2] + AllTrim(Left(aMatLin[Len(aMatLin),1],At('-',aMatLin[Len(aMatLin),1])-1)) } ) == 0
						aMatLin[ Len(aMatLin),Len( aMatLin[Len(aMatLin)] ) ] := .T.
					EndIf
					
				EndIf
			EndIf
		Next
	EndIf
	// Mostra a composicao
	If (!Empty(cChave) .And.  nOpc != K_Incluir) .Or. ( lBD7 .And. !Empty(cChave) )
		
		BD7->( DbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
		If BD7->( MsSeek( cChave ) )
			
			aMatLin := {}
			
			While !BD7->( Eof() ) .And. cChave == BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN)
				AaDd(aMatLin,{BD7->BD7_CODTPA + " - " + OemToAnsi( AllTrim(Posicione("BWT",1,xFilial("BWT")+ Subs(cMatrUs,1,4) + BD7->BD7_CODTPA,"BWT_DESCRI") ) ) ,BD7->BD7_CODUNM,OemToAnsi( AllTrim(Posicione("BD3",1,xFilial("BD3")+BD7->BD7_CODUNM,"BD3_DESCRI")) ), (BD7->BD7_BLOPAG == '1') })
				BD7->( DbSkip() )
			EndDo
		Else
			If ( nPos := Ascan(__aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro} ) ) > 0
				
				aMatLin := {}
				
				For nI:=1 To Len(__aMatCom[nPos,2])
					If !__aMatCom[nPos,2,nI,Len(__aMatCom[nPos,2,nI])]
						AaDd(aMatLin,{__aMatCom[nPos,2,nI,1],__aMatCom[nPos,2,nI,2],__aMatCom[nPos,2,nI,3],.F.})
					EndIf
				Next
			EndIf
		EndIf
		
	EndIf
	// Monta tela
	If Len(aMatLin) > 0
		// Monta tela e pega o retorno da composicao
		If lTela
			PLSSELOPT(STR0061,STR0062,aMatLin,aMatCol,nOpc,.T.,NIL,lVisItens) //"Composição do procedimento" //"Marca e Desmarca todos"
		EndIf
		// Monta matriz para envio da composicao
		If ( nPos := Ascan(__aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro} ) ) == 0
			AaDd(__aMatCom,{ cSequen+cCodPad+cCodPro, aMatLin } )
		Else
			__aMatCom[nPos,2] := aMatLin
		EndIf
	EndIf
	// Se foi informado o alias de gravacao e o campo existe grava a composicao
	If !Empty(cAlias) .And. (cAlias)->( FieldPos(cAlias+"_COMPAR") ) > 0 .And. Type(cAlias+"_COMPAR") <> "U"
		// Monta composicao autorizada
		cComPar := ""
		For nI:=1 To Len(aMatLin)
			If !aMatLin[nI,5]
				cComPar += aMatLin[nI,2] + "-" + AllTrim(Left(aMatLin[nI,1],At('-',aMatLin[nI,1])-1))+","
			EndIf
		Next
		// alimenta o M para gravacao
		M->&(cAlias+"_COMPAR") := Left(cComPar,Len(cComPar)-1)
	EndIf
Return( __aMatCom )

/*/{Protheus.doc} PLSSELOPT
Mostra linhas com possibilidade de selecionar itens
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSSELOPT(cTexTit,cTexChk,aMatLin,aMatCol,nOpc,lChkQt,lMosMt,lVisItens,oDlgTB,nLinI,nColI,nLinF,nColF)
	LOCAL nI		 := 0
	LOCAL nOpca      := 0
	LOCAL nPosChk	 := 0
	LOCAL cTipoPes	 := ""
	LOCAL cChave	 := space(100)
	LOCAL bCol		 := ""
	LOCAL bOK        := {|| lOk :=.t.,oDlgTB:end() }
	LOCAL bCancel    := {|| lOk :=.f.,oDlgTB:end() }
	LOCAL lOk		 := .f.
	LOCAL lCheck	 := .f.
	LOCAL lPes		 := .f.
	LOCAL lDlg		 := .f.
	LOCAL aPesOrd  	 := {}
	LOCAL oPes		 := nil
	LOCAL oCheck	 := nil
	LOCAL oObjGrid	 := nil
	LOCAL nTam		 := 20
	DEFAULT oDlgTB	 := nil
	DEFAULT nLinI	 := 0
	DEFAULT nColI	 := 0
	DEFAULT nLinF	 := 0
	DEFAULT nColF	 := 0
	DEFAULT cTexTit  := STR0059	//"Titulo"
	DEFAULT cTexChk	 := STR0060	//"Marca e Desmarca todos"
	DEFAULT lMosMt	 := .f.
	DEFAULT lChkQt	 := .f.
	DEFAULT lVisItens:= .f. 	//Somente Visual
	// para nao abrir a tela varias vezes quando for k_incluir
	inclui := .f.
	
	// verifica se foi definido na matriz de coluna itens para pesquisa
	if len(aMatCol[1])>=4
		for nI:=1 to len(aMatCol)
			if aMatCol[nI,4]
				aadd(aPesOrd,aMatCol[nI,1])
				lPes := .t.
			endIf
		next
	endIf
	// Somente Visualizar os Itens
	if lVisItens
		lMosMt := .f.
	endIf
	// Inicia controle a ultima posicao sempre deve ser um valor logico
	if len(aMatLin)>0
		nPosChk := len(aMatLin[1])
		// Verifica se a ultima posicao e um logico e aborta caso nao seja
		if valType(aMatLin[1,nPosChk]) <> 'L'
			msgAlert(STR0058) //"Matriz com conteudo de linhas não contem a ultima posição correta (valor logico)"
			return({})
		endIf
	endIf
	//se a definicao de tela foi na propria funcao ou nao
	if valType(oDlgTB) <> 'O'
		DEFINE MSDIALOG oDlgTB TITLE cTexTit FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
		nLinI := ndLinIni
		nColI := ndColIni
		nLinF := ndLinFin
		nColF := ndColFin
		lDlg  := .t.
	endIf
	// Marca/Desmarca
	if lMosMt
		@ nLinI+10+nTam,nColI-iIf(lDlg,6,5) CHECKBOX oCheck VAR lCheck PROMPT cTexChk OF oDlgTB SIZE 100,8
		oCheck:bChange := {|| msAguarde( {|| PLSMD(aMatLin,lCheck) ,oObjGrid:Refresh() } ) }
	endIf
	// Pesquisa generica
	if lPes
		@ nLinI+7+nTam,140 COMBOBOX oTipoPes var cTipoPes ITEMS aPesOrd SIZE 070,010 OF oDlgTB PIXEL COLOR CLR_HBLUE
		@ nLinI+7+nTam,210 get oPes var cChave size 145,08 of oDlgTB pixel valid {|| PLSPE(oObjGrid,aMatLin,cChave,aMatCol,cTipoPes), cChave := space(100) }
	endIf
	// Tabelas
	oObjGrid 			:= tcBrowse():new(nLinI+20+nTam-(iIf(lMosMt,0,7)),nColI-6,iIf(lDlg,nColF*3.5,nColF),iIf(lDlg,nLinF*4.8+(iIf(lMosMt,0,7)),nLinF),,,,oDlgTB,,,,,,,,,,,,.f.,,.t.,,.f.)
	oObjGrid:lHScroll 	:= .t.
	oObjGrid:lVScroll 	:= .t.
	
	oObjGrid:addColumn(tcColumn():new(" ",Iif(lMosMt,{|| loadBitmap( GetResources(), Iif(aMatLin[oObjGrid:nAt,nPosChk],"LBOK","LBNO") ) },{||}),"@c",nil,nil,nil,010,.T.,.T.,nil,nil,nil,.T.,nil))
	
	for nI:=1 to len(aMatCol)
		bCol :=  "{|| oObjGrid:addColumn(tcColumn():New(aMatCol["+allTrim(str(nI))+",1],{||OemToAnsi( aMatLin[oObjGrid:nAt,"+AllTrim(Str(nI))+"] )},+aMatCol["+AllTrim(Str(nI))+",2],nil,nil,nil,aMatCol["+AllTrim(Str(nI))+",3],.F.,.F.,nil,nil,nil,.F.,nil) ) }"
		eval( &bCol )
	next
	// atualiza browse
	PLSSELATU(oObjGrid,aMatLin)
	
	if lMosMt
		oObjGrid:bLDblClick := {|| PLSCHKBOX(aMatLin,oObjGrid:nAt) }
	endIf
	//se a definicao de tela foi na propria funcao ou nao
	If Len(aMatLin) == 0  //Caso nao tenha dados desabilita as funcionalidades do Obj para nao ocorrer errorlog
		oObjGrid:Disable()
	EndIf
	if lDlg
		ACTIVATE MSDIALOG oDlgTB CENTERED ON INIT enChoiceBar(oDlgTB,bOK,bCancel,.F.,{})
	endIf
return(iIf(lDlg,lOk,oObjGrid))

/*/{Protheus.doc} PLSCHKBOX
Marca e desmarca linha
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
static Function PLSCHKBOX(aMatLin,nLin)
	LOCAL nPos := 0
	
	If Len(aMatLin) == 0
		Return()
	EndIf
	nPos := len(aMatLin[1])
	// verifica se e registro valido para selecao
	if aMatLin[nLin,nPos]
		aMatLin[nLin,nPos] := .f.
	else
		aMatLin[nLin,nPos] := .t.
	endIf
return(nil)

/*/{Protheus.doc} PLSSELATU
Atualiza o browse
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSSELATU(oObjGrid,aMatLin)
	oObjGrid:setArray(aMatLin)
	oObjGrid:goTop()
	oObjGrid:refresh()
return(nil)

/*/{Protheus.doc} PLSLIMSTA
Limpa matriz statica
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSLIMSTA(cChave)
	DEFAULT cChave 	:= Space(100)
	//Zera matriz statica
	If Empty(cChave)
		__aMatCom := {}
	EndIf
Return()

/*/{Protheus.doc} PLSMD
Marca campos selecionados
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSMD(aMat,lCheck)
	LOCAL nI 	:= 0
	LOCAL nTam	:= Iif( Len(aMat)>0 , Len(aMat[1]) ,0)
	//Marca linhas
	For nI := 1 To Len(aMat)
		If aMat[nI,nTam] != lCheck
			aMat[nI,nTam] := lCheck
		EndIf
	Next
Return

/*/{Protheus.doc} PLSPE
Pesquisa do Browse
@type function
@author TOTVS
@since 02.05.2011
@version 1.0
/*/
Function PLSPE(oObjGrid,aMatLin,cChave,aMatCol,cTipoPes)
LOCAL nPos 		:= 0
LOCAL nPesCol 	:= ascan(aMatCol,{|x| x[1] == cTipoPes})

// Marca os itens ja selecionados
if (nPos := ascan(aMatLin,{|x| upper(allTrim(x[nPesCol])) == upper(allTrim(cChave))})) > 0

	aMatLin[nPos,len(aMatLin[nPos])] := .t.
	
	oObjGrid:nAt := nPos
	oObjGrid:refresh()
endIf

return

/*/{Protheus.doc} PLSGrauUM
Marca campos selecionados
@type function
@author TOTVS
@since 24.08.2010
@version 1.0
/*/
Function PLSGrauUM(cCdPadP,cCodPro,cCodigo,cDatPro,cTipo)
LOCAL aArea 	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cRet		:= ""
LOCAL aVetTab 	:= {}
LOCAL cCodTab	:= ""

DEFAULT cCdPadP	:= ""
DEFAULT cCodPro := ""
DEFAULT cCodigo := ""
DEFAULT cTipo	:= ""

//cTipo == "1" - Informa BD4_CODTPA e retorna BD4_CODIGO
//cTipo == "2" - Informa BD4_CODIGO e retorna BD4_CODTPA

aVetTab := PLSRETTAB(cCdPadP,cCodPro,cDatPro,PLSINTPAD(),"","","","")

If aVetTab[1]
	cCodTab := aVetTab[3]
EndIf

If cTipo == "1"
	BD4->(dbSetOrder(3)) //BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODTPA
	If BD4->(dbSeek(xFilial("BD4")+PLSINTPAD()+cCodTab+cCdPadP+cCodPro+cCodigo))
		cRet := BD4->BD4_CODIGO
		lRet := .T.
	EndIf
Else
	BD4->(dbSetOrder(1)) //BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODIGO + DTOS(BD4_VIGINI)
	If BD4->(dbSeek(xFilial("BD4")+PLSINTPAD()+cCodTab+cCdPadP+cCodPro+cCodigo))
		cRet := BD4->BD4_CODTPA
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)

Return {lRet,cRet}

/*/{Protheus.doc} PLSTXTSX3
Retorna o texto do item do sx3
@type function
@author TOTVS
@since 20.02.2011
@version 1.0
/*/
Function PLSTXTSX3(cCampo,cConteudo)
LOCAL nPos	 := 0
LOCAL cTexto := ""
LOCAL aRet 	 := {}

// Monta matriz com conteudo do sx3
aRet := RetSx3Box( X3CBox( Posicione('SX3',2,cCampo,'X3_CBOX') ),,,1 )

// Alimenta a estrutura
If Len(aRet) > 0
	If ( nPos := Ascan(aRet,{ |x| x[2] == cConteudo }) ) > 0
		cTexto := AllTrim(aRet[nPos,3])
	EndIf
EndIf

Return OemtoAnsi(cTexto)

/*/{Protheus.doc} PLSHTML
Retorna um texto no formato html
@type function
@author TOTVS
@since 08/02/11
@version 1.0
/*/
Function PLSHTML(cTexto,cTamanho,cColor,cType)
DEFAULT cTamanho := '4'
DEFAULT cColor   := 'black'
DEFAULT cType	 := 'Courier new'

cRet := '<font Style="font-size:'+cTamanho+'px; font-family:'+cType+'; color:'+cColor+'; font-weight: bold" >'+cTexto+'</font>'

Return cRet

/*/{Protheus.doc} B72Limpa
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
Function B72Limpa()

M->B72_OBS := ""

Return .T.

/*/{Protheus.doc} PLSAJUMAT
Ajusta matriz de criticas na gravacao
@type function
@author TOTVS
@since 08/02/11
@version 1.0
/*/
Function PLSAJUMAT(aCabCri,aDadCri,cCampo)
LOCAL nI		:=	1
LOCAL nPos		:= 0
LOCAL aMatAux 	:= {}
LOCAL cAlias	:= SubStr(cCampo,1,3)
LOCAL cCodGlo	:= ""
LOCAL cCodAux	:= ""

For nI := 1 To Len(aDadCri)

	if PLRETPOS( cCampo,aCabCri ) !=  0 
		
		If ! Empty( aDadCri[ nI,PLRETPOS( cCampo,aCabCri ) ] )
		
			//Verifica se o campo existe
			If (nPos := PLRETPOS( cAlias + "_TIPO",aCabCri ) ) > 0
				
				cCodGlo := aDadCri[ nI,PLRETPOS( cAlias + "_CODGLO",aCabCri ) ]
				
				If cCodAux <> cCodGlo
					If Empty(cCodGlo)
						cCodGlo := cCodAux
					Else
						cCodAux := cCodGlo
					EndIf
				EndIf
				
				aDadCri[nI,nPos] := Posicione("BCT",1, xFilial("BCT") + PlsIntPad() + cCodGlo ,"BCT_TIPO")
			EndIf
			
			//Matriz ajustada
			AaDd( aMatAux, aDadCri[nI] )
			
		EndIf
		
	else
		exit	
	endIf
	
Next

aDadCri := aClone(aMatAux)

Return

/*/{Protheus.doc} PLSRETCP
Retorna a composicao de um procedimento
@type function
@author TOTVS
@since 03/04/11
@version 1.0
/*/
Function PLSRETCP(cMatrUs,cCodRda,cCodPad,cCodPro,dDatPro,cCodInt,cCodLocal,cCodEsp,lAneste)
LOCAL cCodPla := ""
LOCAL cTipPre := ""
LOCAL aVetTab := {}
LOCAL aComEve := {}

DEFAULT lAneste := .F.

// Verifica o produto do usuario
If ! Empty(cMatrUs)
	BA1->(DbSetOrder(2))//BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO
	BA3->(DbSetOrder(1))//BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB
	
	If BA1->(MsSeek(xFilial("BA1")+cMatrUs)) .And. !Empty(BA1->BA1_CODPLA)
		cCodpla := BA1->BA1_CODPLA
	ElseIf BA3->(MsSeek(xFilial("BA3")+Substr(cMatrUs,1,14))).And. !Empty(BA3->BA3_CODPLA)
		cCodpla := BA3->BA3_CODPLA
	Endif
	
Endif

// Verifica o Tipo do Prestador
If ! Empty(cCodRda)
	BAU->(DbSetOrder(1))//BAU_FILIAL, BAU_CODIGO
	If BAU->(MsSeek(xFilial("BAU")+cCodRda))
		cTipPre := BAU->BAU_TIPPRE
	EndIf
EndIf

// Tabela
If ! Empty(cCodPro)
	
	aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodInt,cCodRda,cCodEsp,"",cCodLocal,dDatPro,"1",cCodInt,cCodpla,,,,cTipPre)
	
	if aVetTab[1]
		aComEve	:= PLSCOMEVE(aVetTab[3],cCodPad,cCodPro,cCodInt,dDatPro,,,,,,,,,,lAneste)
	endIf
	
EndIf

Return(aComEve)

/*/{Protheus.doc} PLSCHKPAC
Verifica a tabela e se o procedimento principal esta no PAC
@type function
@author TOTVS
@since 03/04/11
@version 1.0
/*/
Function PLSCHKPAC(cAliasIte,cCodRda,dDatPro)
LOCAL aArea 	 := GetArea()
LOCAL cCodPad	 := &( "M->"+cAliasIte+"_CODPAD" )
LOCAL cCodPro 	 := ""
LOCAL cCPAux	 := ""
LOCAL nPos		 := 0
LOCAL lExisPac 	 := .F.
LOCAL lRet		 := .F.
// Six
SIX->( DbSetOrder(1) )
// Checa se deve procurar no pacote
If SIX->( MsSeek("BR88") )
	// Verifica se o procedimento informado e pacote
	BR8->( DbSetOrder(8) ) //BR8_FILIAL + BR8_CODPSA + BR8_TPPROC + BR8_CODPAD
	// Antes de verificar se existe pacote
	cCodPro := &("M->"+cAliasIte+"_CODPRO")
	// Nao faz a procura de pacote no reembolso e no honorario
	If !PLSRetAut()[1] $ "04,03"
		lRet := BR8->( MsSeek( xFilial("BR8") + cCodPro + '6' + AllTrim(cCodPad) ) )
	EndIf
	// Verifica se o procedimento de pacotes esta na composicao de pacote
	If lRet
		// Monta a composicao do pacote
		aItensPac := PlRetPac(PLSINTPAD(),cCodRda,BR8->BR8_CODPAD,BR8->BR8_CODPSA,nil,dDatPro)
		
		If Len(aItensPac) > 0
			// Tabela do pacote
			cCodPad := BR8->BR8_CODPAD
			// Verfica qual procedimento deve ser inserido automaticamente
			lExisPac := ( nPos := Ascan( aItensPac,{ |x| x[2] == BR8->BR8_CODPSA } ) ) > 0
			// Nao esta no pacote
			If lExisPac
				cCPAux := aItensPac[nPos,1]
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	// Se nao achou procura na br8
	If !lRet .And. Empty(cCodPad)
		lRet := BR8->( MsSeek( xFilial("BR8") + cCodPro ) )
		If lRet
			cCodPad := IiF( !Empty(cCodPad) , cCodPad , BR8->BR8_CODPAD )
		EndIf
	EndIf
	
	If Empty(cCPAux)
		cCPAux := cCodPad
	EndIf
	// Coloca o codpad no campo
EndIf

RestArea(aArea)
Return( {cCPAux + AllTrim(cCodPro), cCodPad } )

/*/{Protheus.doc} PLSVLDINP
Inclui procedimento nao relacionado no pacote
@type function
@author TOTVS
@since 11.04.11
@version 1.0
/*/
Function PLSVLDINP(__cTipo,cCodPP,oEncA,oBrwP,oBrwC,cAliasCab,cAliasIte,cAliasCri,aDadB43,aCabB43,aTrbB43)
LOCAL nI         := 1
LOCAL nPosII	 := 1
LOCAL nQtdCon  	 := 1
LOCAL nPosLinDel := 0
LOCAL nPosCodPad := 0
LOCAL nPosCodPro := 0
LOCAL cSequen	 := ""
LOCAL cCodPad  	 := ""
LOCAL cCodPro  	 := ""
LOCAL lNegProPac := .F.
LOCAL lExisBrw 	 := .F.
LOCAL aCodCri	 := {}

PRIVATE aGets
PRIVATE aTela

DEFAULT cAliasCab := "BE1"
DEFAULT cAliasIte := "BE2"
DEFAULT cAliasCri := "BEG"
DEFAULT cCodPP    := cPadPro
DEFAULT aDadB43	  := {}
DEFAULT aCabB43	  := {}
DEFAULT aTrbB43	  := {}
// Posicao
nPosLinDel := Len(oBrwP:aHeader)+1
nPosCodPad := Ascan( oBrwP:aHeader,{ |x| x[2] == cAliasIte+"_CODPAD"} )
nPosCodPro := Ascan( oBrwP:aHeader,{ |x| x[2] == cAliasIte+"_CODPRO"} )
// Tabela e o procedimento
cSequen := StrZero( Len(oBrwP:aCols)+1,3 )
cCodPad := Subs(cCodPP,1,2)
cCodPro := Subs(cCodPP,3,16)
cCodPro := cCodPro + Space( 16-Len(cCodPro) )
// Verifica a tabela e se o procedimento principal esta no pacote
lExisBrw := ( nPosII := Ascan( oBrwP:aCols ,{ |x| x[nPosCodPro] == cCodPro .And. x[nPosCodPad] == cCodPad .And. !x[nPosLinDel] } ) ) > 0

If lExisBrw
	cSequen	:= oBrwP:FieldGet(cAliasIte+"_SEQUEN",nPosII)
EndIf

lNegProPac 	:= PLSCHKPRI(cSequen,cCodPad,cCodPro,cAliasIte,oBrwP,cAliasCri,oBrwC,&("M->"+cAliasCab+"_CODRDA"),&("M->" + cAliasCab + Iif(cAliasCab=="BE4","_DTDIGI","_DATPRO") ),&("M->"+cAliasCab+"_USUARI"),&("M->"+cAliasCab+"_CODESP"),&("M->"+cAliasCab+"_CODLOC") )
// Ja existe no browse e deve ser negado pois o pacote foi informado depois
If lNegProPac .And. lExisBrw
	// Fica com .F. para nao checar novamente no 090aut
	lNegProPac := .F.
	// Sequencia e Procedimento
	cCodPad := oBrwP:FieldGet(cAliasIte+"_CODPAD",nPosII)
	
	PLSPOSGLO(PLSINTPAD(),__aCdCri186[1],__aCdCri186[2],,"0")
	AaDd(aCodCri,{__aCdCri186[1],PLSBCTDESC(), cCodPad + "-" + cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro} )
	
	// Alias e caminho da critica.
	PLSCOMPCRI(aCodCri,cAliasCri)
	
	// Ajusta procedimento ja autorizado
	oBrwP:FieldPut(cAliasIte+"_STATUS","0",nPosII)
	oBrwP:FieldPut(cAliasIte+"_IMGSTA","DISABLE",nPosII)
	oBrwP:FieldPut(cAliasIte+"_AUDITO",BCT->BCT_AUDITO,nPosII)
	oBrwP:FieldPut(cAliasIte+"_NIVCRI","BLY",nPosII)
	oBrwP:FieldPut(cAliasIte+"_CHVNIV",cSequen+cCodPad+cCodPro,nPosII)
	// Critica o procedimento ja autorizado
	PLSA090ACR(,,,aCodCri,oBrwC,cSequen,cAliasCri,oBrwP)
	
	oBrwP:lAtuSVCOL := .F.
	// Se for inclusao de pacote onde o procedimento e negado ajusta para .f. para nao considerar na 090aut
ElseIf lNegProPac .And. !lExisBrw .And. cCodPad <> M->&( cAliasIte+"_CODPAD" )
	lNegProPac := .F.
	
ElseIf lNegProPac .And. lExisBrw .And. cCodPad == M->&( cAliasIte+"_CODPAD" )
	lNegProPac := .F.
	// Se vai incluir procedimento nao composto no pacote
ElseIf !lNegProPac .And. !lExisBrw .And. cCodPad <> M->&( cAliasIte+"_CODPAD" )
	// Inclui a linha
	aGets := aClone(oEncA:aGets)
	aTela := aClone(oEncA:aTela)
	// Procedimento
	oBrwP:AddBlank()
	oBrwP:ForceRefresh(oBrwP)
	// Criticas
	oBrwC:AddBlank()
	oBrwC:ForceRefresh(oBrwC)
	
	oBrwC:SetPos( Len(oBrwC:aCols) )
	oBrwP:SetPos( Len(oBrwP:aCols) )
	
	cSequen	:= oBrwP:FieldGet(cAliasIte+"_SEQUEN" )
	oBrwP:FieldPut(cAliasIte+"_SEQUEN",cSequen )
	// Se Ok
	BR8->( DbSetOrder(1) )
	BR8->( MsSeek( xFilial("BR8")+cCodPad+cCodPro ) )
	// Valida o procedimento
	If cAliasCab <> "BE4"
		lRet := PLSA090Aut(cSequen,cCodPad,cCodPro,nQtdCon,"2",;
			cAliasIte,cAliasCab,cAliasCri,oBrwP,oBrwC,&("M->"+cAliasCab+"_CDPFRE"),nil,nil,nil,nil,nil,;
			nil,nil,nil,aDadB43,aCabB43,aTrbB43,NIL,If(__cTipo=="2","S","E"),;
			nil,nil,.F.)
	Else
		lRet := PLSA092Aut(cSequen,cCodPad,cCodPro,nQtdCon,"2",cAliasIte,cAliasCab,cAliasCri,,.F.)
	EndIf
	// Verficacao final
	If lRet
		// Trigger
		RunTrigger(1)
		SX7->( DbSetOrder(1) )
		If SX7->( MsSeek( cAliasIte+"_CODPRO" ) )
			
			While ! SX7->(Eof()) .And. SX7->X7_CAMPO == cAliasIte+"_CODPRO"
				
				If oBrwP:FieldPos(SX7->X7_CDOMIN) > 0 .And. Type("M->"+SX7->X7_CDOMIN) <> "U"
					oBrwP:FieldPut(SX7->X7_CDOMIN,&("M->"+SX7->X7_CDOMIN))
				EndIf
				
				SX7->( DbSkip() )
			EndDo
		EndIf
		// Atualiza
		oBrwP:Refresh()
		oBrwC:Atualiza()
		oBrwP:Atualiza()
	EndIf
EndIf
Return( lNegProPac )

/*/{Protheus.doc} PLSCHKPRI
Verifica a tabela e se o procedimento principal esta no pacote
@type function
@author TOTVS
@since 03/04/11
@version 1.0
/*/
Function PLSCHKPRI(cSequen,cCodPad,cCodPro,cAliasIte,oBrwPro,cAliasCri,oBrwCri,cCodRda,dDatPro,cMatrUs,cCodEsp,cCodLocal)
LOCAL aArea   	  	:= GetArea()
LOCAL nPos		  	:= 0
LOCAL nPosII	  	:= 0
LOCAL nI		  	:= 1
LOCAL lRet 	  	  	:= .F.
LOCAL lExisPac	  	:= .F.
LOCAL lExisPacBrw  	:= .F.
LOCAL lParAut		:= .F.
LOCAL lNegProPac	:= .F.
LOCAL cComPar	  	:= ""
LOCAL cCodPadDig    := ""
LOCAL nPosLinDel  	:= Len(oBrwPro:aHeader)+1
LOCAL nPosCodPad  	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliasIte+"_CODPAD"})
LOCAL nPosCodPro  	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == cAliasIte+"_CODPRO"})
LOCAL aItensPac	  	:= {}
LOCAL aMatCom 	  	:= {}
LOCAL aRet		  	:= {}
LOCAL aCodCri		:= {}
LOCAL oGEN		  	:= NIL
DEFAULT cMatrUs	  	:= ""
DEFAULT cCodRda	  	:= ""
DEFAULT cCodEsp	  	:= ""
DEFAULT cCodLocal 	:= ""
// Verifica se ja existe um procedimento de pacote no browse
lExisPacBrw := ( nPosII := Ascan( oBrwPro:aCols ,{ |x| x[nPosCodPro] == cCodPro .And. x[nPosCodPad] <> cCodPad .And. !x[nPosLinDel] } ) ) > 0
// Se existe pega do browse
If lExisPacBrw
	cCodPadDig := oBrwPro:FieldGet(cAliasIte+"_CODPAD",nPosII)
Else
	cCodPadDig := M->&( cAliasIte+"_CODPAD" )
EndIf
// Checa se o procedimento encontrado e um pacote
aItensPac := PlRetPac(PLSINTPAD(),cCodRda,cCodPadDig,cCodPro,nil,dDatPro)
// Se tem composicao
If Len(aItensPac) > 0
	// Se o procedimento de pacote esta na composicao do pacote
	lExisPac := ( nPos := Ascan( aItensPac,{ |x| x[2] == cCodPro } ) ) > 0
	
	If lExisPac
		// Pega a participacao do procedimento dentro do pacote
		cComPar := aItensPac[nPos,9]
		// Participacao do procedimento informado na getdados
		aMatCom := PLSNEGCOM(cSequen,cCodPad,cCodPro,'0',dDatPro,K_Incluir,"",.T.,cCodRda,cCodEsp,cCodLocal,cMatrUs,"",.F.)
		// Se o procedimento tem composicao
		If !Empty(cComPar) .And. Len(aMatCom) > 0
			// Matriz da composicao do procedimento do pacote
			oGEN := PLSCONTR():New()
			aRet := oGEN:Split(',', cComPar )
			oGEN:Destroy()
			// Posiciona no procedimento
			If ( nPos := Ascan(aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro} ) ) > 0
				
				For nI:=1 To Len(aMatCom[nPos,2])
					If !aMatCom[nPos,2,nI,5]
						aMatCom[nPos,2,nI,5] := AsCan( aRet,{|x| StrTran(x,'-','') == aMatCom[nPos,2,nI,2] + AllTrim(Left(aMatCom[nPos,2,nI,1],At('-',aMatCom[nPos,2,nI,1])-1)) } ) > 0
					EndIf
				Next
				
			EndIf
			// Se existe ao menos uma participacao liberada
			lParAut := AsCan( aMatCom[nPos,2],{|x| !x[5] } ) > 0
		EndIf
		// Se existe ao menos uma participacao liberada
		If !lParAut
			lNegProPac := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return( lNegProPac )

/*/{Protheus.doc} PLSNACOM
Negar a composicao do procedimento
@type function
@author TOTVS
@since 03/04/11
@version 1.0
/*/
Function PLSNACOM(cSequen,cCodPad,cCodPro,cStatus,dDatPro,nOpc,cChave,cCodRDA,lBD7,cMatrUs)
LOCAL aArea		:= GetArea()
LOCAL nY		:= 0
LOCAL nPos		:= 0
LOCAL nPos2		:= 0
LOCAL aMatCom 	:= {}
DEFAULT cMatrUs	:= ""

// Se a critica esta ativa e se eh permitida para a rda
If PLSPOSGLO( PLSINTPAD(),__aCdCri178[1],__aCdCri178[2] ) .And. PLSCHKCRI( {'BAU',cCodRDA,__aCdCri178[1]} )

	// Seta o idx
	BD7->( DbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC

	// Negar a participacao
	aMatCom := PLSNEGCOM(cSequen,cCodPad,cCodPro,cStatus,dDatPro,nOpc,cChave,,cCodRDA,,,cMatrUs,,,lBD7)

	// Posiciona no procedimento correto
	If ( nPos := Ascan(aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro } ) ) > 0
		// Verifica todas as participacoes

		For nY:=1 To Len(aMatCom[nPos,2])

			// Posiciona no bd7 correspondente e bloqueia a Participacao
			If BD7->( MsSeek( xFilial("B53") + B53->(B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV + cSequen + aMatCom[nPos,2,nY,2] ) ) )
				
				If BD7->( FieldPos("BD7_BLOPAG") ) > 0

					PLSPOSGLO(PLSINTPAD(),__aCdCri179[1],__aCdCri179[2])

					// Se esta negada ou nao
					BD7->( RecLock("BD7",.F.) )
						PLBLOPC('BD7', aMatCom[nPos,2,nY,Len(aMatCom[nPos,2,nY])], __aCdCri179[1], PLSBCTDESC())
					BD7->( MsUnLock() )
					
				EndIf
				
			EndIf
		Next
	EndIf
EndIf

// Rest nas linhas do browse e na area
RestArea( aArea )

Return(aMatCom)

/*/{Protheus.doc} PLSSALDO
Verifica se ainda tem saldo no BD7
@type function
@author TOTVS
@since 03/04/11
@version 1.0
/*/
Function PLSSALDO(cChave,cChavLib)
LOCAL aArea	:= GetArea()
LOCAL lSaldo:= .F.
DEFAULT cChavLib := ""
// Posiciona no primeiro item e verifica se ainda tem saldo
If !Empty(cChavLib)
	BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	If BE2->(MsSeek(xFilial("BE2")+ cChavLib))
		While !BE2->(Eof()) .and. xFilial("BE2")+cChavLib == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
			If BE2->BE2_SALDO > 0
				lSaldo := .T.
				Exit
			EndIf
			BE2->(DbSkip())
		Enddo
	EndIf
Endif
// Retorno a Area
RestArea( aArea )
Return(lSaldo)

/*/{Protheus.doc} PLSGETCRI
Retorna critica validada na autorizacao
@type function
@author TOTVS
@since 11/08/11
@version 1.0
/*/
Function PLSGETCRI(cAliasCab,cChavGui,cSequen,cCodPad,cCodPro,nQtdPro)
LOCAL aArea		:= GetArea()
LOCAL aAreaCab	:= {}
LOCAL aAreaCri	:= {}
LOCAL cChave	:= ""
LOCAL cOpeMov	:= ""
LOCAL cCodCri 	:= ""
LOCAL cDesCri 	:= ""
LOCAL cInfCri 	:= ""
LOCAL cAliasCri := ""
LOCAL cCodTpa	:= ""
LOCAL aCodCri 	:= {}

// Satd - Cobranca (Consulta ou Exame)
if cAliasCab == 'BEA'

	cAliasCri := 'BEG'
	
	aAreaCab  := (cAliasCab)->(GetArea())
	aAreaCri  := (cAliasCri)->(GetArea())
	
	BEA->( DbSetOrder(12) ) //BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV

// Honorario
ElseIf cAliasCab == 'B0D'

	cAliasCri := 'B2D'
	
	aAreaCab  := (cAliasCab)->(GetArea())
	aAreaCri  := (cAliasCri)->(GetArea())
	
	B0D->( DbSetOrder(5) ) //B0D_FILIAL + B0D_OPEMOV + B0D_CODLDP + B0D_CODPEG + B0D_NUMGUI
	
	SIX->(DbSetOrder(1))
	If !SIX->( MsSeek("B0D5") )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Indice nao encontrado [5] alias ["+cAliasCab+"]" , 0, 0, {})
		
		Return(aCodCri)
	EndIf

// Resumo
ElseIf cAliasCab == 'B0I'

	cAliasCri := 'B0L'
	
	aAreaCab  := (cAliasCab)->(GetArea())
	aAreaCri  := (cAliasCri)->(GetArea())
	
	B0I->( DbSetOrder(3) ) //B0I_FILIAL + B0I_OPEMOV + B0I_CODLDP + B0I_CODPEG + B0I_NUMGUI
	
EndIf

// Posiciona no cabecalho para montar a chave da critica
if !empty(cAliasCri)

	if (cAliasCab)->( msSeek(xFilial(cAliasCab) + cChavGui ) )
		cChave := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)")
	endIf
	
endIf

BCT->(DbSetOrder(1)) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO

// Posiciona na critica
If !Empty(cChave)
	
	(cAliasCri)->( DbSetOrder(1) ) //???_FILIAL + ???_OPEMOV + ???_ANOAUT + ???_MESAUT + ???_NUMAUT + ???_SEQUEN
	If (cAliasCri)->( MsSeek(xFilial(cAliasCri)+cChave+cSequen) )
		
		// While de critica conforme chave
		While !(cAliasCri)->(eof()) .And. &(cAliasCri+"->("+cAliasCri+"_OPEMOV+"+cAliasCri+"_ANOAUT+"+cAliasCri+"_MESAUT+"+cAliasCri+"_NUMAUT+"+cAliasCri+"_SEQUEN)") == cChave+cSequen
		
			// Dados da critica
			cOpeMov	:= (cAliasCri)->&(cAliasCri+"_OPEMOV")
			cCodCri := (cAliasCri)->&(cAliasCri+"_CODGLO")
			cDesCri := (cAliasCri)->&(cAliasCri+"_DESGLO")
			cInfCri := (cAliasCri)->&(cAliasCri+"_INFGLO")
			cCodTpa := (cAliasCri)->&(cAliasCri+"_PARTIC")
		
			// Posiciona na tabela de critica
			If !Empty(cCodCri)
		
				If BCT->(MsSeek( xFilial("BCT") + cOpeMov + cCodCri ) )
					AaDd(aCodCri,{cCodCri,cDesCri,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro,cSequen,cCodTpa,nQtdPro,0,"1"})
				EndIf
				
			Else
				AaDd(aCodCri,{"",cDesCri,cInfCri,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro,cSequen})
			EndIf
			
			(cAliasCri)->(DbSkip())
		EndDo
		
	EndIf
	
EndIf

// Retorno a Area
RestArea( aArea )

(cAliasCab)->( RestArea( aAreaCab ) )
(cAliasCri)->( RestArea( aAreaCri ) )

Return(aCodCri)

/*/{Protheus.doc} PLSORDFIE
Matriz de campos ordenados para uso na msget ou PLSBRW. A matriz acampos pode ter o conteudo da bcm por exemplo
@type function
@author TOTVS
@since 11/08/11
@version 1.0
/*/
Function PLSORDFIE(cAlias, aCampos, aCamposEdt, lFolder, lCopyGui)
LOCAL aArea  	:= GetArea()
LOCAL lMsMat  	:= getNewPar("MV_PLSLSX3",.F.)
LOCAL nI	  	:= 1
LOCAL aFields 	:= NIL
LOCAL aFolders	:= NIL
LOCAL cDFolder	:= ""
local lPLSA094B := funName() == "PLSA094B"

DEFAULT lFolder  := .T.
DEFAULT lCopyGui := .F.     // oriundas de rotinas de copas de guias

// Se monta a msmget por sx3 ou matriz
If lMsMat .or. lCopyGui

	SX3->( DbSetOrder(2) )

	// For de campos
	aFields := {}
	
	For nI := 1 To Len(aCampos)
	
		// Posiciona no registro
		If SX3->( MsSeek( aCampos[nI] ) )
	
			// Monta matriz de campos
			If X3Uso(SX3->X3_USADO)
			
				AaDd( aFields, {SX3->X3_TITULO,;		//01
								SX3->X3_CAMPO,;			//02
								SX3->X3_TIPO,;			//03
								SX3->X3_TAMANHO,;		//04
								SX3->X3_DECIMAL,;		//05
								SX3->X3_PICTURE,;		//06
								IIf(!Empty(SX3->X3_VALID),&("{||"+SX3->X3_VALID+"}"),""),;//07
								X3Obrigat(SX3->X3_CAMPO),;	//08
								SX3->X3_NIVEL,;				//09
								SX3->X3_RELACAO,;			//10
								SX3->X3_F3,;				//11
								IIf(!Empty(SX3->X3_WHEN),&("{||"+SX3->X3_WHEN+"}"),""),;			//12
								IIf(AsCan(aCamposEdt,aCampos[nI])>0,.F.,SX3->X3_VISUAL == "V"),;	//13
								.F.,; //lChave								//14
								SX3->X3_CBOX,; // tem que validar paises.	//15
								VAL(SX3->X3_FOLDER),; // nFolder			//16
								.F.,;//lNAltera								//17
								SX3->X3_PICTVAR,;//lPictVar  				//18
								SX3->X3_TRIGGER,;//Gatilho					//19
								nI} )//Ordem								//20
				
				// copiando uma liberação devemo habilitar somente o campo solicitação o campo relaizado não, pois ainda não foi realizado nada
				If lCopyGui .and. lPLSA094B
				
					If Alltrim(SX3->X3_CAMPO) == "BE2_QTDPRO"
					
						SX3->( MsSeek("BE2_QTDSOL"))
						aFields[Len(aFields),1] := SX3->X3_TITULO
						
						If lCopyGui
							aFields[Len(aFields),10] := ''
						Endif
						
					Elseif Alltrim(SX3->X3_CAMPO) == "BE2_QTDSOL"
					
						SX3->( MsSeek("BE2_QTDPRO") )
						aFields[Len(aFields),1]	:= SX3->X3_TITULO
						aFields[Len(aFields),13]:= .T.
						
						If lCopyGui
							aFields[Len(aFields),10]:= ''
						Endif
						
					Endif
					
				Endif
				
			EndIf
			
		EndIf
		
	Next
	
	// Order de campo e folder
	If lFolder
		aFields := aSort(aFields,,,{|x,y| x[20]+x[16] < y[20]+y[16] } )
	EndIf
	
	// Monta folder
	If Len(aFields) > 0
	
		SXA->(DbSetOrder(1))
	
		If SXA->(MsSeek(cAlias)) .And. lFolder
		
			aFolders := {}
		
			While !SXA->(Eof()) .And. (SXA->XA_ALIAS == cAlias)
			
				#IFDEF SPANISH
					cDFolder := SXA->XA_DESCSPA
				#ELSE
					#IFDEF ENGLISH
						cDFolder := SXA->XA_DESCENG
					#ELSE
						cDFolder := SXA->XA_DESCRIC
					#ENDIF
				#ENDIF
				AaDd(aFolders,Capital(AllTrim(cDFolder)))
				
			SXA->(DbSkip())
			EndDo
			
		Else
			aFolders := NIL
		EndIf
		
	Else
		aFields := NIL
	EndIf
	
EndIf

RestArea(aArea)

Return( {aFields,aFolders} )

/*/{Protheus.doc} PLSXB11
Atualiza sequen ou valida qtd
@type function
@author TOTVS
@since 06/05/11
@version 1.0
/*/
Function PLSXB11(nTp)
LOCAL xRet

If Type('oBrwBD6')=='O'
	n := oBrwBD6:linha()
	
	If nTp == 1
		xRet := oBrwBD6:aCols[n,PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)]
	Else
		xRet := M->B11_QTDGLO <= oBrwBD6:aCols[n,PLRETPOS("BD6_QTDPRO",oBrwBD6:aHeader)]
	EndIf
Else
	If nTp == 1
		xRet := '001'
	Else
		xRet := M->B11_QTDGLO <= 1
	EndIf
EndIf
Return xRet

/*/{Protheus.doc} PLSVLDGP
Verifica se o numero da guia principal do BD5 E BE4 e valido
@type function
@author TOTVS
@since 06/05/11
@version 1.0
/*/
Function PLSVLDGP(cNumero,nTp)
LOCAL aArea := BEA->(GetArea())
LOCAL lRet  := .T.
DEFAULT nTp	:= 2
//| Verifica se a guia de autorizacao existe (sadt ou internacao)
If !Empty(cNumero)
	If nTp == 1
		BEA->(DbSetOrder(1))//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		If !BEA->( MsSeek(xFilial("BEA")+cNumero) )
			BEA->(DbSetOrder(6))//BEA_FILIAL + BEA_OPEINT + BEA_ANOINT + BEA_MESINT + BEA_NUMINT + DTOS(BEA_DATPRO) + BEA_HORPRO
			If !BEA->(MsSeek(xFilial("BEA")+cNumero))
				lRet := .F.
			EndIf
		EndIf
	Else
		BEA->(DbSetOrder(6))//BEA_FILIAL + BEA_OPEINT + BEA_ANOINT + BEA_MESINT + BEA_NUMINT + DTOS(BEA_DATPRO) + BEA_HORPRO
		If !BEA->(MsSeek(xFilial("BEA")+cNumero))
			lRet := .F.
		EndIf
	EndIf
EndIf
//| Verifica se encontrou
If !lRet
	Aviso( 	"Atenção",;
		"Não existe esta guia de autorização",;
		{ "Ok" }, 2 )
EndIf

BEA->(RestArea(aArea))
Return lRet

/*/{Protheus.doc} PLSHISGLO
Historico de glosas
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSHISGLO(cAlias)
local nI		 := 1
local cChaveGui	 := ( cAlias )->&( cAlias + "_CODOPE" ) + ( cAlias )->&( cAlias + "_CODLDP" ) + ( cAlias )->&( cAlias + "_CODPEG" ) + ( cAlias )->&( cAlias + "_NUMERO" ) + ( cAlias )->&( cAlias + "_ORIMOV" )
local aHistorico := {}
local aTitCampo  := {}
local aCabec     := {}
local aRetGlo	 := {}
local aRetAcao	 := {}

// Array de campos
AaDd(aTitCampo,'BDX_ACAO')  //01
AaDd(aTitCampo,'BDX_TIPGLO')//02
AaDd(aTitCampo,'BDX_DTACAO')//03
AaDd(aTitCampo,'BDX_CODPRO')//04
AaDd(aTitCampo,'BDX_DESPRO')//05
AaDd(aTitCampo,'BDX_CODGLO')//06
AaDd(aTitCampo,'BDX_DESGLO')//07
AaDd(aTitCampo,'BDX_VLRMAN')//08
AaDd(aTitCampo,'BDX_VLRPAG')//09
AaDd(aTitCampo,'BDX_VLRGLO')//10
AaDd(aTitCampo,'BDX_PERGL2')//11
AaDd(aTitCampo,'BDX_QTDREC')//12
AaDd(aTitCampo,'BDX_VLRREC')//13
AaDd(aTitCampo,'BDX_VLRINF')//14
AaDd(aTitCampo,'BDX_QTDINF')//15
AaDd(aTitCampo,'BDX_RESPAL')//16
AaDd(aTitCampo,'BDX_OBS')	//17


//Monta matriz de historico
BDX->(dbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
if BDX->( msSeek( xFilial("BDX") + cChaveGui) )
	
	//Pega o titulo dos campos
	SX3->( DbSetOrder(2) )
	
	for nI := 1 To Len(aTitCampo)
		
		if SX3->( msSeek( aTitCampo[nI] ) )
			aadd(aCabec,{ allTrim(SX3->X3_TITULO),SX3->X3_PICTURE,iIf(SX3->X3_TIPO == 'M',200,SX3->X3_TAMANHO)} )
		endIf
		
	next
	
	//Monta matriz de historico
	while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV) == xFilial("BDX") + cChaveGui
	
 		if BDX->BDX_TIPREG == '3' .or. (BDX->BDX_TIPREG == '1' .and. !empty(BDX->BDX_ACAO))
			
			aadd(aHistorico,{ 	PLRDESBOX(@aRetAcao,'BDX_ACAO',BDX->BDX_ACAO),;
								PLRDESBOX(@aRetGlo,'BDX_TIPGLO',BDX->BDX_TIPGLO),;
								BDX->BDX_DTACAO,;
								allTrim(BDX->BDX_CODPRO),;
								allTrim(BDX->BDX_DESPRO),;
								allTrim(BDX->BDX_CODGLO),;
								allTrim(BDX->BDX_DESGLO),;
								BDX->BDX_VLRMAN,;
								BDX->BDX_VLRPAG,;
								BDX->BDX_VLRGLO,;
								BDX->BDX_PERGL2,;
								BDX->BDX_QTDREC,;
								BDX->BDX_VLRREC,;
								BDX->BDX_VLRINF,;
								BDX->BDX_QTDINF,;
								allTrim(BDX->BDX_RESPAL),;
								allTrim(BDX->BDX_OBS) } )
		endIf
		
	BDX->( dbSkip() )
	endDo
	
endIf

//exibe tela
if len(aHistorico) > 0
	plsCriGen(aHistorico, aCabec,"Glosas",,,,,,,,,,,,,,,,,,,,TFont():new("Courier New",7,14,,.F.,,,,.F.,.F.))
else
	aviso( "Atenção","Não existem glosas para esta guia",{ 'Ok' } )
endIf

return()

/*/{Protheus.doc} PLSVLCOC
Valida se o procedimento e de consulta
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSVLCOC(cCodPad,cCodPro)
LOCAL aArea := GetArea()
LOCAL lRet	:=.T.
// Verifica se o procedimento e uma consulta
If BR8->( FieldPos(BR8->BR8_CONSUL) ) > 0
	BR8->(DbSetOrder(1))
	If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )
		
		If BR8->BR8_CONSUL<>"1"
			lRet := .F.
		EndIf
		
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} PLSVINTS
Valida se e possivel alterar o observacao da interna saude
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSVINTS()
LOCAL aArea 	:= GetArea()
LOCAL lRet		:= .T.

// Verifica se tem resposta do auditor para o questionamento da int saude
B73->( DbSetOrder(1) )//B73_FILIAL + B73_ALIMOV + B73_RECMOV + B73_SEQPRO + B73_CODGLO + B73_SEQUEN
lRet := B73->( MsSeek( xFilial("B73") + B72->( B72_ALIMOV + B72_RECMOV + B72_SEQPRO + B72_CODGLO ) ) )

RestArea(aArea)
	
Return(lRet)

/*/{Protheus.doc} PLSCLSOP
Limpa __cOpeUsr se for necessario para forcar uma na saude reinicizalizaçao
@type function
@author TOTVS
@since 26.10.05
@version 1.0
/*/
Function PLSCLSOP()

__cOpeUsr := ""

Return

/*/{Protheus.doc} PLSJAVA
Executa .Jar externo via linha de comando.
@type function
@author TOTVS
@since 10.08.2011
@version 1.0
/*/
Function PLSJAVA(cPath, cJarName, aParms, cLib)
LOCAL cComando
LOCAL cResposta
LOCAL nX

cComando := "javaw -jar "

If ExistDir(cPath)
	cComando += '"' + cPath
Else
	Return(STR0069 + Chr(13) + Chr(10) + cPath)//"Erro: Caminho não existe!"
EndIf

If File(cPath+"\"+cJarName)
	cComando += '\' + cJarName + '"'
Else
	Return(STR0070 + Chr(13) + Chr(10) + cPath+"\"+cJarName)//"Erro: Arquivo .jar não encontrado!"
EndIf

If ValType(cLib) == "C" .And. !Empty(cLib) .And. !File(cPath+"\"+cLib)
	Return(STR0071 + Chr(13) + Chr(10) + cPath+"\"+cLib)//"Erro: Arquivo de biblioteca do .jar não encontrado!"
EndIf

If ValType(aParms) == "A"
	
	For nX := 1 To Len(aParms)
		
		cComando += ' "' + aParms[nX] + '"'
		
	Next
	
EndIf

cComando := strtran(cComando,'"','')
cResposta := WinExec(cComando)

If ValType(cResposta) == "N"
	cResposta := CValToChar(cResposta)
EndIf
	
Return(cResposta)

/*/{Protheus.doc} PLSBAUOPE
Valida Rda x Operadora
@type function
@author TOTVS
@since 10.08.2011
@version 1.0
/*/
Function PLSBAUOPE(cRda)
Return(ExistCpo("BAU",cRda,1) .And. ExistCpo("BAW",cRda + PLSINTPAD(),1) )

/*/{Protheus.doc} PLSRSUB
Retorna conteudo do relacao
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSRSUB(nTp)
LOCAL cRet:= ""

If nTp == 1
	cRet := If(Inclui,"",Posicione("BT5",1,xFilial("BT5")+PLSINTPAD()+B40->(B40_CODEMP+B40_NUMCON+B40_VERCON),"BT5_NOME"))
ElseIf nTp == 2
	cRet := If(Inclui,"",Posicione("BQC",1,xFilial("BQC")+PLSINTPAD()+B40->(B40_CODEMP+B40_NUMCON+B40_VERCON+B40_SUBCON+B40_VERSUB),"BQC_DESCRI"))
EndIf

Return(cRet)

/*/{Protheus.doc} PLSINCRI
Inclui novas criticas na matriz de criticas
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSINCRI(aCodCri,aRet)
LOCAL nFor := 0
// Inclui novas criticas na matric static de critica
For nFor := 1 To Len(aRet)
	If Ascan(aCodCri,{|x| x[1] == aRet[nFor,1] } ) == 0
		AaDd(aCodCri,aRet[nFor])
	EndIf
Next
Return

/*/{Protheus.doc} PLSDPTUSS
De/Para tabela tuss
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSDPTUSS(cTp,cCodPad,cCodPro)
LOCAL cRetCPad := cCodPad
LOCAL cRetCPro := cCodPro

// Somente se informado
If ! Empty(cCodPad+cCodPro)
	// Verifica se a ordem foi alterada
	Do Case
		// Entrada
	Case cTp == 'E'
		If BW0->( IndexOrd() ) <> 1
			BW0->( DbSetOrder(1) ) //BW0_FILIAL + BW0_CODPD1 + BW0_CODPR1 + BW0_CODPD2 + BW0_CODPR2
		EndIf
		// De/para de entrada
		If BW0->( MsSeek( xFilial("BW0") + cCodPad + cCodPro ) )
			cRetCPad := BW0->BW0_CODPD2
			cRetCPro := BW0->BW0_CODPR2
		Else
			If BW0->( MsSeek( xFilial("BW0") + cCodPad + space(Len(BW0->BW0_CODPR2)) ) )
				cRetCPad := BW0->BW0_CODPD2
				BR8->( DbSetOrder(1) )
				If BR8->( MsSeek( xFilial("BR8") + BW0->BW0_CODPD2 + cCodPro ) )
					cRetCPad := BW0->BW0_CODPD2
					cRetCPro := cCodPro
				EndIf
			EndIf
		EndIf
		// Saida
	Case cTp == 'S'
		If BW0->( IndexOrd() ) <> 2
			BW0->( DbSetOrder(2) ) //BW0_FILIAL + BW0_CODPD2 + BW0_CODPR2 + BW0_CODPD1 + BW0_CODPR1
		EndIf
		// De/para de entrada
		If BW0->( MsSeek( xFilial("BW0")+cCodPad+cCodPro ) )
			cRetCPad := BW0->BW0_CODPD1
			cRetCPro := BW0->BW0_CODPR1
		Else
			If BW0->( MsSeek( xFilial("BW0")+cCodPad+space(Len(BW0->BW0_CODPR2)) ) )
				cRetCPad := BW0->BW0_CODPD1
				BR8->( DbSetOrder(1) )
				If BR8->( MsSeek( xFilial("BR8") + BW0->BW0_CODPD1 + cCodPro ) )
					cRetCPad := BW0->BW0_CODPD1
					cRetCPro := cCodPro
				EndIf
			EndIf
		EndIf
	EndCase
EndIf

Return( { cRetCPad,cRetCPro } )

/*/{Protheus.doc} PLSFTel
Formata numero de telefone
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSFTel(cTel)
	
cTel := AllTrim( StrTran(StrTran(StrTran(cTel,"-",""),')',""),"(","") )
// Formata Numero de telefone
If Len( AllTrim(cTel) ) == 10
	cTel := "("+Left(cTel,2)+") " + SubStr(cTel,3,4) + "-" + SubStr(cTel,7,4)
ElseIf Len( AllTrim(cTel) ) == 8
	cTel := SubStr(cTel,1,4) + "-" +  SubStr(cTel,5,4)
EndIf

Return(cTel)

/*/{Protheus.doc} PLSCOMPCRI
Inclui nivel e caminho da critica.
@type function
@author TOTVS
@since 04.02.2012
@version 1.0
/*/
Function PLSCOMPCRI(___aCodCri,cAlias,cChvNiv)
Local nX	:= 0
LOCAL iX	:= 0
DEFAULT cChvNiv := ""

// Adiciona uma nova linha com o alias e o caminho da critica.
If Valtype(___aCodCri) == "A" .and. Len(___aCodCri) > 0

	If Valtype(___aCodCri[1]) == "A" .and. Len(___aCodCri[1]) > 0
		
		Aadd(___aCodCri, Array(Len(___aCodCri[1])) )
		
		iX := Len(___aCodCri)
		
		For nX := 1 To Len(___aCodCri[iX])
		
			If nX == 1
				___aCodCri[iX][nX] := " "
			Elseif nX == 2
				___aCodCri[iX][nX] := "Nível: " + cAlias + " - "+Posicione('SX2' , 1 , cAlias , 'X2_NOME')
			Elseif nX == 3
				___aCodCri[iX][nX] := StrZero(iX, 2) + " - " + PLSRETNCRI(cAlias)
			Elseif nX == 4
				If !Empty(cChvNiv)
					___aCodCri[iX][nX] := "Chave: " + cChvNiv
				Endif
			else
				___aCodCri[iX][nX] := ""
			Endif
			
		Next
		
	Endif
	
Endif

Return(___aCodCri)

/*/{Protheus.doc} PlVlMatM
Verifica se procedimento eh Material ou Medicamento e se a Rda de pagamento recebeu um procedimento.
@type function
@author TOTVS
@since 13/06/11
@version 1.0
/*/
function PlVlMatM()
local cCodPad 	:= BD7->BD7_CODPAD
local cCodPro 	:= BD7->BD7_CODPRO
local aRegBD6 	:= BD6->(GetArea())
local cChaGui 	:= ""
local cClasse 	:= ""
local cTpProc 	:= ""
local aTpMAT	:= strTokarr(allTrim( getNewPar("MV_PLSTPMA","0,6|1,2,3,4,5,7,8|9|1,2,3,4,5,7,8,9") ), "|") 
local lConsulta := .f.
local nValMax	:= 0

cChaGui := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)

BR8->(dbSetOrder(1))
BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+cChaGui))

if ! empty(BD6->BD6_GUIORI)
	cChaGui := BD6->BD6_GUIORI
	BD6->(MsSeek(xFilial("BD6")+cChaGui))
endIf

while BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChaGui .and. !BD6->(eof())
	
	if BD6->BD6_VLRAPR > nValMax .or. lConsulta
		
		if BR8->(BR8_CODPAD+BR8_CODPSA) <> BD6->(BD6_CODPAD+BD6_CODPRO)
			BR8->( msSeek( xFilial('BR8') + BD6->(BD6_CODPAD+BD6_CODPRO) ) )
		endIf
		
		cTpProc := BR8->BR8_TPPROC
		cClasse	:= BR8->BR8_CLASSE
		
		//Se não for Mat/Med/Txas - 1,2,3,4,5,7,8,9
		if ! cTpProc $ aTpMAT[4] 
			
			cCodPad := BD6->BD6_CODPAD
			cCodPro := BD6->BD6_CODPRO
		
			//Se for Consulta
			if PLSISCON(cCodPad,cCodPro)
				lConsulta := .t.
			else
				lConsulta := .f.
			endif
			
			if ! lConsulta .or. nValMax == 0
				nValMax := BD6->BD6_VLRAPR
			endIf	
				
		endif
		
	endIf
	
	BD6->(dbSkip())
	
endDo

BD6->(RestArea(aRegBD6))

return ( { cCodPad,cCodPro,lConsulta,cClasse,cTpProc } )

/*/{Protheus.doc} PLSBIGRELA
Função Generica para Inic. Pad. de campo maiores que o  X3_RELACAO
@type function
@author TOTVS
@since 25.05.06
@version 1.0
/*/
Function PLSBIGRELA(cCampo)
local xRet 		:= Nil
default	cCampo 	:= ""

if cCampo == "BCD_DESESP"
	xRet := Posicione("BAQ",1,xFilial("BAQ")+IIf(Type("M->BAX_CODINT")<>"U" .And. Inclui,M->(BAX_CODINT+BAX_CODESP),BCD->(BCD_CODINT+BCD_CODESP)),"BAQ_DESCRI")
endIf
	
return(xRet)

//TIPO DO SERVICO
/*
Adequação da RN 390 – Anexos – à função PlTpServ (PLSXFUN.PRW) – para retornar o Tipo de Serviço classificando os procedimentos.

7.1.2 O tipo de evento deverá considerar os seguintes conceitos:

==> AMBULATORIAIS
Procedimentos Odontológicos:
Total de atendimentos com fins de diagnóstico e orientação terapêutica em saúde bucal, em regime ambulatorial, de
caráter eletivo, urgência ou emergência.
->	Localização pela tabela padrão (BR8_ODONTO = '1'), independente do tipo de procedimento (BR8_TPPROC).

Consultas Médicas:
Total de atendimentos prestados por profissional habilitado pelo Conselho Regional de Medicina, com fins de
diagnóstico e orientação terapêutica, em regime ambulatorial, de caráter eletivo, urgência ou emergência.
->	Testa se o procedimento é uma consulta, somente em ambulatorial. Neste caso, quando há mais de um procedimento, a
classificação dos demais se dará pelo BFA e exceções serão classificadas em Demais Despesas Médico-Hospitalares.
Se não houver outro procedimento na guia, os itens juntos a Consulta serão classificados como Demais Despesas.

Outros Atendimentos Ambulatoriais:
Atendimentos realizados em regime ambulatorial de caráter eletivo, urgência ou emergência, incluindo honorários
profissionais, medicamentos, materiais e taxas (exceto consultas médicas, exames e terapias).
Inclui atendimentos com profissionais de nível superior.
->	Localizar somente pelo BFA, somente em ambulatorial. Neste caso, quando há mais de um procedimento, a
classificação dos demais se dará pelo BFA e exceções serão classificadas em Demais Despesas Médico-Hospitalares.

Exames:
Total de procedimentos de auxílio diagnóstico utilizados para complementar a avaliação do estado de saúde, em regime
ambulatorial, de caráter eletivo, urgência ou emergência, incluindo honorários profissionais, medicamentos, materiais
e taxas.
->	Localizar somente pelo BFA, somente em ambulatorial. Neste caso, quando há mais de um procedimento, será
considerado como principal o de maior valor, e a classificação se dará a partir dele.

Terapias:
Total de atendimentos utilizando métodos de tratamento, em regime ambulatorial, de caráter eletivo, urgência ou
emergência, incluindo honorários profissionais, medicamentos, materiais e taxas.
->	Localizar somente pelo BFA, somente em ambulatorial. Neste caso, quando há mais de um procedimento, será
considerado como principal o de maior valor, e a classificação se dará a partir dele.

Demais Despesas Médico-Hospitalares:
Despesas assistenciais médico-hospitalares, acessórias aos atendimentos de promoção da saúde, prevenção de doenças,
diagnóstico, tratamento e reabilitação do paciente, incluindo despesas não classificáveis nos demais itens deste anexo,
menos os descontos obtidos no pagamento de eventos. Incluem as atividades coletivas, aluguel de cadeiras de rodas,
remoção de paciente, campanha de vacinação, palestras, assistência farmacêutica.
->	Exceções não classificáveis nos demais itens deste anexo.

==> INTERNAÇÕES
Internações:
Total de internações prestadas a paciente admitido para ocupar leito hospitalar (enfermaria, quarto ou unidades de
curta permanência, terapia intensiva ou semi-intensiva) e classificados conforme o principal procedimento gerador
identificado por ocasião da alta hospitalar.
Para apurar o valor das internações, devem ser consideradas as despesas com hotelaria, honorários profissionais,
medicamentos, materiais, taxas, terapias e exames, conforme a especificidade da execução do item.
->	Tudo o que for lançado em tempo de internação.
*/
/*/{Protheus.doc} PlTpServ
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
function PlTpServ(cCodPad,cCodPro,cChvBen,cAliasCab)
local aArea		:= {}
local aAreaBR8	:= BR8->(GetArea())
local cTmp 		:= ""
local aCodPro 	:= {}
local aNivPro 	:= {}
local nTmp		:= 0
local lAchou	:= .f.
local lConsulta := .f.
local cGruGen	:= getNewPar('MV_PLSCTGR','0001')

local cMatricUsr:= " "
local lIntern	:= BD6->BD6_TIPGUI $ '05,06'
local cRet		:= ""
local aTpMAT	:= strTokarr(allTrim( getNewPar("MV_PLSTPMA","0,6|1,2,3,4,5,7,8|9|1,2,3,4,5,7,8,9") ), "|")  
local lClaTpEve	:= .f.
local cHorPro	:= BD6->BD6_HORPRO

Local aAreaBd5 := BD5->(Getarea())

private cClasse    	:= ""

default cCodPad 	:= BD7->BD7_CODPAD
default cCodPro 	:= BD7->BD7_CODPRO
default cChvBen		:= ""
default cAliasCab	:= PlRetAlias(BD7->BD7_CODOPE,BD7->BD7_TIPGUI)

if !empty(cAliasCab)

	aArea := (cAliasCab)->(getArea())

	if cAliasCab $ 'BE4/BD5'
		
		cChavCab := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)

		(cAliasCab)->( dbSetOrder(1) )
		if (cAliasCab)->( msSeek( xFilial(cAliasCab) + cChavCab ) )
			cMatricUsr	:= BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
		endIf	
		
	else
		cMatricUsr := cChvBen
	endIf
	
endIf

//Se nao for paciente internado
if !lIntern
	
	BR8->( dbSetOrder(1) )//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
	if BR8->( msSeek( xFilial('BR8') + cCodPad + cCodPro ) )
	
		cTpProc	:= BR8->BR8_TPPROC
		
		//Procedimentos Odontológicos
		if BR8->BR8_ODONTO == '1'

			BI3->(dbSetOrder(5)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO
			if BI3->( msSeek( xFilial("BI3") + BD6->(BD6_OPEUSR + BD6_CODPLA) ) )
				
				BI6->(dbSetOrder(1)) //BI6_FILIAL+BI6_CODSEG
				if BI6->( msSeek( xFilial("BI6") + BI3->BI3_CODSEG ) )
				
					//verifica se é uma operadora odontologica ou se somente comercializa produto odonto (opcionais)
					if BI6->BI6_MEDICO == '0' .and. BI6->BI6_ODONTO == '1' .and. BI3->BI3_TPFORN == '2' .and. ! empty(BI3->BI3_SUSEP)
						lClaTpEve := .t.
					endIf
				
				endIf
				
			endIf
			
			//outros atendimentos ambulatoriais
			if ! lClaTpEve
				cRet := '12'
			endIf	
			
		else
			
			lClaTpEve := .t.
			
		endIf
		
		If BD6->BD6_TIPGUI =='01'
			cRet := '01'
			lClaTpEve := .F.
		EndIf
		//classificacao do evento
		if lClaTpEve
			
			BD5->(dbSetorder(1))
			If BD5->(MsSeek(xfilial('BD5') + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_NUMERO))) .AND. !(empTy(BD5->(BD5_GUIINT)))
				cRet := '06'
			EndIf
			BD5->(restArea(aAreaBd5))
			
			If !(empTy(cret))
		        do case
		        
		            // Tipo do Item = Procedimento ou Pacote - pode ser Consulta, Exames ou Terapias '0|6'
		            case cTpProc $ aTpMAT[1]
		                
		                // Testa se é Consulta // 01 - Consultas
		                if PLSISCON(cCodPad,cCodPro)
		                    cRet := '01'		
		                endIf
		                
		            //1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;7=Gases Medicinais;8=Alugueis;	
		            case cTpProc $ aTpMAT[2]
		                
		                aCodPro		:= PlVlMatM()
		                
		                cCodPad		:= aCodPro[1]
		                cCodPro		:= aCodPro[2]
		                lConsulta	:= aCodPro[3]
		                cClasse		:= aCodPro[4]
		                cTpProc		:= aCodPro[5]
		                
		                // Se for Mat/Med/Txas e Consulta - Não classifica mat-med-etc como consulta, classifica em Outros
		                if lConsulta
		                    cRet := "12" //Outros Atendimento Ambulatoriais
		                endif
		                
		            // Outros Atendimentos
		            case cTpProc == aTpMAT[3]
		                
		                cRet := "12" //Outros Atendimento Ambulatoriais
		
		        endCase
           endIf 

            // Se não classificou ainda, para Exames, Terapias ou Mat/Med classificados no procedimento principal
            if empty(cRet)
                
                BF0->( dbsetorder(1) ) //BF0_FILIAL+BF0_GRUGEN+BF0_CODIGO
                BFA->( dbsetorder(2) ) //BFA_FILIAL+BFA_CODPSA+BFA_GRUGEN+BFA_CODIGO

                if BFA->( msSeek(xFilial("BFA") + cCodPro + space(TamSX3("BFA_CODPSA")[1] - Len(cCodPro)) + cGruGen ) )
                    
                    if BF0->( msSeek( xFilial("BF0") + cGruGen + BFA->BFA_CODIGO ) )
                    		cRet := BF0->BF0_TPUNIM
                    endIf
                    
                else
                    
                    lAchou  := .f.
                    aNivPro := PLSESPNIV(cCodPad)
                    
                    For nTmp := 1 to aNivPro[1]
                    
                        cTmp := substr(cCodPro,aNivPro[2][nTmp][1],aNivPro[2][nTmp][2])
                        cTmp += replicate("0",(7 - aNivPro[2][nTmp][2]))
                        
                        if BFA->(MsSeek(xFilial("BFA") + cTmp + space(TamSX3("BFA_CODPSA")[1] - Len(cTmp)) + cGruGen))
                            
                            if BF0->( MsSeek( xFilial("BF0") + cGruGen + BFA->BFA_CODIGO ) )

                                cRet	:= BF0->BF0_TPUNIM
                                lAchou 	:= .t.
                                exit
                                
                            endif
                            
                        endif
                        
                    next
                    
                endIf
                
            endIf
		
		endIf
	
	endIf
	
    if EmpTy(cRet)
        cRet := "13"		// Demais Despesas Assistenciais
    endIf
//Paciente internado
else 
	
	cRet := "06" 

endIf

if existBlock("PLGRPPRO")
	cRet := execblock("PLGRPPRO",.F.,.F.,{cRet,cTpProc,cCodPad,cCodPro,cGrugen,lHonorario,cAliasCab})
endIf

BR8->(restArea(aAreaBR8))

if !empty(cAliasCab)
	(cAliasCab)->(RestArea(aArea))
endIf	
	
return(cRet)

/*/{Protheus.doc} PLSREFAUA
Verifica se a unidade pode aceitar referencia maior que 1
@type function
@author TOTVS
@since 25.05.06
@version 1.0
/*/
Function PLSREFAUA(cUnidade,nRef)
local lRet := .t.
local oHelp := nil
// Verifica se foi informado a unidade
if upper(cUnidade) == 'AUA'
	if 	nRef > 1
		lRet := .f.
		PLShelp("Não é permitido digitar referência maior que 1 para a unidade AUA")
	endIf
endIf
return(lRet)

/*/{Protheus.doc} PLSFILDAD
Filtro de dados com browse de exibiçao
@type function
@author TOTVS
@since 17.07.2008
@version 1.0
/*/
Function PLSFILDAD(cPerg)
LOCAL nI		 := 0
LOCAL cIniPad 	 := ""
LOCAL cBox 		 := ""
LOCAL cPicture 	 := ""
LOCAL bCol		 := ""
LOCAL aCoors  	 := FWGetDialogSize( oMainWnd )
LOCAL aCampos	 := {}
LOCAL aHeader	 := {}
LOCAL aCols		 := {}
LOCAL aMatLin	 := {}
LOCAL aMatCol	 := {}
LOCAL aField	 := {}
LOCAL oDlg		 := nil
LOCAL oGetDad	 := nil
LOCAL oObjGrid	 := nil
LOCAL oCheck	 := nil
LOCAL oTop 		 := nil
LOCAL oDown		 := nil
LOCAL oFWLayer	 := nil
LOCAL lCheck	 := .f.
PRIVATE _lChkAll := .f.
// pergunte relacionado
pergunte(cPerg,.f.)
// monta afield conforme sx1
SX1->(dbSetOrder(1))
if SX1->(dbSeek(cPerg))
	
	nI := 1
	while !SX1->(eof()) .and. allTrim(SX1->X1_GRUPO) == allTrim(cPerg)
		// se o mv existir
		if type('mv_par'+strZero(nI,2)) <> "U"
			// se nao informada a picture defini como padrao
			cIniPad := &('mv_par'+strZero(nI,2))
			// verifica se e box
			if upper(SX1->X1_GSC) == "C"
				if !empty(SX1->X1_DEF01)
					cBox := "1="+SX1->X1_DEF01
				endIf
				if !empty(SX1->X1_DEF02)
					cBox += ";2="+SX1->X1_DEF02
				endIf
				if !empty(SX1->X1_DEF03)
					cBox += ";3="+SX1->X1_DEF03
				endIf
				if !empty(SX1->X1_DEF04)
					cBox += ";4="+SX1->X1_DEF04
				endIf
				if !empty(SX1->X1_DEF05)
					cBox += ";5="+SX1->X1_DEF05
				endIf
			endIf
			// se nao informada a picture defini como padrao
			if empty(SX1->X1_PICTURE)
				if upper(SX1->X1_TIPO) == 'C'
					cPicture := "@!"
				elseif upper(SX1->X1_TIPO) == 'D'
					cPicture := "@D"
				elseif upper(SX1->X1_TIPO) == 'N'
					cPicture := "@"+replicate("9",SX1->X1_TAMANHO)
				endIf
			endIf
			// monta a field's
			aadd(aField,{SX1->X1_PERGUNT,SX1->X1_VAR01,SX1->X1_TIPO,SX1->X1_TAMANHO,SX1->X1_DECIMAL,cPicture,SX1->X1_VALID,.f.,1,cIniPad,SX1->X1_F3,,.f.,.f.,cBox,,.f.,,})
		endIf
		nI++
		SX1->(dbSkip())
	endDo
else
	aviso( "Atenção","Pergunta não localizado no SX1",{ "OK" }, 2 )
	return
endIf
// MsDialog
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3]-100,aCoors[4]-350,"Filtro de dados",,,,,,,,,.T.)
// Cria o conteiner onde serão colocados browse's
oFWLayer := FWLayer():New()
oFWLayer:init( oDlg, .f.)
// Divisao da tela em duas linhas de 50%
oFWLayer:addLine('Top'	,50,.f.)
oFWLayer:addLine('Down'	,100,.f.)
// layer top e down
oTop  := oFWLayer:getLinePanel('Top')
oDown := oFWLayer:getLinePanel('Down')
// mget
oGetDad 				:= msMGet():new(/*cAlias*/,0,3,/*uPar4*/,/*uPar5*/,/*uPar6*/,/*aCampos*/,{oTop:nTop,oTop:nLeft,oTop:nBottom,oTop:nRight/2},/*aCampos*/,/*nModelo*/,/*uPar11*/,/*uPar12*/,/*uPar13*/,oTop,/*lF3*/,/*lMemoria*/,.f.,/*caTela*/,/*lNoFolder*/,.t.,aField,/*aFolder*/,.t.,/*lNoMDIStretch*/,/*uPar25*/)
oGetDad:oBox:align 	:= CONTROL_ALIGN_ALLCLIENT
// botoes
tButton():New(007,358, "Executar"	,oDown,{|| PLSEXEFIL(1,cPerg,oObjGrid,aMatCol,aMatLin) }, 040, 010,,,,.t.)
tButton():New(007,399, "Cancelar"	,oDown,{|| aMatLin := {}, PLSSELATU(oObjGrid,aMatLin) }, 040, 010,,,,.t.)
// primeira pesquisa e monta header do grid
PLSEXEFIL(0,cPerg,oObjGrid,aMatCol,aMatLin)
// Browse
oObjGrid := PLSSELOPT("","Marca e Desmarca todos",aMatLin,aMatCol,K_Incluir,.t.,.t.,.f.,oDown,000,006,oDown:nHeight/4.7,oDown:nWidth/2)

oDlg:lCentered	:= .T.
oDlg:activate()
return(nil)

/*/{Protheus.doc} PLSEXEFIL
Executa filtro de dados para selecao
@type function
@author TOTVS
@since 17.07.2008
@version 1.0
/*/
Function PLSEXEFIL(nTp,cPerg,oObjGrid,aMatCol,aMatLin)
LOCAL cSql := ""
// Monta query confirme cada filtro
do case
	// pagamento
case cPerg == "PLA470"
	// define o nome de cada coluna
	if nTp == 0
		aadd(aMatCol,{"Ope + Local + PEG"	,'@!',050,.t.} )
		aadd(aMatCol,{"Cod. Rda"			,'@!',040,.t.} )
		aadd(aMatCol,{"Nome da Rda"			,'@!',200,.t.} )
		// query
	else
		cSql := " SELECT BCI_CODOPE+BCI_CODLDP+BCI_CODPEG AS PEG,BCI_CODRDA,BCI_NOMRDA "
		cSql += "   FROM "+BCI->(retSQLName("BCI"))
		cSql += "  WHERE BCI_FILIAL = '"+xFilial("BCI")+"' "
		cSql += "    AND BCI_CODRDA BETWEEN '"+MV_PAR29+"' AND '"+MV_PAR30+"' "
		cSql += "    AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY BCI_CODRDA "
	endIf
endCase
// executa query
if !empty(cSQL)
	cSQL := changeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBFIL",.F.,.T.)
	// monta dados
	aMatLin := {}
	while !TRBFIL->(eof())
		aadd(aMatLin,{TRBFIL->PEG,TRBFIL->BCI_CODRDA,TRBFIL->BCI_NOMRDA,.F.})
		TRBFIL->(dbSkip())
	endDo
	TRBFIL->(dbclosearea())
	// atualiza browse
	if len(aMatLin)>0
		PLSSELATU(oObjGrid,aMatLin)
	endIf
	
endIf

return(nil)

/*/{Protheus.doc} PLSRETROT
Retona da aRotina a opcao de comportacao do menu
@type function
@author TOTVS
@since 17.07.2008
@version 1.0
/*/
Function PLSRETROT(nOpc)
return(iIf(! empty(aRotina) .and. len(aRotina[1])>=4,aRotina[nOpc,4],0))

/*/{Protheus.doc} PLSGUIJUR
(long_description)
@type function
@author TOTVS
@since 12/25/12
@version 1.0
/*/
Function PLSGUIJUR(cMenVar,lDireto)
LOCAL aCritJur 	:= {}
LOCAL lForcar  	:= .F.
local cVar  	:= ""
local lRet	    := .T.
DEFAULT lDireto := .F.

// Reinicia o registrador.
__aGuiJur := {.F.,.F.}

If cMenVar == "BE1_GUIJUR"
	If Type("M->BE1_GUIJUR")=="C"
		cVar := M->BE1_GUIJUR
	Endif
	
Elseif cMenVar == "B01_GUIJUR"
	If Type("M->B01_GUIJUR")=="C"
		cVar := M->B01_GUIJUR
	Endif
	
Elseif cMenVar == "BE4_GUIJUR"
	If Type("M->BE4_GUIJUR")=="C"
		cVar := M->BE4_GUIJUR
	Endif
	
Endif

If !Empty(cVar)
	If cVar == "1"
		If PLSPOSGLO(PLSINTPAD(),__aCdCri09Z[1],__aCdCri09Z[2],"1")
			
			If !BCT->( MsSeek(xFilial("BCT")+PlsIntPad()+__aCdCri09Z[1]) )
				If !lDireto
					MsgAlert("A critica não foi localizada: as regras da guia juridica não serão consideradas.")
				Endif
				
				// Registra que nao permitiu seguir em frente com a guia juridica.
				__aGuiJur[1] := .f.
				__aGuiJur[2] := .f.
				
				// Não permite continuar com guia = SIM.
				lRet := .F.
			Else
				AaDd(aCritJur,{__aCdCri09Z[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"",""})
				
				// Se definiu Auditoria, avisa que os procedimentos irao para auditoria
				If BCT->BCT_AUDITO == "1"
					AaDd(aCritJur,{""   ,"A guia será enviada para auditoria, conforme definição da crítica.","","","","",""}) //"Quantidade/Valor do procedimento"
				Endif
				
				// Permite forcar ?
				If !lDireto
					lForcar := BCT->BCT_PERFOR=="1"
					lForcou := PLSMOVCRI("1",{"","","",""},aCritJur,lForcar)
				Endif
				
				If lForcar .and. !lForcou
					If !lDireto
						MsgAlert("A critica não foi forçada: as regras da guia juridica não serão consideradas.")
					Endif
					// Registra que nao permitiu seguir em frente com a guia juridica.
					__aGuiJur[1] := .f.
					__aGuiJur[2] := .f.
					
					// Não permite continuar com guia = SIM.
					lRet := .F.
				Else
					// Registra que permitiu seguir em frente com a guia juridica.
					__aGuiJur[1] := .T.
					
					If BCT->BCT_AUDITO == "1"
						// Registra que deve mandar a guia pra auditoria.
						__aGuiJur[2] := .T.
					Endif
				Endif
			Endif
		Else
			If !lDireto
				help("",1,"PLSGUIJU1")
			Endif
			
			// A critica nao esta ativa: registra que nao podera seguir em frente.
			__aGuiJur[1] := .f.
			__aGuiJur[2] := .f.
			
			// Não permite continuar com guia = SIM.
			lRet := .F.
		EndIf
	Else
		// Informou nao: registra que nao podera seguir em frente.
		__aGuiJur[1] := .f.
		__aGuiJur[2] := .f.
	Endif
EndIf

Return(lRet)

/*/{Protheus.doc} PlsGetJur
(long_description)
@type function
@author TOTVS
@since 12/26/12
@version 1.0
/*/
Function PlsGetJur()
Return(__aGuiJur)

/*/{Protheus.doc} PLSTrbGer
Retorna Alias de trabalho DIOPS
@type function
@author TOTVS
@since 03.06.09
@version 1.0
/*/
Function PLSTrbGer(cTipo)
Local aStru		:= {}
Local cArqTemp	:= ""
Local _aTotal
Local oTempTRB
If cTipo=='1'
	
	_aTotal:= GetSldPlGer( MV_PAR13, MV_PAR02, MV_PAR03, "01", 10 , .T.,.T. ,'1', , , .F., , .T., "01", , , .T. )
Else
	
	_aTotal:= GetSldPlGer( MV_PAR12, MV_PAR02, MV_PAR03, "01", 10 , .T.,.T. ,'1', , , .F., , .T., "01", , , .T. )
	
Endif
//cTipo : 1=Intercambio ; 2=Corresponsabilidade
DEFAULT cTipo	:= ""

If Select("TRB") > 0
	TRB->(dbCloseArea())
EndIf

// Caso a query não retorne valor preencho as tags com valor DEFAULT

aadd(aStru,{"SALDO1" ,"N",016,2})
aadd(aStru,{"SALDO2" ,"N",016,2})
aadd(aStru,{"SALDO3" ,"N",016,2})
aadd(aStru,{"SALDO4" ,"N",016,2})

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TRB" )
oTempTRB:SetFields( aStru )
oTempTRB:AddIndex( "INDTRB",{ "SALDO1" } )
	
if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf
	
oTempTRB:Create()

If _aTotal[1,4]+_aTotal[2,4]+_aTotal[3,4]+_aTotal[4,4] +_aTotal[6,4]+_aTotal[7,4]> 0
	
	DbSelectArea("TRB")
	TRB->(RecLock("TRB",.T.))
	TRB->SALDO1 := Iif(cTipo=="1",_aTotal[3,4],_aTotal[1,4])
	TRB->SALDO2 := Iif(cTipo=="1",_aTotal[4,4],_aTotal[2,4])
	TRB->SALDO3 := Iif(cTipo=="1",_aTotal[6,4],0)
	TRB->SALDO4 := Iif(cTipo=="1",_aTotal[7,4],0)
	
	TRB->(MsUnlock())
Endif
	
Return

/*/{Protheus.doc} PLSXFUN
(long_description)
@type function
@author TOTVS
@since 05/28/13
@version 1.0
/*/
Function PLSPISCOF(ddataini,ddatafim,cAlias)
Local cQuery := ""
DEFAULT ddataini 	:= ddatabase
DEFAULT ddatafim 	:= ddatabase
DEFAULT cAlias 		:= "TRB"

If BFQ->(FieldPos("BFQ_BLOCOI"))<= 0
	Return(.F.)
Endif

//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
cQuery:= " SELECT BFQ_BLOCOI CLASS, BM1_TIPO TIPO , BM1_VALOR VALOR , BM1_PREFIX PREFIXO, BM1_NUMTIT NUMERO, BM1_TIPTIT TIPTIT, BM1_CODTES TES,"
cQuery+=" BM1_DOCSF2 NOTA,BM1_SERSF2 SERIE, BM1_CSTCOF CSTCOF, BM1_CSTPIS CSTPIS, BM1_NATURE NATUREZA,D2_CLIENTE CLIENTE, D2_LOJA LOJA, "
cQuery+=" FT_TNATREC NATREC, FT_CNATREC CNATREC, FT_GRUPONC GRUPONC,FT_DTFIMNT DTFIMNT, FT_ALIQPIS ALIQPIS, FT_ALIQCOF ALIQCOF  "
cQuery+=" FROM "+RetSqlName("BM1") + " BM1 "
cQuery+=" INNER JOIN " +RetSqlName("BFQ")+" BFQ  ON   BFQ_FILIAL ='"+Xfilial('BFQ')+"' AND  BFQ_CODINT=BM1_CODINT  AND BFQ_PROPRI||BFQ_CODLAN=BM1_CODTIP AND  "
cQuery+=" BFQ.D_E_L_E_T_=' '  "
cQuery+=" LEFT JOIN " +RetSqlName("SD2")+" SD2  ON   D2_FILIAL ='"+Xfilial('SD2')+"' AND  D2_NUMSEQ=BM1_SEQSD2 AND "
cQuery+=" SD2.D_E_L_E_T_=' '  "
cQuery+=" LEFT JOIN " +RetSqlName("SFT")+" SFT  ON   FT_FILIAL ='"+Xfilial('SFT')+"' AND FT_SERIE=BM1_SERSF2 AND FT_NFISCAL=BM1_DOCSF2 AND "
cQuery+=" FT_CLIEFOR=D2_CLIENTE AND FT_LOJA=D2_LOJA AND FT_PRODUTO=D2_COD AND FT_ITEM= D2_ITEM AND FT_TIPOMOV='S' AND "
cQuery+=" SFT.D_E_L_E_T_=' '  "
cQuery+=" WHERE  BM1_MES BETWEEN '"+Substr(dtos(ddataini),5,2)+"' AND '"+Substr(dtos(ddatafim),5,2)+"' AND  "
cQuery+=" BM1_ANO  BETWEEN '"+Substr(dtos(ddataini),1,4)+"' AND '"+Substr(dtos(ddatafim),1,4)+"' AND  "
cQuery+=" BM1_DOCSF2 <> ' '  AND  "
cQuery+=" BM1.D_E_L_E_T_= ' '  "

cQuery+= " UNION "

cQuery+= " SELECT BFQ_BLOCOI CLASS, BM1_TIPO   TIPO,  BM1_VALOR  VALOR, BM1_PREFIX PREFIXO, BM1_NUMTIT NUMERO,  BM1_TIPTIT TIPTIT, BM1_CODTES TES,"
cQuery+="  BM1_DOCSF2 NOTA, BM1_SERSF2 SERIE, BM1_CSTCOF CSTCOF, BM1_CSTPIS CSTPIS, BM1_NATURE NATUREZA, E1_CLIENTE CLIENTE, E1_LOJA    LOJA, "
cQuery+="  ED_TABCCZ NATREC, ED_CODCCZ CNATREC, ED_GRUCCZ GRUPONC, ED_DTFCCZ DTFIMNT,ED_PCAPPIS ALIQPIS, ED_PCAPCOF ALIQCOF "
cQuery+="  FROM  "+RetSqlName("BM1")+" BM1"
cQuery+="  INNER JOIN "+RetSqlName("BFQ")+" BFQ  ON BFQ_FILIAL = '"+Xfilial("BFQ")+"' AND BFQ_CODINT = BM1_CODINT  AND BFQ_PROPRI|| BFQ_CODLAN = BM1_CODTIP AND"
cQuery+="  BFQ.D_E_L_E_T_ = ' ' "
cQuery+="  LEFT JOIN "+RetSqlName("SE1")+" SE1 ON E1_FILIAL = '"+xFilial("SE1")+"'   AND E1_PREFIXO = BM1_PREFIX AND E1_NUM = BM1_NUMTIT AND E1_TIPO = BM1_TIPTIT 	AND"
cQuery+="  E1_PARCELA = BM1_PARCEL AND "
cQuery+="  SE1.D_E_L_E_T_ = ' ' "
cQuery+="  LEFT JOIN "+RetSqlName("SED")+" SED ON ED_FILIAL = '"+xFilial("SED")+"'  AND ED_CODIGO = E1_NATUREZ  AND SED.D_E_L_E_T_ = ' ' "
cQuery+=" WHERE  BM1_MES BETWEEN '"+Substr(dtos(ddataini),5,2)+"' AND '"+Substr(dtos(ddatafim),5,2)+"' AND  "
cQuery+=" BM1_ANO  BETWEEN '"+Substr(dtos(ddataini),1,4)+"' AND '"+Substr(dtos(ddatafim),1,4)+"' AND  "
cQuery+=" BM1_DOCSF2 = ' '  AND  "
cQuery+=" BM1.D_E_L_E_T_= ' '  "

cQuery := ChangeQuery(cQuery)

If Select(cAlias) > 0
	&(cAlias+"->")(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)

Return(.T.)

/*/{Protheus.doc} PLQDOAUX
Retorna informação para o Quadro Auxiliar de Eventos- DIOPS
@type function
@author TOTVS
@since 07/22/13
@version 1.0
/*/
Function PLQDOAUX(ddataIni,dDatafim)
Local cSqlTmp:= " "
Local cSql := " "
Local cSqlRee:= " "
Local cCtpl14 := GetNewPar('MV_PLCT14','OPE')
Local cAnoIni :=Alltrim(Str(year(ddataIni)))
Local cMesIni :='01'
Local cAnoFin :=Alltrim(Str(year(ddatafim)))
Local cMesFin :=Alltrim(Strzero(Month(ddatafim),2))
Local cClas,cModPag,cBi3ApoSrg,cBi3TipCon,cBi3Tipo,cBi3CodSeg,cBi3ModPag,cTpPlan, cLei
LOCAL cDataBase := ""
Local nHandle  := 0
Local nHandle1 := 0
Local nHandle2 := 0
Local nHandle3 := 0

//Individual familiar
Local _bIndalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aIndalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _bIndplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aIndplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}


//Coletivo por adesão
Local _bColalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aColalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _bColplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aColplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}

// Coletivo empresarial

Local _bEmpalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aEmpalei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _bEmpplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}
Local _aEmpplei		:= {{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0},;
	{0,0,0,0,0,0}}

Local aRet:={}
Local cDir := ALLTRIM(MV_PAR16)

cDataBase := AllTrim(TCGetDB())
cSQL := "SELECT 'GUI' ALIAS, BD7_CODOPE CODOPE,BD7_CODEMP CODEMP,BD7_MATRIC MATRIC,BD7_TIPREG TIPREG,  BD7_CODPAD CODPAD, BD7_CODPRO CODPRO,BD7_ORIMOV ORIMOV, '' TPUNIM, "
cSQL += "BD7_CODRDA CODRDA, (BD7_VLRPAG-BD7_VLRTPF) VALORCUSTO, R_E_C_N_O_ NUMREG  FROM "+RetSqlName('BD7')+" WHERE "
cSQL += " BD7_FILIAL = '"+xFilial('BD7')+"'  "
cSQL += " AND BD7_NUMLOT >= '" + cAnoIni  + cMesIni  + "0000' AND BD7_NUMLOT <= '" + cAnoFin  + cMesFin+"9999' "
cSQL += " AND BD7_BLOPAG <> '1'  "
cSQL += "AND D_E_L_E_T_ = ' ' "

cSQL += " UNION "

cSQL += " SELECT 'BGQ' ALIAS, BGQ_CODOPE CODOPE,BGQ_CODEMP CODEMP,BGQ_MATRIC MATRIC, BGQ_CODLAN TIPREG, '' CODPAD, ' ' CODPRO, ' ' ORIMOV, BGQ_TPUNIM TPUNIM, "
If cDataBase <> "MSSQL"
	cSQL += " BGQ_CODIGO CODRDA, SUM(DECODE(BBB_TIPSER,1,-1*BGQ_VALOR,BGQ_VALOR)) VALORCUSTO, 0 NUMREG "
Else
	cSQL += " BGQ_CODIGO CODRDA, SUM(CASE BBB_TIPSER WHEN 1 THEN -1*BGQ_VALOR ELSE BGQ_VALOR END) VALORCUSTO, 0 NUMREG "
Endif
cSQL += " FROM "+RetSqlName('BGQ')+" BGQ, "+RetSqlName('BBB')+" BBB "
//cSQL += " WHERE BGQ.BGQ_CODLAN <> '050' "  especifico CABERJ
cSQL += " WHERE BBB.BBB_FILIAL = '"+xFilial("BBB")+"' "
cSQL += " AND BBB.BBB_CODSER = BGQ.BGQ_CODLAN "
cSQL += " AND BGQ.BGQ_NUMLOT >= '" + cAnoIni  + cMesIni  + "0000' AND BGQ.BGQ_NUMLOT <= '" + cAnoFin  + cMesFin+"9999'  "
cSQL += " AND BGQ.BGQ_TPUNIM <> '"+SPACE(len(BGQ->BGQ_TPUNIM))+"' "
cSQL += " AND BGQ.D_E_L_E_T_ = ' ' "
cSQL += " AND BBB.D_E_L_E_T_ = ' ' "
If Existblock("PLQDFILBGQ")
	cSql +=Execblock("PLQDFILBGQ",.F.,.F.) //BGQ.BGQ_CODLAN <> '050' "  especifico CABERJ
Endif
cSQL += "GROUP BY BGQ_CODOPE,BGQ_CODEMP ,BGQ_MATRIC,BGQ_CODLAN, BGQ_CODIGO, BGQ_TPUNIM "

cSQL+= "UNION "

cSQL+= "SELECT 'OPM' ALIAS, BD6_CODOPE CODOPE,BD6_CODEMP CODEMP,BD6_MATRIC MATRIC,BD6_TIPREG TIPREG , BD6_CODPAD CODPAD, BD6_CODPRO CODPRO,'' ORIMOV, '' TPUNIM, "
cSQL+= "BD6_CODRDA CODRDA, SUM((D1_TOTAL -D1_VALDESC - BD6_VLRPF))  VALORCUSTO, 0 NUMREG "
cSQL+= "FROM "+RetSqlName('B19')+" B19, "+RetSqlName('SD1')+" SD1,"+RetSqlName('SF1')+" SF1, "+RetSqlName('BD6')+" BD6 "
cSQL+= "WHERE  "
cSQL+= "SF1.F1_EMISSAO BETWEEN '"+DTOS(DDATAINI)+"' AND '"+DTOS(DDATAFIM)+"' "
cSQL+= " AND SD1.D1_DOC = SF1.F1_DOC "
cSQL+= " AND B19.B19_DOC = SD1.D1_DOC "
cSQL+= " AND SD1.D1_ITEM = B19.B19_ITEM "
cSQL+= " AND BD6.BD6_FILIAL = '"+xFilial('BD6')+"' "
If cDataBase <> "MSSQL"
	cSQL+= " AND BD6_CODOPE = SubStr(B19_GUIA,01,04) "
	cSQL+= " AND BD6_CODLDP = SubStr(B19_GUIA,05,04) "
	cSQL+= " AND BD6_CODPEG = SubStr(B19_GUIA,09,08) "
	cSQL+= " AND BD6_NUMERO = SubStr(B19_GUIA,17,08) "
	cSQL+= " AND BD6_ORIMOV = SubStr(B19_GUIA,25,01) "
	cSQL+= " AND BD6_SEQUEN = SubStr(B19_GUIA,26,03) "
Else
	cSQL+= " AND BD6_CODOPE = SubString(B19_GUIA,01,04) "
	cSQL+= " AND BD6_CODLDP = SubString(B19_GUIA,05,04) "
	cSQL+= " AND BD6_CODPEG = SubString(B19_GUIA,09,08) "
	cSQL+= " AND BD6_NUMERO = SubString(B19_GUIA,17,08) "
	cSQL+= " AND BD6_ORIMOV = SubString(B19_GUIA,25,01) "
	cSQL+= " AND BD6_SEQUEN = SubString(B19_GUIA,26,03) "
Endif
cSQL+= " AND BD6_FASE IN (3,4) "
cSQL+= " AND B19.D_E_L_E_T_ = ' ' "
cSQL+= " AND SD1.D_E_L_E_T_ = ' ' "
cSQL+= " AND SF1.D_E_L_E_T_ = ' ' "
cSQL+= " AND BD6.D_E_L_E_T_ = ' ' "
cSQL+= " GROUP BY BD6_CODOPE,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_CODPAD, BD6_CODPRO,BD6_CODRDA  "

cSQL+= "UNION "


cSQL+= " SELECT 'REE' ALIAS, B44_OPEUSR CODOPE, B44_CODEMP CODEMP, B44_MATRIC MATRIC, B44_TIPREG TIPREG, B45_CODPAD CODPAD, B45_CODPRO CODPRO, ' ' ORIMOV, '' TPUNIM, "
cSQL+= " '' CODRDA, SUM(B45_VLRPAG) VALORCUSTO, 0 NUMREG "
cSQL+= " FROM "+RetSqlName('B44')+" B44," +RetSqlName('B45')+" B45, "+RetSqlName('SE1')+" SE1 "
cSQL+= " WHERE B45_FILIAL='"+xFilial('B45')+"'  "
cSQL+= " AND B44_FILIAL='"+xFilial('B44')+"' "
cSQL+= " AND E1_FILIAL='"+xFilial('SE1')+"' "

If Existblock("PLQDFILREE")
	cSql +=Execblock("PLQDFILREE",.F.,.F.)    ////cSQL+= " AND E1_PREFIXO='RLE' "
Endif
cSQL+= " AND B44_CODLDP=B45_CODLDP "
cSQL+= " AND B44_CODPEG=B45_CODPEG "
cSQL+= " AND B44_NUMAUT=B45_NUMAUT "
cSQL+= " AND B44_PREFIX =E1_PREFIXO "
cSQL+= " AND B44_NUM=E1_NUM "
cSQL+= " AND B44.D_E_L_E_T_ = ' ' "
cSQL+= " AND B45.D_E_L_E_T_=' ' "
cSQL+= " AND SE1.D_E_L_E_T_=' '  "
cSql+="  AND E1_EMISSAO BETWEEN '"+dtos(ddataini)+"' AND '"+dtos(ddatafim)+"' "
cSQL+= " GROUP BY  B44_OPEUSR, B44_CODEMP,B44_MATRIC, B44_TIPREG, B45_CODPAD, B45_CODPRO "

cSQL+= " ORDER BY ALIAS "


cSQL := ChangeQuery(cSql)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"PLQDOAUX",.T.,.F.)
TcSetField("PLQDOAUX", 'VALORCUSTO', 'N', 18, 2)

If PLQDOAUX->(!EOF())
	If MV_PAR15 == 1
		// criar arquivo texto vazio a partir do root path no servidor
		nHandle := FCREATE(cDir+"\TRBGUIAS.txt")
		If nHandle = -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})
		EndIf
		nHandle1 := FCREATE(cDir+"\TRBRREMB.txt")
		If nHandle1 = -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})
		EndIf
		nHandle2 := FCREATE(cDir+"\TRBOPME.txt")
		If nHandle2 = -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})
		EndIf
		nHandle3 := FCREATE(cDir+"\TRBBGQ.txt")
		If nHandle3 = -1
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',"Erro ao criar arquivo - ferror " + Str(Ferror()) , 0, 0, {})
		EndIf
		
	EndIf
Endif


While PLQDOAUX->(!EOF())
	
	BA1->(DbSetOrder(2))
	If BA1->(Dbseek(xFilial("BA1")+ PLQDOAUX->(CODOPE+CODEMP+MATRIC+TIPREG))) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
		
		BA3->(Dbseek(xFilial("BA3")+ PLQDOAUX->(CODOPE+CODEMP+MATRIC))) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
		
		//POSICIONAR PRODUTO - BUSCAR BI3
		If Empty(BA1->BA1_CODPLA)
			cPlano	:= BA3->BA3_CODPLA+BA3->BA3_VERSAO
			cCodPla := BA3->BA3_CODPLA
			cOpeOri := BA3->BA3_CODINT
		Else
			cPlano	:= BA1->BA1_CODPLA+BA1->BA1_VERSAO
			cCodPla := BA1->BA1_CODPLA
			cOpeOri := BA1->BA1_OPEORI
		EndIf
	Else
		cPlano	:= ""
		cCodPla := ""
	Endif
	
	If Select('TRBBI3') > 0
		TRBBI3->(dbCloseArea())
	EndIf
	cSqlTmp	:= "SELECT BI3_MODPAG, BI3_APOSRG, BI3_TIPCON, BI3_TIPO, BI3_CODSEG, BI3_TPBEN FROM "
	cSqlTmp += RetSqlName('BI3')+" WHERE BI3_FILIAL = '"
	cSqlTmp	+= xFilial('BI3')+"' AND BI3_CODINT = '"+PLSINTPAD()+"' AND "
	csqlTmp	+= "BI3_CODIGO = '"+cCodPla+"' AND BI3_VERSAO = '"+SUBS(cPlano, Len(cCodPla)+1 )
	cSqlTmp	+= "' AND D_E_L_E_T_ = ' ' "
	cSqlTmp	:= ChangeQuery(cSqlTmp)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlTmp),"TRBBI3",.T.,.F.)
	
	If TRBBI3->(!EOF())
		
		cBi3ApoSrg := TRBBI3->BI3_APOSRG
		cBi3TipCon := TRBBI3->BI3_TIPCON
		cBi3Tipo   := TRBBI3->BI3_TIPO
		cBi3CodSeg := TRBBI3->BI3_CODSEG
		cBi3ModPag := TRBBI3->BI3_MODPAG
	Endif
	
	TRBBI3->(dbCloseArea())
	
	cModPag	:= IIf( AllTrim(cBi3ModPag) $'1', '1', '2' )   // 1- preço pre estabelecido / 2- preço pos estabelecido
	
	
	//Tipo de Plano:
	//Individual/familiar;
	//Coletivo por Adesão;
	//Coletivo empresarial.
	
	If cBi3Tipo == "1"	//BI3_TIPO => 1=Pessoa Fisica;2=Pessoa Juridica;3=Ambas
		cTpPlan := "ind"	// 1 - Individual / Familiar
	Else
		cTpPlan	:= IIF(cBi3TipCon=='2',"Col","Emp")		// 1=Individual/familiar;2=Coletivo Empresarial;3=Coletivo Adesao
	Endif
	
	//Antes da Lei (Não regulamentado);
	//Após Lei (Regulamentado)
	cLei	:= IIf( cBi3ApoSrg == '1', 'plei', 'alei' )
	
	//Classificação do procedimento:
	//Consulta Médica;
	//Exames;
	//Terapias;
	//Internações;
	//Outros atendimentos;
	//Demais despesas.
	//
	
	cClas := IIF(PLQDOAUX->ALIAS =='BGQ',PLQDOAUX->TPUNIM, IIF(!EMPTY(PLQDOAUX->CODPRO),PlTpServ(,PLQDOAUX->CODPAD,PLQDOAUX->CODPRO),""))
	
	If cClas $ "01" // consulta
		nCategoria := 1
	ElseIf cClas $ "02/03"//exames
		nCategoria := 2
	ElseIf cClas $ "04/05"  //terapias
		nCategoria := 3
	ElseIf cClas $ "06/07/08/09/10/11" .OR. PLQDOAUX->ALIAS ='OPM' //internações
		nCategoria := 4
	ElseIf cClas ="12"
		nCategoria := 5
	Else
		nCategoria := 6
	Endif
	
	IF PLQDOAUX->ALIAS =='GUI'
		BD7->(dbGoto(PLQDOAUX->NUMREG))

		If BD7->BD7_TIPGUI <>'03'
			If BD5->(DbSeek(Xfilial("BD5")+BD7->BD7_CODOPE+BD7->BD7_CODLDP+BD7->BD7_CODPEG+BD7->BD7_NUMERO )) .and. !Empty(BD5->BD5_GUIINT)
				nCategoria := 4
			Endif
		Endif
		
	ENDIF
	
	//Tipo de Rede :
	//Rede Própria
	//Rede Contratada
	//Reembolso
	//Intercâmbio Eventual
	
	//REDE DE ATENDIMENTO  -   BUSCAR DO BAU
	If Select('TRBBAU') > 0
		TRBBAU->(dbCloseArea())
	EndIf
	
	cSqlTmp := "SELECT BAU_EST, BAU_TIPPRE, BAU_COPCRE, BAU_RECPRO FROM "
	cSqlTmp += RetSqlName('BAU')+" WHERE BAU_FILIAL = '"
	cSqlTmp	+= xFilial('BAU')+"' AND BAU_CODIGO = '"+ PLQDOAUX->CODRDA
	cSqlTmp	+= "' AND D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSqlTmp)),"TRBBAU",.T.,.F.)
	
	cBauEst		:= TRBBAU->BAU_EST
	cBauTipPre	:= TRBBAU->BAU_TIPPRE
	cBauCopCre	:= TRBBAU->BAU_COPCRE
	cBauRecPro	:= TRBBAU->BAU_RECPRO
	
	TRBBAU->(dbCloseArea())
			
	Do Case
		
	Case PLQDOAUX->ALIAS ='REE'
		nTpRede:= 3 // reembolso
		
	Case cBauCopCre $ '1/3'  .or. ( cBauCopCre $ '2' .and. cBauRecPro $ '1' )
		nTpRede:= 1        // rede própria
		
	Case cBauCopCre == '2'
		nTpRede:= 2  //rede conveniada
		
		// Nao Cooperados - Todas as classes...
		
	Case cBauTipPre $ cCtpl14
		nTpRede:= 4 // intercambio
		// Outras opcoes
	OtherWise
		nTpRede	:= 0
		
	EndCase
	
	If cModPag == "1"   //pre pagamento
		
		bExec := &("{|| _b"+Alltrim(cTpPLan)+Alltrim(cLei)+"[nTpRede][nCategoria] += PLQDOAUX->VALORCUSTO }")
		Eval(bExec)
	Else
		bExec := &("{|| _a"+Alltrim(cTpPLan)+Alltrim(cLei)+"[nTpRede][nCategoria] += PLQDOAUX->VALORCUSTO }")
		Eval(bExec)
	Endif
	
	If MV_PAR15 == 1 .and. nHandle > 0 .and. PLQDOAUX->ALIAS=="GUI"
		cStr := Str(PLQDOAUX->NUMREG,20,0)+';'+PLQDOAUX->ALIAS+';'+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)+";"+BD7->BD7_SEQUEN+";"+BD7->BD7_CODPAD+";"
		cStr += BD7->BD7_CODPRO+";"+BD7->BD7_CODUNM+";"+Str(PLQDOAUX->VALORCUSTO,20,2)
		FWrite(nHandle, cStr + CRLF)
	EndIf
	
	If MV_PAR15 == 1 .and. nHandle1 > 0 .and. PLQDOAUX->ALIAS=="REE"
		cStr:= Str(PLQDOAUX->NUMREG,20,0)+";"+ PLQDOAUX->ALIAS+";"+PLQDOAUX->CODOPE+";"+PLQDOAUX->CODEMP+";"+PLQDOAUX->MATRIC+";"+PLQDOAUX->TIPREG+";"
		cStr+= PLQDOAUX->CODPAD+";"+PLQDOAUX->CODPRO+";"+Str(PLQDOAUX->VALORCUSTO,20,2)
		FWrite(nHandle1, cStr + CRLF)
	EndIf
	
	If MV_PAR15 == 1 .and. nHandle2 > 0 .and. PLQDOAUX->ALIAS=="OPM"
		cStr:= Str(PLQDOAUX->NUMREG,20,0)+";"+PLQDOAUX->ALIAS+";"+ PLQDOAUX->CODOPE+";"+PLQDOAUX->CODEMP+";"+PLQDOAUX->MATRIC+";"
		cStr+= PLQDOAUX->TIPREG+";"+PLQDOAUX->CODPAD+";"+PLQDOAUX->CODPRO+";"+PLQDOAUX->CODRDA+";"+Str(PLQDOAUX->VALORCUSTO,20,2)
		FWrite(nHandle2, cStr + CRLF)
	EndIf
	
	If MV_PAR15 == 1 .and. nHandle3 > 0 .and. PLQDOAUX->ALIAS=="BGQ"
		cStr :=Str(PLQDOAUX->NUMREG,20,0)+';'+PLQDOAUX->ALIAS+';'+PLQDOAUX->CODOPE+";"+PLQDOAUX->CODEMP+";"+PLQDOAUX->MATRIC+";"
		cStr+=  PLQDOAUX->TIPREG+";"+PLQDOAUX->TPUNIM+";"+PLQDOAUX->CODRDA+";"+Str(PLQDOAUX->VALORCUSTO,20,2)
		FWrite(nHandle3, cStr + CRLF)
	EndIf
	
	PLQDOAUX->(Dbskip())
Enddo
PLQDOAUX->(DbCloseArea())

If MV_PAR15 == 1 .and. nHandle > 0
	FClose(nHandle)
EndIf

If MV_PAR15 == 1 .and. nHandle1 > 0
	FClose(nHandle1)
EndIf
If MV_PAR15 == 1 .and. nHandle2 > 0
	FClose(nHandle2)
EndIf

If MV_PAR15 == 1 .and. nHandle3 > 0
	FClose(nHandle3)
EndIf

aRet:={_bIndalei, _aIndalei,_bIndplei,_aIndplei,_bColalei,_aColalei,_bColplei,_aColplei,_bEmpalei,_aEmpalei,_bEmpplei,_aEmpplei}
//BGQ

// ponto de entrada para manipular dados  do Quadro Auxiliar de Eventos- DIOPS
if ExistBlock("PLSQDROEVE")
	aRetItens := aClone(aRet)
	aRet := ExecBlock("PLSQDROEVE", .f., .f., {aRet})
	If Len(aRet) > 0 .and. Valtype(aRet) = "A"
		aRet := aClone(aRetItens)
	Endif
endIf
Return(aRet)

/*/{Protheus.doc} PLSAMSKTB
Monta mascara virtualmente. Utilizado no campo BR8_CODPRO
@type function
@author TOTVS
@since 21/03/2012
@version 1.0
/*/
Function PLSAMSKTB(cTipo,cCodTabPro,cOri)
local cMascara	:= "@R "
local cRet		:= ''
local nRecBF8	:= BF8->(Recno())

default cCodTabPro	:= if(cTipo=="B",BR8->BR8_CODPAD,BR8->BR8_CODPSA)
default cOri		:= "G"

BF8->(dbClearFilter())
BF8->(dbSetOrder(1))

if ! BF8->(msSeek(xFilial("BF8")+cCodTabPro))
	if cOri == "G"
		cRet := "@!"+"%C"
	else
		cRet := "@!"
	endIf
	return(cRet)
endIf

while ! BF8->(Eof()) .And. BF8->(BF8_FILIAL+BF8_CODINT+BF8_CODIGO) == xFilial("BF8")+cCodTabPro
	cMascara += replicate("!",val(BF8->BF8_DIGITO))+BF8->BF8_SEPARA
	BF8->(dbSkip())
endDo

BF8->(dbGoTo(nRecBF8))

if cOri == "G"
	cRet := cMascara+"%C"
else
	cRet := cMascara
endIf

return(cRet)

/*/{Protheus.doc} PLBA8VLDP
Valida o codigo do procedimento da TDE.
(Executada no valido do campo BA8_CODPRO)

@author Totvs
@since 11/02/14
@version 1.0
/*/

Function PLBA8VLDP()
local lRet 	:= .t.
local cChar	:= ""
local nInd	:= 0
local _nTamCod := PLSRETCT()
Local _nTamSDg := Len(allTrim(M->BA8_CODPRO))
Local _nTamField := TamSX3("BA8_CODPRO")[1]
Local cTmp := ""

//*******
//_nTamCod variavel private definida no PLSABA8V
//*******
// Verifico se todos os caracteres sao numeros
// Apenas caso o tipo de tabela tenha digito verificador

If  lTemDig
	For nInd := 1 to len(rtrim(M->BA8_CODPRO))
		cChar := subStr(M->BA8_CODPRO,nInd,1)
		If isAlpha(cChar)
			Help(" ", 1, "ONLYNUM")
			Return(.f.)
		EndIf
	Next
	
	If _nTamSDg <> _nTamCod
		
		//Valida se codigo digitado + digito atinge o tamanho pre-determinado.
		If _nTamSDg+1 <> _nTamCod
		
			If Alltrim(FunName()) == "PLSA140"
				MsgAlert("Tamanho do Codigo Maior ou Menor que o parametrizado na estrutura")//"Tamanho do Codigo Maior ou Menor que o parametrizado na estrutura"
			Endif
			
			Return(.F.)
			
		Else
			
			If Alltrim(FunName()) == "PLSA140"
				cTmp := (substr(allTrim(M->BA8_CODPRO),1,_nTamCod) + modulo11(M->BA8_CODPRO))
				M->BA8_CODPRO := cTmp+Space(_nTamField-Len(cTmp))
			Else

				//Rotinas em MVC nao suportam atribuicao direta. Modificar diretamente o Model.
				oModel := FWModelActive()
				oModel:SetValue( 'PLSABA8MMD', 'BA8_CODPRO', (substr(allTrim(M->BA8_CODPRO),1,_nTamCod) + modulo11(M->BA8_CODPRO)))
				
			Endif
			
		Endif
	Else
		If substr(allTrim(M->BA8_CODPRO),_nTamSDg,1) <> Alltrim(modulo11(substr(allTrim(M->BA8_CODPRO),1,_nTamCod-1)))
			If Alltrim(FunName())=="PLSA140"
				MsgAlert("Digito verificador informado inválido")//"Digito verificador informado inválido"
			Endif
			Return(.F.)
		Else
			If Alltrim(FunName())<>"PLSA140"
				//Rotinas em MVC nao suportam atribuicao direta. Modificar diretamente o Model.
				oModel := FWModelActive()
				oModel:SetValue( 'PLSABA8MMD', 'BA8_CODPRO', allTrim(M->BA8_CODPRO))
			Endif
		Endif
	Endif
	
else
	If _nTamSDg <> _nTamCod
		If Alltrim(FunName())=="PLSA140"
			MsgAlert("Tamanho do Codigo Maior ou Menor que o parametrizado na estrutura")//"Tamanho do Codigo Maior ou Menor que o parametrizado na estrutura"
		Endif
		Return(.F.)
	EndIf
EndIf

return(lRet)

/*/{Protheus.doc} PLBA8VldVi
Verifica se a vigencia informada e inferior a data final de,
uma vigencia ja informada.
(Executada no valido do campo BD4_VIGINI e BD4_VIGFIM)

@author Totvs
@since 11/02/14
@version 1.0
/*/

Function PLBA8VldVi(dData,cUnidade,cOpe)
local lRet		:= .t.
local aArea 		:= BD4->(getArea())
local nRecBD4		:= iif(inclui,0,BD4->(recno()))

default dData   	:= ""
default cUnidade	:= ""
default cOpe    := ""

if empty(cUnidade)
	PLShelp(STR0076)//"Informe a Unidade de Medida"
	lRet := .f.
endIf

if lRet .and. cOpe == "I" .and. !empty(dData) .and. !empty(M->BD4_VIGFIM) .and. dData > M->BD4_VIGFIM
	PLShelp(STR0077)//"A data da Vigência Início informada é superior a data da Vigência Fim"
	lRet := .f.
elseIf lRet .and. cOpe == "F" .and. !empty(M->BD4_VIGINI) .and. !empty(dData) .and. dData < M->BD4_VIGINI
	PLShelp(STR0078)//"A data da Vigência Fim informada é inferior a data da Vigência Início"
	lRet := .f.
endIf

if lRet
	BD4->(dbSetOrder(1))//BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)
	if BD4->(msSeek(xFilial('BD4')+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)+M->BD4_CODIGO))
		
		while !BD4->(eof()) .and. xFilial('BD4')+BA8->(BA8_CODTAB+BA8_CDPADP+BA8_CODPRO)+M->BD4_CODIGO == BD4->(BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO)
			
			if BD4->(recno()) <> nRecBD4
				if PLSINTVAL("BD4","BD4_VIGINI","BD4_VIGFIM",dData,M->BD4_VIGINI,M->BD4_VIGFIM)
					PLShelp(STR0079)//"A data informada está entre um intervalo de vigências já utilizado"
					lRet := .f.
					exit
				endIf
			endIf
			
			BD4->(dbSkip())
		endDo
	endIf
	
endIf

BD4->(restArea(aArea))

return(lRet)

/*/{Protheus.doc} PLShelp
Exibe mensagem como HELP

@author Totvs
@since 11/02/14
@version 1.0
/*/
Function PLShelp(cMsg)
	
help(,,'HELP',,cMsg,1,0)
	
return

/*/{Protheus.doc} PLBF8VLC
Validacao do campo BF8_CODIGO

@author Totvs
@since 11/02/14
@version 1.0
/*/
Function PLBF8VLC(cCodInt)
local nRet    := 0
local nOrdBF8 := BF8->(IndexOrd())

BF8->(dbSetOrder(1))

BF8->(dbSeek(xFilial("BF8")+cCodInt+Replicate("9",Len(BF8->BF8_CODIGO)),.T.))
BF8->(dbSkip(-1))

if BF8->(BF8_FILIAL+BF8_CODINT) <> xFilial("BF8")+cCodInt
	nRet := StrZero(1,3)
else
	nRet := StrZero(Val(BF8->BF8_CODIGO)+1,3)
endif

BF8->(DbSetOrder(nOrdBF8))

return(nRet)

/*/{Protheus.doc} PLGETUNIC
Retorna o X2_UNICO ou primeiro indice da tabela

@author Totvs
@since 11/02/14
@version 1.0
/*/

Function PLGETUNIC(cTable)
local cUnico := ''
local cChave	:= ''
local nIdx	:= 1
Local cAlias := cTable

dbSelectArea(cTable)

SX2->(dbSetOrder(1))
if SX2->(msSeek(cTable))
	cUnico := allTrim(strTran(FWX2Unico(cTable),' ',''))
endIf

SIX->(dbSetOrder(1))

if SIX->(msSeek(cTable))
	nIdx 	:= val(SIX->ORDEM)
	cChave 	:= allTrim(strTran(SIX->CHAVE,' ',''))
	
	while !SIX->(eof()) .And. SIX->INDICE == cTable
		
		//Veririca se existe algum indice igual a chave unica da tabela e utiliza ele.
		if cUnico == cChave .or. empty(cUnico)
			nIdx := val(SIX->ORDEM)
			cChave := allTrim(strTran(SIX->CHAVE,' ',''))
			exit
		endIf
		
	SIX->(dbSkip())
	endDo

endIf
	
return( {nIdx,cChave} )

/*/{Protheus.doc} PLSRETNP
Retorna o nivel do procedimento BR4

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/

Function PLSRETNP(cCodPro,lTipo)
local nTam 	:= 1
local nReg := BR4->(recno())
local nOrd := BR4->(indexOrd())
local cRet := ''
local aNivel := {}
default lTipo := .f.

BR4->(dbSetOrder(1))
if BR4->(msSeek(xFilial("BR4")+BF8->BF8_CODPAD))
	
	while !BR4->(eof()) .and. BR4->(BR4_FILIAL+BR4_CODPAD) == xFilial("BR4")+BF8->BF8_CODPAD
		
		if BR4->BR4_DIGVER $ "0, "
			aadd(aNivel,{BR4->BR4_CODNIV,subStr(cCodPro,nTam,val(BR4->BR4_DIGITO))})
		endIf
		
		nTam += val(BR4->BR4_DIGITO)
		
		BR4->(dbSkip())
	endDo
	for nTam:=1 to len(aNivel)
		if val(aNivel[nTam,2])>0
			cRet := aNivel[nTam,1]
			
			//verificando se e 1=Analitico;2=Sintetico
			if lTipo
				cRet := '2'
				if len(aNivel) == nTam
					cRet := '1'
				endIf
			endIf
		endIf
	next
	if empty(cRet)
		cRet := '1'
	endIf
endIf

BR4->(dbGoTo(nReg))
BR4->(dbSetOrder(nOrd))
return(cRet)

/*/{Protheus.doc} PLSRETCT
Retorna tamanho do codigo TDE.

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/

Function PLSRETCT()
local nTam := 0
local nReg := BR4->(recno())
local nOrd := BR4->(indexOrd())

BR4->(dbSetOrder(1))
if BR4->(msSeek(xFilial("BR4")+BF8->BF8_CODPAD))
	
	while !BR4->(eof()) .And. BR4->(BR4_FILIAL+BR4_CODPAD) == xFilial("BR4")+BF8->BF8_CODPAD
		
		nTam += val(BR4->BR4_DIGITO)
		lTemDig := BR4->BR4_DIGVER = "1"
		
		BR4->(dbSkip())
	endDo
endIf

BR4->(dbGoTo(nReg))
BR4->(dbSetOrder(nOrd))
return(nTam)

/*/{Protheus.doc} PLGRVDIAG
FUNCAO GENERICA PARA MONTAGEM DE TELA COM GRID. Recebe um alias e campo para gravaçao de uma
tabela qualquer atraves de uma DiaLog de tamanho menor da tela Generica
@type function
@author TOTVS
@since 15/02/2009
@version 1.0
/*/
Function PLGRVDIAG(cAliUso,cTitulo,cFiltro, cCpoID, xDadoId, nInd, cCmpsInd, aCampos, nOpcGD, cFunPosOK, nAltDiag, nLargDiag, aButAR, lCpoSequen, lB7D, cFunDel, cCpoExb, lOnlyShow,cOrder)
LOCAL aArea 	:= GetArea()
LOCAL nX 		:= 0
LOCAL nPos 		:= 0
LOCAL aHead 	:= {}, nI := 0, nU := 0

LOCAL aIndAux	:= {}
LOCAL aIndUso	:=	{} // aqui irão os campos do indice + a expressao macro para pegar o dado no grid
LOCAL cVarInd	:= "" //Conteudo do indice apos a execucao da macro
LOCAL lAchou	:= .F.
LOCAL nI		:= 0
Local aCpo 		:= {}

Private oGDPri		:= nil
Private aColsGen	:= {}
Private nCGen 		:= 0
Private nOpca 		:= 0
Default nAltDiag	:= 540 // Altura da Dialog
Default nLargDiag 	:= 700 // Largura da Dialog
Default cCpoID 		:= "" //Campo principal de identificaçao dos registros editados (normalmente o mesmo do filtro)
Default cFiltro 	:= "" // Filtro passado para a tabela
Default nOpcGD		:= GD_INSERT + GD_UPDATE + GD_DELETE // Permissoes no GRID
Default cFunPosOK	:= "" // Funçao para execuçao ao clicar em OK e antes de gravar
Default aButAR		:= {} // Botoes no açoes relacionadas
Default aCampos		:= {} // Campos que serao exibidos
Default lCpoSequen	:= .T. // Se houver campo sequencial confirma a utilizaçao do sequencial
Default lB7D		:= .F. // se a rotina for chamada utilizando a B7D uma tela para inclusão de observação sera visualizada.
Default cFunDel		:= "" // Bloco de codigo executado na delecao do Grid
Default cCpoExb		:= "ALL" // Campos que serao exibidos no grid
Default lOnlyShow	:= .F. // Campos que serao exibidos no grid
Default cOrder  	:= "" //Ordenação pelos Campos
Default cCmpsInd  	:= "" //Ordenação pelos Campos

aIndAux := StrToArray( cCmpsInd , '+' ) // Pega o indice e separa os campos

SX2->(DbSetOrder(1))
SX2->(MsSeek(cAliUso))
Default cTitulo := "Manutenção " + Alltrim(SX2->X2_DESCRI)

If lOnlyShow
	nOpcGD := 0
	Inclui := .F.
EndIf

HS_BDados(cAliUso, @aHead, @aColsGen,@nU, 1,, cFiltro,,,cCpoExb,,,,,,.T.,/*aLeg*/,,,,, /*aCpo*/, /*aJoin*/,,cOrder)

nCodID := Ascan(aHead,{|x|AllTrim(x[2])==cCpoID})

For nX := 1 To Len(aIndAux)
	If 	"_FILIAL" $ Alltrim(aIndAux[nX])
		Loop
	ElseIf 	Alltrim(aIndAux[nX]) == Alltrim(cCpoID) // Se for o campo passado dentro do indice joga a variavel do dado pra ser executada macro
		AADD(aIndUso, { aIndAux[nX] , "xDadoId" } )
	Else // Caso contrario jogo a macro da posição no aCols encontrada
		nPos := Ascan(aHead,{|x| AllTrim(x[2])==aIndAux[nX]})
		If nPos == 0
			Exit
		EndIf
		AADD(aIndUso, { aIndAux[nX] , "aColsGen[nCGen," + Alltrim(Str(nPos)) + "]" } )
	EndIf
	
Next nX

DEFINE MSDIALOG oDlgGen TITLE cTitulo From 000, 000 To 480, 650 Of oMainWnd Pixel   //000 000 400 600

oGDPri := MsNewGetDados():New(030, 005, 230, 320,nOpcGD,,,,,,,,,, oDlgGen, aHead, aColsGen)    // 000 000 300 500

//Se excluir uma receita, executa a rotina ExiMotExc.
If !Empty(cFunDel)
	oGDPri:BDelOk := {|| &(cFunDel) }//{|| ExiMotExc(oGDPri) }
EndIf

ACTIVATE MSDIALOG oDlgGen CENTERED ON INIT EnchoiceBar(oDlgGen,{ || nOpca := 1, oDlgGen:End() },{|| nOpca := 0, oDlgGen:End()})

If nOpca == 1 .and. !lOnlyShow
	
	If !Empty(cFunPosOK)
		&(cFunPosOK)
	EndIf
	
	dbSelectArea(cAliUso)
	&(cAliUso)->(DbSetOrder(nInd))
	
	If !Empty(oGDPri:aCols)
		aColsGen := aClone(oGDPri:aCols)
		
		For nI := 1 to Len(aColsGen)
			cVarInd := ""
			nCGen := nI
			For nX := 1 To Len(aIndUso)
				cVarInd += &(aIndUso[nX,2])
			Next nX
			lAchou := IIf( !Empty( cVarInd ),   &(cAliUso)->(MsSeek(xFilial(cAliUso) + cVarInd)),.F.)
			If aColsGen[nI][Len(oGDPri:aHeader) + 1]  .And. lAchou // ITEM DELETADO NA GRID
				RecLock(cAliUso, !lAchou)
				DbDelete()
				MsUnLock()
			Else
				RecLock(cAliUso, !lAchou)
				HS_GRVCPO(cAliUso, aColsGen, aHead, nI)
				&(cAliUso + "_FILIAL") 	:= xFilial(cAliUso)
				If !Empty(cCpoID) .AND. !Empty(xDadoID)
					&(cCpoID) 	:= xDadoID
				EndIf
				MsUnlock()
			EndIf
		Next nI
	EndIf
	If lCpoSequen
		While __lSx8
			ConfirmSx8()
		End
	EndIf
Else
	If lCpoSequen
		While __lSx8
			RollBackSxe()
		End
	EndIf
EndIf

restArea(aArea)

Return

/*/{Protheus.doc} PLSIdade
Retorna a idade contando os dias
@type function
@author Rogerio Tabosa
@since 15/02/2009
@version 1.0
/*/
Function PLSIdade(dDataI, dDataF,lStrFull)
Local aIdade 		:= HS_DifData(dDataI, dDataF)
Default lStrFull	:= .F. // Define se o retorno sera String completa ou apenas quantos anos em numerico

If lStrFull
	Return(StrZero(aIdade[1], 2) + " ano(s) " + StrZero(aIdade[2], 2) + " mes(es) " + StrZero(aIdade[3], 2) + " dia(s) ") //" ano(s) "###" mes(es) "###" dia(s) "
Else
	Return(aIdade[1])
EndIf

Return()

/*/{Protheus.doc} ValMotPad
Carregar Descrição e observação do motivo padrão.
@type function
@author Roberto Vanderlei
@since 01.07.2015
@version 1.0
/*/
Static Function ValMotPad(cSequen, cTpTela)
local lRet := .F.

if cTpTela = 'I'   // Testa se é a tela de inclusão de interação
	cDesMotPad := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_DESMOT")
	cObsMotPad := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_OBSERV")
else // Se for a tela de visualização da interação
	cDesMotPadVis := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_DESMOT")
	cObsMotPadVis := BBR->BBR_OBSERV
endIf

If Empty(cSequen)
	lRet := .T.
else
	if Empty(alltrim(cDesMotPad)) .and. Empty(alltrim(cDesMotPadVis))
		lRet := .F.
	else
		lRet := .T.
	endIf
endIf

Return(lRet)

/*/{Protheus.doc} CHKSELECT
Checa se alguma linha foi selecionada.
@type function
@author Roberto Vanderlei
@since 01.07.2015
@version 1.0
/*/
Function CHKSELECT(aArray, cMotivoPadrao, cMemoObs)
local nFor
local lSelecionado
local nPosicao := len(aArray[1])

lSelecionado := .F.

for nFor := 1 to len(aArray)
	
	if aArray[nFor, nPosicao]
		lSelecionado := .T.
	endif
	
	
next nFor

if ! lSelecionado
	MsgAlert('É necessário selecionar pelo menos um procedimento.')  //'É necessário selecionar pelo menos um procedimento.'
else
	If ( Empty(alltrim(cMotivoPadrao)) .AND. Empty(alltrim(cMemoObs)) )
		MsgAlert('É necessário preecher o campo Motivo Padrão ou Observação, pois ambos não podem ficar vazios.')  //'É necessário preecher o campo Motivo Padrão.'
		lSelecionado := .F.
	endif
endif
	
return(lSelecionado)

/*/{Protheus.doc} FILLITERA
Carrega Dinâmicamente a grade de Histórico
@type function
@author Roberto Vanderlei
@since 01.07.2015
@version 1.0
/*/
Function FILLITERA(cChave, aDadH, cAliasPai, cRotGen)
local nFor
local cMotPadrao
local aTrbHist
Default cRotGen		:= "0"

aDadH := {}
If cRotGen == "0"
	BBR->( DbSetOrder(1) )
	BBR->( MsSeek( xFilial("BBR")+cChave+cAliasPai ))
	Store Header "BBR" TO aCabHist For .T.
	If BBR->(DbSeek(xFilial("BBR")+cChave))
		Store COLS "BBR" TO aDadHist FROM aCabHist VETTRAB aTrbHist While xFilial("BBR")+cChave+cAliasPai == BBR->(BBR_FILIAL+BBR_CODOPE+BBR_ANOAUT+BBR_MESAUT+BBR_NUMAUT+BBR_SEQPRO+BBR_ALIMOV)
	else
		Store COLS Blank "BBR" TO aDadHist FROM aCabHist
	endif
else
	//BBR_FILIAL+BBR_NUMGUI+BBR_SEQPRO
	BBR->( DbSetOrder(3) )
	Store Header "BBR" TO aCabHist For .T.
	If BBR->( MsSeek( xFilial("BBR")+cChave))
		Store COLS "BBR" TO aDadHist FROM aCabHist VETTRAB aTrbHist While xFilial("BBR")+cChave == BBR->(BBR_FILIAL+BBR_NUMGUI+BBR_SEQPRO)
	Else
		Store COLS Blank "BBR" TO aDadHist FROM aCabHist
	EndIf
endIf

for nFor := 1 to  len(aDadHist)
	cMotPadrao 	:= Posicione("BBP",1,xFilial("BBP")+aDadHist[nFor, 2],"BBP_DESMOT")
	cNomUsr		:= UsrFullName(aDadHist[nFor, 4])
	aadd(aDadH, {aDadHist[nFor, 5], aDadHist[nFor, 6], cMotPadrao, aDadHist[nFor, 16], cChave + aDadHist[nFor, 17], aDadHist[nFor, 7], cNomUsr})
Next

aDadH := ASORT(aDadH,,, { |Intera1,Intera2| DtoS(Intera1[2])+Intera1[6] > DtoS(Intera2[2])+Intera2[6] } )  //Organizar por data+hora a Interação. 
	
return aDadH

/*/{Protheus.doc} PLSBBRSeq
Proximo sequencial para a interação
@type function
@author Roberto Vanderlei
@since 01.07.15
@version 1.0
/*/
Function PLSBBRSeq(cCodOpe, cAnoAut, cMesAut, cNumAut, cSeqPro, cRotGen, cChave)
LOCAL cSeq
local cMaior := 0
Default cRotGen	:= "0"
Default cChave	:= ""

If cRotGen == "0"
	
	BBR->(DbSetOrder(1))
	cChave := cCodOpe + cAnoAut + cMesAut + cNumAut + cSeqPro
else
	BBR->(DbSetOrder(3))
	cChave := cChave + cSeqPro
endif

If BBR->(MsSeek(xFilial("BBR") + cChave ))
	
	While !BBR->(Eof()) .and. ;
	      ((BBR->(IndexOrd())== 1 .and. xFilial("BBR") + cChave == BBR->(BBR_FILIAL+BBR_CODOPE+BBR_ANOAUT+BBR_MESAUT+BBR_NUMAUT+BBR_SEQPRO)) .or. ;
           (BBR->(IndexOrd())== 3 .and. xFilial("BBR") + cChave == BBR->(BBR_FILIAL+BBR_NUMGUI+BBR_SEQPRO)))
	
		if cMaior <  Val(BBR->BBR_SEQUEN)
			cMaior := Val(BBR->BBR_SEQUEN)
		endif
		
		BBR->(DbSkip())
	Enddo
	cSeq := StrZero(cMaior+1,3)
else
	cSeq := "001"
Endif

Return(cSeq)


/*/{Protheus.doc} PLSATUAUD
Atualiza Auditoria
@type function
@author Roberto Vanderlei
@since 06.07.2015
@version 1.0
/*/
Function PLSATUAUD(cTpPublico, cRespPrestador, cResposta,cObsMotPad)
local cSETORBF := GetNewPar("MV_SETORBF","00")
local cSETORPR := GetNewPar("MV_SETORPR","00")
local cSETORAT := GetNewPar("MV_SETORAT","00")
local lEncaminhamento := .F.
local cAliasMov
local cAliasRec
local cDepto
Default cObsMotPad:=""

if alltrim(cResposta) <> ''
	cAliasMov 	:= B53->B53_ALIMOV
	cAliasRec 	:= B53->B53_RECMOV
	cDepto := cSETORAT
	
	B53->(RecLock("B53",.F.))
	B53->B53_CODDEP := cSETORAT
	B53->(MsUnLock())
	lEncaminhamento := .T.
else
	if cTpPublico == "Prestador"
		cAliasMov 	:= B53->B53_ALIMOV
		cAliasRec 	:= B53->B53_RECMOV
		cDepto 		:= cSETORPR
		
		B53->(RecLock("B53",.F.))
		B53->B53_CODDEP :=  cSETORPR
		B53->(MsUnLock())
		lEncaminhamento := .T.
	else
		if cTpPublico == "Beneficiário"
			cAliasMov 	:= B53->B53_ALIMOV
			cAliasRec 	:= B53->B53_RECMOV
			cDepto 		:= cSETORBF
			
			B53->(RecLock("B53",.F.))
			B53->B53_CODDEP :=  cSETORBF
			B53->(MsUnLock())
			lEncaminhamento := .T.
		endif
	endif
endif

if lEncaminhamento
	PLSICB71(cAliasMov, cAliasRec, B53->B53_CODDEP,cObsMotPad )
endif
	
return

/*/{Protheus.doc} PLSAINTE
Incluir Interação
//01=Odonto;02=SADT;03=Reembolso;04=Internacao;05=Consulta;07=Anexos Clinicos
@type function
@author Roberto Vanderlei
@since 06.07.2015
@version 1.0
/*/
Function PLSAINTE(cAliasIte,cTpGuia, cCodOper, cAno, cMes, cNum)
Local oDlg			:= nil
Local cCadastro		:= '   '
local cTpPublico	:= ''
local cParecer		:= ''
LOCAL aButtons 		:= {}
local oList			:= nil
local aDadProc 		:= {}
local cF3 			:= 'BBP'
local cCampoMot 	:= Space(03)
local cChave		:= ''
local cChaveIte		:= ''
local aCabPro 		:= {}
local aDadPro 		:= {}
local aTrbPro 		:= {}
local nProc			:= 0
local nCab			:= 0
local nPosTab 		:= 0
local nPosProc 		:= 0
local nPosDesc 		:= 0
local nPosSequen 	:= 0
LOCAL lCheck 		:= .F.
local nFor			:= 0
local nOpca			:= 0
local aDadH 		:= {}
local aSize 		:= {}
local lSelecionado 	:= .F.
local nLinhaIni		:= 0
local nColunaIni	:= 0
local cSetor		:= ''
local cAlteraPublico:= ''
local cCodOpe		:= ''
local cNomOpe		:= ''
local cAliasPai		:= ''
local lRespPre		:= .F.
local lAuditado 	:= .F.
local cDescDep  	:= ""

Private cObsMotPad	 	:= ""
Private cDesMotPad	 	:= ""
Private cDesMotPadVis	:= ""
Private cObsMotPadVis	:= ""

if cTpGuia = 'AD'
	
	cAliasPai := B53->B53_ALIMOV
	
	//caso a guia esteja auditada, apenas será possível visualizar ou criar interações internas 
	If B53->B53_SITUAC == "1"
		lAuditado := .T.
	EndIf 
	
	If B53->B53_ROTGEN == "1"
		PlsIntGen(cTpGuia)
		Return		
	Else
		if B53->B53_ALIMOV = 'BE4' //Internação
			cAliasIte := "BEJ"
		else
			if B53->B53_ALIMOV = 'BEA'
				cAliasIte := "BE2" //SADT - Odonto
			else
				if B53->B53_ALIMOV = 'B44'
					cAliasIte := "B45" //Reembolso
				else
					if B53->B53_ALIMOV = 'B4A' //Anexos Clinicos
						cAliasIte := "B4C"
					else
						if B53->B53_ALIMOV = 'B4Q' //Anexos Clinicos
							cAliasIte := "BQV"
						endif
					endif
				endif
			endif
		endif
	endIf
	
	aCampos := {}
	
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_CODOPE',cAliasIte + '_OPEMOV') , Left(B53->B53_NUMGUI,4)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_ANOINT',cAliasIte + '_ANOAUT') , SubStr(B53->B53_NUMGUI,5,4)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_MESINT',cAliasIte + '_MESAUT') , SubStr(B53->B53_NUMGUI,9,2)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_NUMINT',cAliasIte + '_NUMAUT') , Right(B53->B53_NUMGUI,8)})
else
	
	if cAliasIte = "BEJ"  //Internação
		cAliasPai := 'BE4'
	else
		if cAliasIte = "BE2"
			cAliasPai := "BEA" //SADT - Odonto
		else
			if cAliasIte = "B45"
				cAliasPai := 'B44'  //Reembolso
			else
				if cAliasIte = "B4C" //Anexos Clinicos
					cAliasPai := 'B4A'
				else
					if cAliasIte = "BQV" //Anexos Clinicos
						cAliasPai := 'B4Q'
					endif
				endif
			endif
		endif
	endif
	
	
	aCampos := {}
	
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_CODOPE',cAliasIte + '_OPEMOV') , &(cCodOper)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_ANOINT',cAliasIte + '_ANOAUT') , &(cAno)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_MESINT',cAliasIte + '_MESAUT') , &(cMes)})
	aadd(aCampos, { if(cAliasIte $ 'BEJ,BQV', cAliasIte + '_NUMINT',cAliasIte + '_NUMAUT') , &(cNum)})
	
endif

dbSelectArea(cAliasIte)

cChaveIte := PADL(CVALTOCHAR(aCampos[1][2]), TamSx3(aCampos[1][1])[1],"0") + PADR(CVALTOCHAR(aCampos[2][2]), TamSx3(aCampos[2][1])[1],) + PADL(CVALTOCHAR(aCampos[3][2]), TamSx3(aCampos[3][1])[1],"0") + PADL(CVALTOCHAR(aCampos[4][2]), TamSx3(aCampos[4][1])[1],"0")//BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

&(cAliasIte)->( DbSetOrder(1) )
&(cAliasIte)->( MsSeek( xFilial(cAliasIte)+cChaveIte ))

Store Header cAliasIte TO aCabPro For .T.
Store COLS cAliasIte TO aDadPro FROM aCabPro VETTRAB aTrbPro While xFilial(cAliasIte)+&(cAliasIte)->(&(aCampos[1][1])+&(aCampos[2][1])+&(aCampos[3][1])+&(aCampos[4][1])) == xFilial(cAliasIte)+cChaveIte

if empty(aDadPro) 
	msgInfo(STR0095,STR0028) //"Está guia não possui acesso a rotina de interação pois não possui procedimentos", "Atenção"
	return
endIf 

for nCab := 1 to len(aCabPro) // Busca dinâmica da posição dos campos, no caso da ordem for alterada.
	if nPosTab = 0 .or. nPosProc = 0 .or. nPosDesc = 0 //Só faz a comparação se ainda não achou os 3 campos.
		if aCabPro[nCab][2] == cAliasIte + '_CODPAD'
			nPosTab := nCab
		else
			if aCabPro[nCab][2] == cAliasIte + '_CODPRO'
				nPosProc := nCab
			else
				if aCabPro[nCab][2] == cAliasIte + '_DESPRO'
					nPosDesc := nCab
				else
					if aCabPro[nCab][2] == cAliasIte + '_SEQUEN'
						nPosSequen := nCab
					endif
				endif
			endif
		endif
	endif
next nCab

/*Buscando o Setor e a Permissão para Alterar o Público*/
DbSelectArea("BX4")
BX4->(DbSetOrder(1))
cChave := xFilial("BX4") + RETCODUSR() + PLSINTPAD()

If BX4->(DbSeek(cChave))
	cSetor 		 := BX4->BX4_CODDEP
	cAlteraPublico := alltrim(BX4->BX4_ALTPUB)
	cCodOpe 		 := BX4->BX4_CODOPE
endif

aSize := MsAdvSize()

nLinhaIni := aSize[1]  + 005  //005
nColunaIni := aSize[2]  + 005 //035

aSize[3] := aSize[3]
aSize[4] := Round(aSize[4] * 0.92, 0)
aSize[5] := Round(aSize[5] * 0.57/*0.92*/, 0)
aSize[6] := Round(aSize[6] , 0) //* 0.82
aSize[7] := Round(aSize[7] * 0.92, 0)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL

@ nColunaIni, nLinhaIni SAY "Procedimentos" SIZE 100,010 PIXEL OF oDlg //Desc. Espec


for nProc := 1 to Len(aDadPro) //Com base na posição do cabeçalho, busca o conteúdo.
	aadd(aDadProc, {alltrim(aDadPro[nProc][nPosTab]) , alltrim(aDadPro[nProc][nPosProc]), alltrim(aDadPro[nProc][nPosDesc]), alltrim(aDadPro[nProc][nPosSequen]), .F.})
next nProc

oList := TCBROWSE():New(nColunaIni + 010,nLinhaIni,/*395*/aSize[5]*0.49 ,50 ,,;
	{}, {40,40,40},;
	oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )


ADD COLUMN To oList BitMap Data { || LoadBitMap( GetResources(), Iif(!aDadProc[oList:nAt,Len(aDadProc[oList:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 ALIGN CENTERED NOHILITE

oList:AddColumn(TcColumn():New('Cod. Tab. Pd',{ || aDadProc[oList:nAt, 1] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
oList:AddColumn(TcColumn():New('Cod. Proc.'  ,{ || aDadProc[oList:nAt, 2] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
oList:AddColumn(TcColumn():New('Descr. Proc.',{ || aDadProc[oList:nAt, 3] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))

oList:SetArray(aDadProc)

oList:BLDBLCLICK := { || MarcaLinha(oList:nAt,aDadProc,lCheck) , oList:Refresh() }


@ nColunaIni + 70, nLinhaIni SAY "Incluir Interação" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
oPanel  := TPanel():New( nColunaIni + 80, nLinhaIni, "",, , .F., , , , aSize[5], 190, .T., .F. )//*0.49

@ 010, 010 SAY oSay3 PROMPT "Público:" SIZE 025, 007 OF oPanel PIXEL
@ 017, 010 MSCOMBOBOX oParecer VAR cTpPublico ITEMS {"", "Beneficiário", "Prestador" } SIZE 055, 010 OF oPanel;
	WHEN cAlteraPublico = '1' .and. cTpGuia = 'AD' .AND. Alltrim(FUNNAME()) != "TMKA271" .AND. !lAuditado;  
	ON CHANGE IF(!PlVldInt(oList:nAt, aDadProc, cTpPublico, @cParecer,oList),cTpPublico := "",)  PIXEL OF oPanel

@ 010, 070 SAY oSay4 PROMPT "Resposta Prest." SIZE 025, 007 OF oPanel PIXEL
@ 017, 070 MSCOMBOBOX oParecer VAR cParecer ITEMS {"Não","Sim"}  SIZE 030, 010 OF oPanel;
	WHEN /*.T.*/ cTpPublico == "Prestador"  PIXEL OF oPanel

@ 010, 105 SAY oSay5 PROMPT "Motivo Padrão:" SIZE 040, 007 OF oPanel PIXEL
@ 017, 105 MSGET cCampoMot VAR cCadastro F3 cF3 VALID ValMotPad(cCadastro, 'I')  /*VAR cCadastro PICTURE "@!" WHEN .T.*/ SIZE 030,010 PIXEL OF oPanel

@ 017, 135 MSGET cDesMotPad /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE aSize[5]*0.23 /*180*/,010 PIXEL OF oPanel

@ 040,010 SAY "Obs.:" SIZE 100,010 PIXEL OF oPanel //Desc. Espec
@ 047,010 GET cObsMotPad Memo SIZE 200,040 PIXEL OF oPanel

@ nColunaIni + 185, nLinhaIni SAY "Histórico de Interações" SIZE 100,010 PIXEL OF oDlg //Desc. Espec


oListHist := TCBROWSE():New(nColunaIni + 200,nLinhaIni,aSize[5]*0.49 ,50 ,,;
	{},{40,40},;
	oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

oListHist:AddColumn(TcColumn():New('Setor',{ || aDadH[oListHist:nAt, 1] },"@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Data Interação'  ,{ || aDadH[oListHist:nAt, 2] },"@C",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Mot. Padrão'   ,{ || aDadH[oListHist:nAt, 3] },"@C",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Observação'   ,{ || aDadH[oListHist:nAt, 4] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))

oListHist:BLDBLCLICK := { || if( len(aDadH) > 0, PLSAVISINT(aDadH[oListHist:nAt, 5], cAlteraPublico), ) /*, oList:Refresh()*/ } 

oList:bChange :=  {|| oListHist:SetArray(FILLITERA(cChaveIte + aDadProc[oList:nAt, 4], aDadH, cAliasPai)), oListHist:Refresh()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1, If(CHKSELECT(aDadProc, cDesMotPad, cObsMotPad ),oDlg:End(),nOpca := 2)  /*oDlg:End()*/ ,.F.}, {|| oDlg:End()},.F.,aButtons) Centered

If  nOpca == K_OK

	//não permite gerar uma interação enquanto houver reposta pendente do prestador ou do beneficiário 
	If !EMPTY(cTpPublico)
		
		if B53->B53_CODDEP $ "005,006" // Beneficiario, prestador (código da tabela genérica BL
			
		cDescDep := upper( allTrim( Posicione("SX5",1,xFilial("SX5")+"BL"+B53->B53_CODDEP,"X5_DESCRI") ) )

			msgInfo(STR0093 + cDescDep + STR0094, STR0028) //"Guia aguardando interação do ", ", não será possível concluir a interação", "Atenção"
			return
		endIf
	endIf 
		
	Begin Transaction
		for nFor := 1 to len(aDadProc)
			
			if aDadProc[nFor,5]
				
				cSeq := PLSBBRSeq(/*BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT*/PADL(CVALTOCHAR(aCampos[1][2]), TamSx3(aCampos[1][1])[1],"0"), PADR(CVALTOCHAR(aCampos[2][2]), TamSx3(aCampos[2][1])[1]," "), PADL(CVALTOCHAR(aCampos[3][2]), TamSx3(aCampos[3][1])[1],"0"), PADL(CVALTOCHAR(aCampos[4][2]), TamSx3(aCampos[4][1])[1],"0"), PADL(aDadProc[nFor, 4], 3, "0"))
				BBR->(RecLock("BBR",.T.))
				
				if cTpPublico == "Prestador"
					BBR->BBR_TPDIRP := 'P'
				else
					if empty(cTpPublico)
						BBR->BBR_TPDIRP := Space(TamSx3("BBR_TPDIRP")[1])
						BBR->BBR_ANEXAD := .t.
					else
						BBR->BBR_TPDIRP := 'B'
					endif
				endif
				
				//Alteração necessária pois no momento de anexar um arquivo pelo portal
				//do beneficiário, não existe vinculo direto entre o registrocorrente da interação e o procedimento.
				//Desta forma, dificultou muito a alteração do status no momento após anexar um arquivo.
				if cParecer = "Sim" .OR. BBR->BBR_TPDIRP == 'B'
					
					BBR->BBR_RESPRE := .T.
					
					If BBR->BBR_TPDIRP == 'P'  
						BBR->BBR_ANEXAD := .T.
					EndIf 
					
				else
					BBR->BBR_RESPRE := .F.
				endif
				
				BBR->BBR_FILIAL  := xfilial("BBR")
				BBR->BBR_SETOR  := Posicione("SX5",1,xFilial("SX5")+"BL"+cSetor/*BX4->BX4_CODDEP*/,"X5_DESCRI")
				BBR->BBR_CODUSU := cCodOpe
				BBR->BBR_SEQMOP := cCadastro
				BBR->BBR_DTITER := DDATABASE
				BBR->BBR_HRITER := TIME()
				BBR->BBR_SEQPRO := aDadProc[nFor, 4]
				BBR->BBR_CODPRO := aDadProc[nFor, 2]
				BBR->BBR_TPGUIA := cTpGuia //"04"
				BBR->BBR_OBSERV := cObsMotPad
				
				BBR->BBR_ALIMOV := cAliasPai
				
				BBR->BBR_CODOPE := PADL(CVALTOCHAR(aCampos[1][2]), TamSx3(aCampos[1][1])[1],"0")//BE4_CODOPE
				BBR->BBR_ANOAUT := PADR(CVALTOCHAR(aCampos[2][2]), TamSx3(aCampos[2][1])[1],) //BE4_ANOINT
				BBR->BBR_MESAUT := PADL(CVALTOCHAR(aCampos[3][2]), TamSx3(aCampos[3][1])[1],"0") //BE4_MESINT
				BBR->BBR_NUMAUT := PADL(CVALTOCHAR(aCampos[4][2]), TamSx3(aCampos[4][1])[1],"0") //BE4_NUMINT
				
				BBR->BBR_SEQUEN := cSeq
				
				BBR->(MsUnLock())
				
				PLSATUAUD(cTpPublico, cParecer, '',cObsMotPad)
				
				//Atualizar o status na BEA ou BE4 para análise quando depender de resposta do prestador
				IF ( cAliasPai $ ("BEA,BE4,B4A,B4Q") .AND. cTpPublico = "Prestador" )
					If cAliasPai=="BE4"
						&(cAliasPai)->(DbSetOrder(2))
					Else
						&(cAliasPai)->(DbSetOrder(1))
					Endif
					
					IF &(cAliasPai)->( MsSeek( xFilial(cAliasPai)+cChaveIte ))
						&(cAliasPai)->(RecLock((cAliasPai),.F.))
						&(cAliasPai+"->"+cAliasPai+"_STTISS") := PLSANLSTIG("5H") //Aguardando Informação do prestador
						&(cAliasPai)->(msUnLock())
					Endif
				ENDIF
				
				IF ( cAliasPai $ ("BEA,BE4,B4Q") .AND. cTpPublico = "Beneficiário" )
					
					If cAliasPai == "BE4"
						&(cAliasPai)->(DbSetOrder(2))
					Else
						&(cAliasPai)->(DbSetOrder(1))
					Endif
					
					&(cAliasPai)->( msSeek( xFilial(cAliasPai)+cChaveIte ))
					
					&(cAliasPai)->(recLock((cAliasPai),.F.))
						&(cAliasPai+"->"+cAliasPai+"_STTISS") := "2" //Em Análise
					&(cAliasPai)->(msUnLock())
					
				endIf
				
				msgInfo(STR0085)  //'Interação salva com sucesso.'
				
			endif
			
		next nFor
		
	End Transaction
	
Endif

return

/*/{Protheus.doc} PLSAVISINT
Visualizar Interação
@type function
@author Roberto Vanderlei
@since 06.07.2015
@version 1.0
/*/
Function PLSAVISINT(cChave, cAlteraPublico)
local oDlg
local oPanel
local oCampoMotVis 	:= Space(03)
local cCodUsu		:=""
local cNomUsu		:=""
local nOpca
local cCadastro 	:= 'Visualizar Interação'
LOCAL aButtons 		:= {}
local cTpPublico	:=""
local cCampoMot 	:= Space(03)
local cF3 			:= 'BBP'
local cResInt		:=""
Local nCountR 		:= 0
Local lInterPen		:= .F. 
Local cChaveB		:= cChave
Local lRespInt		:= .F.

BBR->( DbSetOrder(2) )
BBR->( MsSeek( xFilial("BBR")+cChave ))

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 10,0 To 600, 500 of oMainWnd PIXEL

/*Buscando o Setor e a Permissão para Alterar o Público*/
DbSelectArea("BX4")
BX4->(DbSetOrder(1))
cChave := xFilial("BX4") + alltrim(BBR->BBR_CODUSU) + PLSINTPAD()


If BX4->(DbSeek(cChave))
	cNomUsu := BX4->BX4_NOMOPE
endif

@ 035,005 SAY "Interação" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
oPanel  := TPanel():New( 042, 005, "",, , .F., , , , 240, 140, .T., .F. )


@ 010, 010 SAY oSay5 PROMPT "Usuário" SIZE 025, 015 OF oPanel PIXEL
@ 017, 010 MSGET alltrim(BBR->BBR_CODUSU) /*VAR cCodUsu F3 cF3*/ WHEN .F. /*VAR cCadastro PICTURE "@!" WHEN .T.*/ SIZE 030,010 PIXEL OF oPanel

@ 017, 040 MSGET alltrim(/*BBR->BBR_NOMUSU*/cNomUsu) /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE 200,010 PIXEL OF oPanel

@ 035, 010 SAY oSay5 PROMPT "Setor" SIZE 025, 015 OF oPanel PIXEL
@ 042, 010 MSGET alltrim(BBR->BBR_SETOR) /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE 060,010 PIXEL OF oPanel

@ 035, 070 SAY oSay5 PROMPT "Data" SIZE 025, 015 OF oPanel PIXEL
@ 042, 070 MSGET BBR->BBR_DTITER /*VAR cCadastro  WHEN .T.*/WHEN .F. SIZE 040,010 PIXEL OF oPanel

@ 035, 110 SAY oSay5 PROMPT "Hora" SIZE 025, 015 OF oPanel PIXEL
@ 042, 110 MSGET alltrim(BBR->BBR_HRITER) /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE 020,010 PIXEL OF oPanel

if BBR->BBR_TPDIRP == 'P'
	cTpPublico := "Prestador"
else
	if empty(BBR->BBR_TPDIRP)
		cTpPublico := Space(TamSx3("BBR_TPDIRP")[1])
	else
		cTpPublico := "Beneficiário"
	endif
endif

lRespPre := BBR->BBR_RESPRE

if lRespPre
	cParecer := "Sim"
Else
	cParecer := "Não"
Endif

@ 035, 140 SAY oSay3 PROMPT "Público:" SIZE 025, 007 OF oPanel PIXEL
@ 042, 140 MSCOMBOBOX oParecer VAR cTpPublico ITEMS {"", "Beneficiário", "Prestador"} SIZE 055, 010 OF oPanel;
	WHEN .F./*cAlteraPublico = '1'*/ ON CHANGE Iif(cTpPublico <> "Prestador" , cParecer := "Não",cParecer := "Sim") PIXEL OF oPanel

@ 035, 195 SAY oSay4 PROMPT "Resposta Prest." SIZE 025, 007 OF oPanel PIXEL
@ 042, 195 MSCOMBOBOX oParecer VAR cParecer ITEMS {"Não","Sim"}  SIZE 030, 010 OF oPanel;
	WHEN .F.  PIXEL OF oPanel

cCampoMot := BBR->BBR_SEQMOP

ValMotPad(cCampoMot, 'V')

@ 060, 010 SAY oSay5 PROMPT "Motivo Padrão:" SIZE 040, 007 OF oPanel PIXEL
@ 067, 010 MSGET oCampoMotVis VAR cCampoMot F3 cF3 /*VALID ValMotPad(cCampoMot, 'V')*/  WHEN .F. /*VAR cCadastro PICTURE "@!" WHEN .T.*/ SIZE 030,010 PIXEL OF oPanel

@ 067, 040 MSGET cDesMotPadVis /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE 180,010 PIXEL OF oPanel

@ 085,010 SAY "Observacao" SIZE 100,010 PIXEL OF oPanel //Desc. Espec
@ 092,010 GET cObsMotPadVis Memo SIZE 220,040 PIXEL OF oPanel MULTILINE HSCROLL READONLY

cResInt := alltrim(BBR->BBR_RESPOS) 

@ 185,005 SAY "Resposta" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
oPanelResposta  := TPanel():New( 192, 005, "",, , .F., , , , 240, 100, .T., .F. )

If ! empty(cResInt) 
	@ 010,010 GET cResInt Memo WHEN BBR->BBR_RESPRE .AND. cParecer = "Sim" SIZE 220,070 PIXEL OF oPanelResposta MULTILINE HSCROLL READONLY
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,nOpca := 0,{|| oDlg:End()},.F.,{},,,,,,.F.) } )
	
Else
	
	lRespInt := .T.
	@ 010,010 GET cResInt Memo WHEN (BBR->BBR_RESPRE .AND. cParecer = "Sim") .OR. (!BBR->BBR_RESPRE .AND. cParecer <> "Sim") SIZE 220,070 PIXEL OF oPanelResposta
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1, oDlg:End(),.F.}, {|| oDlg:End()},.F.,aButtons) Centered
	
EndIF 

If  nOpca == K_OK
	Begin Transaction
		BBR->(RecLock("BBR",.F.))
		BBR->BBR_RESPOS := cResInt
		
		if cParecer = "Sim"
			BBR->BBR_RESPRE := .T.
		else
			BBR->BBR_RESPRE := .F.
		endif
		
		//Se for resposta interna (parecer por parte da operadora quando a resposta esperada é do prestador)
		//Alteramos a interação para não ficar pendente do prestador
		if lRespInt .and. ! Empty(BBR->BBR_RESPOS) .and. (cTpPublico == "Prestador")
			BBR->BBR_TPDIRP := ''
		else
			if cTpPublico == "Prestador"
				BBR->BBR_TPDIRP := 'P'
			else
				if empty(cTpPublico)
					BBR->BBR_TPDIRP := Space(TamSx3("BBR_TPDIRP")[1])
				else
					BBR->BBR_TPDIRP := 'B'
				endif
			endif
		endif			

		BBR->(MsUnLock())
	
	//Verifica se todos os procedimentos estão com resposta, quando remote.
	BBR->(DbSetOrder(1))
	BBR->( MsSeek( xFilial("BBR")+Left(cChaveB,18) ))
		IF ( BBR->BBR_ALIMOV $ ("BEA,BE4,B4A,B4Q") ) 
		
		cAliasPai := BBR->BBR_ALIMOV
		
		While (!BBR->(EOF()) .AND. BBR->(BBR_CODOPE+BBR_ANOAUT+BBR_MESAUT+BBR_NUMAUT) == Left(cChaveB,18))
			
			IF (BBR->BBR_TPDIRP == "P")
				
				IF BBR->BBR_RESPRE .AND. EMPTY(BBR->BBR_RESPOS) .OR. !BBR->BBR_ANEXAD
					lInterPen := .T.
					
					EXIT
				ENDIF
			ENDIF
			
			BBR->(DbSkip())
		ENDDO
		
		if !lInterPen
			//Atualizar o status na BEA ou BE4 para análise quando depender de resposta do prestador
				IF ( cAliasPai $ ("BEA,BE4,B4A,B4Q") .AND. cTpPublico == "Prestador" ) 
				If cAliasPai == "BE4" 
					&(cAliasPai)->(DbSetOrder(2))
				Else
					&(cAliasPai)->(DbSetOrder(1))	
				Endif 
				&(cAliasPai)->( MsSeek( xFilial(cAliasPai)+Left(cChaveB,18) ))
				
				&(cAliasPai)->(recLock((cAliasPai),.f.))
					&(cAliasPai+"->"+cAliasPai+"_STTISS") := PLSANLSTIG("6") //Em análise da Operadora
				&(cAliasPai)->(msUnLock())
			endIf
			
			PLSATUAUD(cTpPublico, cParecer, cResInt,cObsMotPad)
		endIf
		
	endIf
	End Transaction 
	MsgInfo(STR0092)  //'Resposta salva com sucesso'
endif
cObsMotPadVis	:= ""
cDesMotPadVis	:= ""
cCampoMot		:= ""
return

/*/{Protheus.doc} PLRELRDAExe
Retorna as RDAs com acesso ao portal
@type function
@author TOTVS
@since 30/07/2015
@version 1.0
/*/
Function PLRELRDAExe(cSql,aRet)
LOCAL cRegAte 	:= ""
LOCAL aMatEsp 	:= {}
Local aArea   	:= GetArea()
Local lInclui   := .T.
Local nI        := 0
Local cTipPreZ	:= GetNewPar("MV_PLSTPHS","HOS")
LOCAL lLsEspBAQ  := GetNewPar("MV_PLSESPP",.T.) //Lista as especialidades da BAX com DESC da BAQ
LOCAL cIntPad    := PLSINTPAD()

// Execute
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSql)),"TRBBE",.F.,.T.)

If !lLsEspBAQ      
	BAQ->(DbSetOrder(1))
	BAQ->(DBGoTop())	
	While !BAQ->( Eof() ) .And. BAQ->(BAQ_FILIAL+BAQ_CODINT) == xFilial("BAQ")+cIntPad

		If !Empty(BAQ->BAQ_CBOS)
			AaDd( aMatEsp,{BAQ->BAQ_CODESP,;
				BAQ->BAQ_DESCRI,;
				BAQ->BAQ_CBOS,;
				BAQ->BAQ_DESCBO } )
		EndIf
		BAQ->( DbSkip() )
	EndDo	
EndIf
// Monta matriz de retorno

While !TRBBE->( Eof() )

	// Monta a matriz de especialidade
	If BAX->( MsSeek( xFilial("BAX")+TRBBE->(BSO_CODIGO+BSO_CODINT+BSO_CODLOC) ) )
		If lLsEspBAQ
		aMatEsp := {}
		EndIf
			
		While !BAX->( Eof() ) .And. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAX")+TRBBE->(BSO_CODIGO+BSO_CODINT+BSO_CODLOC) .And. lLsEspBAQ
			If BAQ->( MsSeek( xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP) ) ) .And. (Empty(BAX->BAX_DATBLO) .Or. dDataBase < BAX->BAX_DATBLO)
			
				If !Empty(BAQ->BAQ_CBOS)
			
					AaDd( aMatEsp,{	BAQ->BAQ_CODESP,;
									BAQ->BAQ_DESCRI,;
									BAQ->BAQ_CBOS,;
									BAQ->BAQ_DESCBO } )
				EndIf
				
			EndIf
			
		BAX->( DbSkip() )
		EndDo
		
		// Pega as especialidades do corpo clinico
		If GetNewPar("MV_PLESPCL","1") == "1" .And. lLsEspBAQ
			cSql := " SELECT DISTINCT BAX_CODESP "
			cSql += "  FROM " + cBC1 + "," + cBAX
			cSql += " WHERE BC1_FILIAL = '" + xFilial("BC1") + "' "
			cSql += "   AND BC1_CODIGO = '" + TRBBE->BSO_CODIGO + "' "
			cSql += "   AND BC1_CODLOC = '" + TRBBE->BSO_CODLOC + "' "
			cSql += "	AND " + cBC1 + ".D_E_L_E_T_ = ' ' "
			cSql += "   AND BAX_FILIAL = '" + xFilial("BAX") + "' "
			cSql += "   AND BAX_CODIGO = BC1_CODRDA "
			cSql += "   AND BAX_CODINT = BC1_CODINT "
			cSql += "   AND BAX_DATBLO = '" + Space( TamSx3("BAX_DATBLO")[1] ) + "' "
			cSql += "	AND " + cBAX + ".D_E_L_E_T_ = ' ' "
			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSql)),"TRBECC",.F.,.T.)

			While !TRBECC->( Eof() )

				If BAQ->( MsSeek( xFilial("BAQ")+TRBBE->BSO_CODINT+TRBECC->BAX_CODESP ) )

					If !Empty(BAQ->BAQ_CBOS) .And. Ascan(aMatEsp,{|x| x[1] == BAQ->BAQ_CODESP } ) == 0

						AaDd( aMatEsp,{	BAQ->BAQ_CODESP,;
										BAQ->BAQ_DESCRI,;
										BAQ->BAQ_CBOS,;
										BAQ->BAQ_DESCBO } )
							
					EndIf
					
				EndIf
				
			TRBECC->( DbSkip() )
			EndDo
			
			TRBECC->( DbCloseArea() )
			
		EndIf
	EndIf
	
	// Tipo de Regime
	cRegAte := Iif(TRBBE->BAU_TIPPRE != cTipPreZ,'NORMAL','EMERGENCIA') //Alterado devido lentidão. Havia casos do login demorar mais de 2 minutos e de o prestador nem conseguir logar
	
	// Matriz
	If !Empty(aRet)
		lInclui := .T.
		For nI:=1 to len(aRet)
			If aRet[nI][1] == TRBBE->BAU_CODIGO .And. LEN(aRet[nI][7])>0 .And. aRet[nI][7] == TRBBE->BSO_CODLOC
				lInclui := .F.
			Endif
		Next nI
	Endif
	
	If lInclui
			AaDd( aRet,{TRBBE->BAU_CODIGO,;														//1
						TRBBE->BAU_NOME,;														//2
						cRegAte,;																//3
						TRBBE->BAU_TIPPRE,;														//4
						TRBBE->BAU_CPFCGC,;														//5
						TRBBE->BB8_CNES,;														//6
						TRBBE->BB8_TIPLOG,;														//7
						AllTrim(TRBBE->BB8_END),;												//8
						TRBBE->BB8_NR_END,;														//9
						AllTrim(TRBBE->BB8_COMEND),;											//10
						Posicione("BID",1,xFilial("BID")+TRBBE->BB8_CODMUN,"BID_DESCRI"),;		//11 MUNICIPIO
						TRBBE->BB8_BAIRRO,;														//12
						TRBBE->BB8_EST,;														//13
						TRBBE->BB8_CODMUN,;														//14 IBGE
						TRBBE->BB8_CEP,;														//15
						Posicione("BA0",1,xFilial("BA0")+TRBBE->BSO_CODINT,"BA0_SUSEP"),;		//16
						TRBBE->BB8_TEL,;														//17
						TRBBE->BAU_SIGLCR,;														//18
						TRBBE->BAU_CONREG,;														//19
						TRBBE->BAU_ESTCR,;														//20
						TRBBE->BAU_TIPPE,;														//21
						TRBBE->BAU_CODBB0,;														//22
						TRBBE->BSO_CODINT,;														//23
						TRBBE->BSO_CODLOC,;														//24
						Posicione("BB8",1,xFilial("BB8")+TRBBE->(BSO_CODIGO+BSO_CODINT+BSO_CODLOC),"BB8_DESLOC"),;//25
						aMatEsp,;                                                            	//26
						AllTrim(TRBBE->BB8_COMEND),; 										 	//27
						AllTrim(TRBBE->BB8_CARSOL),; 											//28
						AllTrim(IiF(BAU->(FieldPos("BAU_TISVER"))>0,TRBBE->BAU_TISVER,'') ),;     //29
						TRBBE->RECNOBAU          } ) 	//30
		
	Endif
	
TRBBE->( DbSkip() )
EndDo

TRBBE->( DbCloseArea() )

RestArea(aArea)

Return()

/*/{Protheus.doc} PLSRETMSG
Retorna mensagem do portal.
cIdioma = POR - POrtugês  ING - Inglês  ESP - Espanhol  *****Padrão Portugês
@type function
@author Roberto Vanderlei
@since 18.08.2015
@version 1.0
/*/
Function PLSRETMSG(cTipoPortal, cCodigoMsg, cIdioma, cRotina)
Local nOrdem 	:= 1
Local cFiltro 	:= ""
Local cCmps 	:= "BMV->(BMV_FILIAL+"
Local aMensagens:= {}

Default cCodigoMsg 	:= ""
Default cIdioma 	:= "POR"
Default cRotina 	:= ""

If Empty(cCodigoMsg)

	cFiltro := cTipoPortal+cRotina
	cCmps += "BMV_TPPOR"

	If !(Empty(cRotina))
		cCmps += "+BMV_ROTINA"
	EndIf
	
	nOrdem := 2
Else
	cFiltro := cCodigoMsg
	cCmps += "BMV_CODIGO"
	nOrdem := 1
EndIf

cCmps += ")"

BMV->(DbSetOrder(nOrdem))
If (BMV->(MsSeek(xFilial("BMV") + cFiltro)))
	
	While ! BMV->(Eof()) .AND. RTrim(&(cCmps)) == (xFilial("BMV") + cFiltro)
		aadd(aMensagens, {BMV->BMV_CODIGO, if(cIdioma = "POR", BMV->BMV_MSGPOR, if(cIdioma = "ING", BMV->BMV_MSGING, BMV->BMV_MSGESP))})
		
	BMV->(DbSkip())
	Enddo
	
EndIf

Return aMensagens

/*/{Protheus.doc} PLSGETBA1
Retorna os beneficiários vinculados a familia ou a empresa
@type function
@author Karine Riquena Limp
@since 10.09.2015
@version 1.0
/*/
Function PLSGETBA1(nTpPor, cCodLWeb, cMatUsu, cSoFam)
LOCAL cAlias	:= "BA1"
LOCAL cAliasAux	:= Iif( nTpPor==2 ,"B40" ,"B49")
LOCAL cSql 		:= ""
LOCAL cPlusW	:= ""
DEFAULT cMatUsu := ""
DEFAULT cSoFam := ""

// Query para retornar dados do F3
cSql := "SELECT BA1_CODINT,BA1_CODEMP as BA1CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CODEMP,BA1_NOMUSR," + RetSQLName(cAliaS) + ".R_E_C_N_O_ RECNO"
cSql += "  FROM " + RetSQLName(cAlias) + ", " + RetSQLName(cAliasAux)
cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "
cSql += "   AND " + RetSQLName(cAliasAux) +	".D_E_L_E_T_ = ' ' "
// Empresa
If nTpPor == 2
	cSql += " AND B40_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += " AND B40_CODUSR = '" + cCodLWeb + "' "
	cSql += " AND BA1_CODINT = B40_CODINT "
	cSql += " AND BA1_CODEMP = B40_CODEMP "
	cSql += " AND BA1_CONEMP = B40_NUMCON "
	cSql += " AND BA1_VERCON = B40_VERCON "
	cSql += " AND BA1_SUBCON = B40_SUBCON "
	cSql += " AND BA1_VERSUB = B40_VERSUB "
	// Filtrando a familia pela matricula de qualquer um dos integrantes da mesma
	If !Empty(cMatUsu)
		cSql += " AND(BA1_CODINT + BA1_CODEMP + BA1_MATRIC) = '" + left(cMatUsu, 14) + "' "
	EndIf
	// Somente familia
	If !Empty(cSoFam)
		cSql += " AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
	EndIf
	
	// Contrato
	B40->( DbSetOrder(1) )//B40_FILIAL + B40_CODUSR + B40_CODINT + B40_CODEMP + B40_NUMCON + B40_VERCON + B40_SUBCON + B40_VERSUB
	B40->( MsSeek( xFilial("B40") + cCodLWeb ) )
	
	While !B40->( Eof() ) .And. B40->B40_CODUSR == cCodLWeb
		If Empty( B40->(B40_SUBCON+B40_VERSUB) ) .And. At( B40->(B40_SUBCON+B40_VERSUB),cPlusW) == 0
			cPlusW += "'" + B40->(B40_CODEMP+B40_NUMCON+B40_VERCON) + "',"
		EndIf
		B40->( DbSkip() )
	EndDo
	// Where
	If !Empty(cPlusW)
		cSql += " UNION "
		
		cSql += "SELECT BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CODEMP,BA1_NOMUSR," + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO"
		cSql += "  FROM " + RetSQLName(cAlias) + ", " + RetSQLName(cAliasAux)
		cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "
		cSql += "   AND " + RetSQLName(cAliasAux) +	".D_E_L_E_T_ = ' ' "
		
		cSql += "   AND B40_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND B40_CODUSR = '" + cCodLWeb + "' "
		cSql += "   AND BA1_CODINT = B40_CODINT "
		// Somente familia
		If !Empty(cSoFam)
			cSql += "   AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
		EndIf
		cSql += " AND BA1_CODEMP,BA1_CONEMP,BA1_VERCON IN(" + Left(cPlusW,Len(cPlusW)-1) + ") "
	EndIf
	// Beneficiario
ElseIf nTpPor == 3
	cSql += " AND B49_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += " AND B49_CODUSR = '" + cCodLWeb + "' "
	cSql += " AND (BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) = B49_BENEFI "	

	// Somente familia
	If !Empty(cSoFam)
		cSql += " AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
	EndIf
EndIf

cSql += " ORDER BY BA1CODEMP,BA1_NOMUSR "
Return cSql

/*/{Protheus.doc} PLSGETREE
Retorna beneficiários com acesso ao reembolso BA1_REEWEB
@type function
@author Renan Martins
@since 21/03/2012
@version 1.0
/*/
Function PLSGETREE(nTpPor, cCodLWeb, cMatUsu, cSoFam, cPermReb) 

LOCAL cAlias	:= "BA1"
LOCAL cSql 		:= ""

cSql := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,BA1_NOMUSR, BA1_DATINC, BA1_DATBLO"

If BA3->(fieldPos('BA3_CODRAS')) > 0 
	cSql += ",BA3_CODRAS, BA3_CODPLA"
EndIf 

cSql += " FROM " + RetSQLName(cAlias)

If BA3->(fieldPos('BA3_CODRAS')) > 0 
	cSql += " INNER JOIN " + RetSQLName("BA3")
	cSql += " ON BA3_CODINT = BA1_CODINT AND BA3_CODEMP = BA1_CODEMP AND BA3_MATRIC = BA1_MATRIC "
EndIf 

cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "

If BA3->(fieldPos('BA3_CODRAS')) > 0
	cSql += " AND " + RetSQLName("BA3") + ".D_E_L_E_T_ = ' ' "
EndIf

cSql += " AND " + RetSQLName(cAlias) + ".D_E_L_E_T_ = ' ' "

If nTpPor == 3 .and. cPermReb == '1'
	
	If ! empty(cMatUsu)
		B49->( dbSetOrder(2) )
		B49->( MsSeek(xFilial(cAlias) + cMatUsu) )
	Else
		B49->( dbSetOrder(1) )
		B49->( MsSeek(xFilial(cAlias) + cCodLWeb) )
	EndIf	
	
	if B49->(found())
		cSql += " AND BA1_CODINT = '" + left(B49->(B49_BENEFI), 4) + "' AND BA1_CODEMP = '" + Substr(B49->(B49_BENEFI), 5,4) + "' AND BA1_MATRIC = '" + Substr(B49->(B49_BENEFI),9,6)+ "'"
	endIf	
	
	cSql += " AND BA1_REEWEB = '1'"

endIf

If BA3->(fieldPos('BA3_CODRAS')) > 0
	cSql += " GROUP BY BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,BA1_NOMUSR, BA1_DATINC, BA1_DATBLO, BA3_CODRAS, BA3_CODPLA"
	cSql += " ORDER BY BA3_CODPLA "
Else
	cSql += " GROUP BY BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,BA1_NOMUSR, BA1_DATINC, BA1_DATBLO"
	cSql += " ORDER BY BA1_NOMUSR "
EndIf

Return cSql

/*/{Protheus.doc} PLSRELGUI
Retorna Relacionamento com Guias
@type function
@author Mario A. Cavenaghi
@since 21/03/2012
@param cTabela, caracter, 	Alias que sera pesquisado
@param nOpcao , numerico, 	Posição do Alias a retornar
Sendo: 1.Guia 2.Procedimento 3.Crítica
@param lEvo   , logico	, 	.F. Críticas (Padrão) ou .T. Evolução
@version 1.0
/*/
Function PLSRELGUI(cTabela, nOpcao, lEvo)
LOCAL nFor 		:= 0
LOCAL cRetTab 	:= "" 
local cEvo 		:= ""

DEFAULT lEvo := .F.

//{"Guia", "Procedimento", "Crítica", "Evolução"}
STATIC __aTabGuias := {;		//	Tabela de Guias
{"BEA", "BE2", "BEG", "P"},;	//	Atendimentos (SADT)
{"BEA", "BQV", "BQZ", "E"},;	//	Prorrogação Atendimento (Evolução)
{"BE4", "BEJ", "BEL", "P"},;	//	Internação
{"BE4", "BQV", "BQZ", "E"},;	//	Prorrogação Internação (Evolução)
{"B44", "B45", "B46", "P"},;	//	Autorização de Reembolso
{"B4A", "B4C", "BEG", "P"},;	//	Anexos Clínicos (Quimio/Radio/OPME)
{"BD5", "BD6", "BDX", "P"},;	//	Proc. Contas (Contas Médicas)
{"BOW", "B1N", "B14", "P"},;	//	Protocolo de Reembolso
{"B53", "B72", "B67", "P"},;	// 	Auditoria
{"B4Q", "BQV", "BQZ", "E"} }	//	Prorrogaçãod e Internação Nova

cEvo := IIF(lEvo, "E", "P")	//	Evolução ou Procedimento
nOpcao := IIF(nOpcao > 3, 3, nOpcao)
FOR nFor := 1 TO LEN(__aTabGuias)
	IF ASCAN(__aTabGuias[nFor], {|x| x == cTabela}) > 0
		IF !lEvo .OR. __aTabGuias[nFor, 4] == cEvo	//	Independe da Evolução OU Só Evolução
			cRetTab := __aTabGuias[nFor, nOpcao]
			EXIT
		ENDIF
	ENDIF
NEXT
	
return(cRetTab)

/*/{Protheus.doc} PicCpfCnpj
Gera Máscara Dinâmica para CPF ou CNPJ
@author Mário A. Cavenaghi
@since 20-04-16
/*/
Function PicCpfCnpj(cCampo)
LOCAL cPict := cConteudo := ""
LOCAL nPos := nLen := 0

DEFAULT cCampo := __ReadVar

IF !EMPTY(cCampo)
	nPos := AT("->", cCampo)	//	Localiza a posição do operador ALIAS "->", "M->" ou "MMM->"
	nPos += IIF(nPos > 0, 2, 1)	//	Posição de início do nome do campo
	cPict := SX3->(ALLTRIM(X3PICTURE(SUBSTR(cCampo, nPos))))
	IF !EMPTY(cPict)
		cConteudo := ALLTRIM(&cCampo)
		nLen := LEN(cConteudo)
		IF     nLen == 11 //Se 11 caracteres, formata para CPF
			cPict := "@R 999.999.999-99"
		ELSEIF nLen == 14 //Se 14 caracteres, formata para CNPJ
			cPict := "@R 99.999.999/9999-99"
		ENDIF
		IF !EMPTY(cConteudo)
			nPos := TAMSX3(SUBSTR(cCampo, nPos))[1]
			cPict += REPLICATE("9", nPos - nLen)	//	 Para manter o tamanho original do Campo
		ENDIF
		cPict += "%C"
	ENDIF
ENDIF

RETURN(cPict)

/*/{Protheus.doc} PicFone
Gera Máscara Dinâmica para Telefone Fixo ou Celular
@author Mário A. Cavenaghi
@since 20-04-16
/*/
FUNCTION PicFone(cCampo)

LOCAL cPict := cConteudo := ""
LOCAL nPos := nLen := 0

DEFAULT cCampo := __ReadVar

IF !EMPTY(cCampo)
	nPos := AT("->", cCampo)	//	Localiza a posição do operador ALIAS "->", "M->" ou "MMM->"
	nPos += IIF(nPos > 0, 2, 1)	//	Posição de início do nome do campo
	cPict := SX3->(ALLTRIM(X3PICTURE(SUBSTR(cCampo, nPos))))
	IF !EMPTY(cPict)
		cConteudo := ALLTRIM(&cCampo)
		nLen := LEN(cConteudo)
		IF     nLen == 11	//	DDD Celular
			cPict := "@R (99) 9.9999-9999"
		ELSEIF nLen == 10	//	DDD Fixo
			cPict := "@R (99) 9999-9999"
		ENDIF
		IF !EMPTY(cConteudo)
			nPos := TAMSX3(SUBSTR(cCampo, nPos))[1]
			cPict += REPLICATE("9", nPos - nLen)	//	 Para manter o tamanho original do Campo
		ENDIF
		cPict += "%C"
	ENDIF
ENDIF

RETURN(cPict)

/*/{Protheus.doc} ValFone
Gera máscara para Telefone Fixo / Celular
@author Mário A. Cavenaghi
@since 20-04-16
/*/
FUNCTION ValFone(cCampo)
LOCAL cConteudo := ""
LOCAL lRet 		:= .T.

DEFAULT cCampo := __ReadVar

cConteudo := ALLTRIM(&cCampo)
IF LEN(cConteudo) < 10
	lRet := .F.
ENDIF
	
RETURN(lRet)

/*/{Protheus.doc} PLSSTATUS
Retorna os status para as guias de atendimento
OBS: Esta função foi criada pois o tamanho do X3_CBOX era insuficiente
@type function
@author Thiago Ribas
@since 21/03/2012
@version 1.0
/*/
Function PLSSTATUS(cAlias)
LOCAL cStatus := ""

DEFAULT cAlias := ""

If cAlias == "B4A"
	cStatus := "1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada;6=Em analise pela auditoria"
ElseIf cAlias $ "BEA,BE4,B4Q"
	cStatus := "1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada;4=Aguardando finalizacao do atendimento;5=Aguardando Liq. Titulo a Receber;6=Em analise pela auditoria"
ElseIf cAlias == "B44"
	cStatus := "1=Aguardando finalizacao atendimento;2=Aprovado para pagamento;3=Nao Autorizada;4=Aprovado Parcialmente;5=Aguardando Liq. Titulo a Pagar;6=Em analise pela auditoria"
EndIf
	
Return(cStatus)

/*/{Protheus.doc} PlVldInt
Validação para não permitir incluir interações direcionadas ao beneficiário
enquanto existir uma interação com o status de aguardando anexo
@type function
@author Thiago Ribas
@since 21/03/2012
@version 1.0
/*/
Function PlVldInt(nPosFlag, aDadProc, cTpPubli, cParecer,oList)
LOCAL lret  := .T.
LOCAL lFlag := aDadProc[nPosFlag][Len(aDadProc[nPosFlag])]

If cTpPubli <> "Prestador"
	cParecer := "Não"
EndIf

If lFlag .AND. cTpPubli == "Beneficiário"
	
	BBR->(dbSetOrder(1))
	If BBR->(MSSEEK(xFilial("BBR") + B53->B53_NUMGUI))
		
		While BBR->(BBR_CODOPE + BBR_ANOAUT + BBR_MESAUT + BBR_NUMAUT) == B53->B53_NUMGUI
			
			If BBR->BBR_TPDIRP == "B"
				
				lRet := .F.
				MarcaLinha(nPosFlag,aDadProc,.F.)
				oList:Refresh()
				MsgAlert(STR0089,;//"Existe uma interação aguardando a resposta do beneficiário. Apenas interações internas são permitidas.
				STR0028)//"Atenção"
				
				EXIT
			EndIf
			
			BBR->(DbSkip())
		EndDo
	EndIf
EndIf

return lRet

/*/{Protheus.doc} VldBlqFut
Valida bloqueio futuro de uma RDA no portal
@author Lucas Nonato
@since 05/08/16
/*/
Function VldBlqFut(cCodRda)
Local lRet := .F.
Local cSql := ""

cSql += " SELECT BSO_CODIGO "
cSql += "   FROM " + RetSQLName("BSO")
cSql += "  WHERE BSO_FILIAL = '" + xFilial('BSO') + "' "
cSql += "    AND BSO_CODUSR = '" + cCodRda + "' "
cSql += "    AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSQL)),"BSOTMP",.F.,.T.)

while !BSOTMP->(EOF())
	
	If A360CHEBLO(BSOTMP->(BSO_CODIGO),dDataBase,.T.,TIME(),.T.)
		
		lRet := .T.
		Exit
	EndIf
	
	BSOTMP->(dbSkip())
EndDo

BSOTMP->(dbCloseArea())

Return lRet


/*/{Protheus.doc} PLSTranCh
Busca em uma string vogais com acentuação e as substitui por pelas normais

@type function
@author victor.silva
@since 23/08/2016
@version 1.0
@param cString, caracter, String com o conteudo a ser transformado
@return cString, String formatada
/*/
Function PLSDelTra(cString)
cString := StrTran(cString,"ç","c")
cString := StrTran(cString,"á","a")
cString := StrTran(cString,"ã","a")
cString := StrTran(cString,"à","a")
cString := StrTran(cString,"â","a")
cString := StrTran(cString,"é","e")
cString := StrTran(cString,"è","e")
cString := StrTran(cString,"ê","e")
cString := StrTran(cString,"í","i")
cString := StrTran(cString,"ì","i")
cString := StrTran(cString,"ó","o")
cString := StrTran(cString,"ò","o")
cString := StrTran(cString,"õ","o")
cString := StrTran(cString,"ô","o")
cString := StrTran(cString,"ú","u")
cString := StrTran(cString,"ù","u")
cString := StrTran(cString,"Á","A")
cString := StrTran(cString,"À","A")
cString := StrTran(cString,"Â","A")
cString := StrTran(cString,"Ã","A")
cString := StrTran(cString,"É","E")
cString := StrTran(cString,"È","E")
cString := StrTran(cString,"Ê","E")
cString := StrTran(cString,"Í","I")
cString := StrTran(cString,"Ì","I")
cString := StrTran(cString,"Ó","O")
cString := StrTran(cString,"Ò","O")
cString := StrTran(cString,"Õ","O")
cString := StrTran(cString,"Ô","O")
cString := StrTran(cString,"Ú","U")
cString := StrTran(cString,"Ç","C")
	
return(cString)

/*/{Protheus.doc} PLSPreEsp
Retorna a especialidade principal do prestador ou as especialidades do mesmo caso o parametro de Local de atendimento não for informado

@type function
@author victor.silva
@since 26/08/2016
@version 1.0
@param cCodRda, caracter, Codigo do Prestador
@param cCodOpe, caracter, Codigo da Operadora
@param cLocEsp, caracter, Codigo do local de atendimento
@param cDatRef, caracter, Data de Referencia para bloqueio no formato "aaaammdd"
@return xRet, 	cLocEsp informado: caracter com a especialidade principal/cLocEsp nao informado: array com as especialidades principais de cada local de atendimento
/*/
Function PLSPreEsp(cCodRda,cCodOpe,cLocEsp,cDatRef)
Local cSqlEspPri 	:= GetNextAlias()
Local xRet				:= nil
Local lConLoc 		:= .F.
Local lConBlc			:= .F.

Default cLocEsp		:= ""
Default cDatRef		:= ""

lConLoc := !Empty(cLocEsp)
lConBlc	:= !Empty(cDatRef)

If ValType(cDatRef) == "D"
	cDatRef	:= DtoS(cDatRef)
EndIf

cWhere := "%"
If lConLoc
	cWhere += "BAX_ESPPRI	= 	'1' AND "
	cWhere += "BAX_CODLOC = '" + cLocEsp + "' AND "
	Iif(lConBlc,cWhere += "(BAX_DATBLO = ' ' OR (BAX_DATBLO <> ' ' AND BAX_DATBLO > '" + cDatRef + "')) AND ",nil)
Else
	Iif(lConBlc,cWhere += "(BAX_DATBLO = ' ' OR (BAX_DATBLO <> ' ' AND BAX_DATBLO > '" + cDatRef + "')) AND ",nil)
EndIf
cWhere += "%"

BeginSql alias cSqlEspPri
	SELECT
	BAX_CODESP,BAX_CODLOC,BAX_DATBLO
	FROM
	%table:BAX% BAX
	WHERE
	BAX_FILIAL	= 	%xFilial:BAX% AND
	BAX_CODINT	= 	%exp:cCodOpe% AND
	BAX_CODIGO	= 	%exp:cCodRda% AND
	%exp:cWhere%
	BAX.%notdel%
	ORDER BY BAX_CODLOC
EndSql

If !(cSqlEspPri)->(Eof())
	If lConLoc
		xRet := (cSqlEspPri)->BAX_CODESP
	Else
		xRet := {}
		//Alimentando o array com os dados das especialidades encontradas na consulta
		While !(cSqlEspPri)->(Eof())
			/*
			Estrutura do aEsp
			[1] - Codigo da Especialidade
			[2] - Codigo do Local de atendimento
			[3] - Flag informando se a especialidade esta bloqueada (0-Nao/1-Sim)
			*/
			aAdd(xRet,{	(cSqlEspPri)->BAX_CODESP,;
				(cSqlEspPri)->BAX_CODLOC,;
				Iif(lConBlc,"0",Iif(((Empty((cSqlEspPri)->BAX_DATBLO)) .Or. (!Empty((cSqlEspPri)->BAX_DATBLO) .And. (cSqlEspPri)->BAX_DATBLO > cDatRef)),"0","1"))})
			
			//Proximo resultado
			(cSqlEspPri)->(DbSkip())
		Enddo
	EndIf
EndIf

(cSqlEspPri)->(DbCloseArea())

Return xRet

/*/{Protheus.doc} PlsFreArr
Libera espaco utilizado em memoria pelo endereco do array informado no parametro

@type function
@author victor.silva
@since 17/08/2016
@version 1.0
/*/
function PlsFreArr(aArray)

if ValType(aArray) == "A"
	aSize(aArray,0)
	aArray := Nil
	aArray := {}
endif

return

/*/{Protheus.doc} PLSEXMCTB
Exclui movimento contabil

@author  PLS TEAM
@version P12
@since   25.07.16
/*/
function PLSEXMCTB(cTipo, cChave, lWeb)
local aAreaBD7 		:= BD7->(getArea())
local lRet			:= .t.

local lBD7_DTPRO	:= BD7->(fieldPos('BD7_DTPRO')) > 0
local lBD7_CHVPRO	:= BD7->(fieldPos('BD7_CHVPRO')) > 0
local lBD7_DTLA		:= BD7->(fieldPos('BD7_DTLA')) > 0
local lBD7_CHVLA	:= BD7->(fieldPos('BD7_CHVLA')) > 0

default lWeb		:= .f.

//se nao existe nao executa nada
if !lBD7_DTPRO .or. !lBD7_CHVPRO .or. !lBD7_DTLA .or. !lBD7_CHVLA
	lRet := .f.
endIf

if lRet 
	
	//verifica se existe algum registro contabilizado
	if PLCHKCTB(cTipo, cChave)
	
		BD7->(dbSetOrder(1)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		
		//retorno de fase	
		if  cTipo == "A" .or. cTipo == "T"
			
			if !lWeb 
				lRet := msgYesNo("Confirma a exclusão do movimento contábil?")
			endIf
			
		endIf
			
		if lRet
		
			lRet := setEMovCTB( cTipo, cChave )
			
		endIf	
		
	endIf	
	
endIf

restArea(aAreaBD7)
	
return(lRet)

/*/{Protheus.doc} setEMovCTB
Verifica se existe registro contabilizado de custo
@author  PLS TEAM
@version P12
@since   20.01.17
/*/
function PLCHKCTB(cTipo,cChave)
local lRet := .f.
 


If GetNewPar("MV_PLNOCB",.F.)
	//De forma paliativa foi criado esse paramentro pois precisamos desabilitar o controle para que o sistema impessa 
	// a contabilização das Guias ja contabilizada, esse item foi criado para CEMIG na nersao 12.7  e no futuro devera ser retirado
	return(lRet) 
Endif

SIX->(dbSetOrder(1))

//alteracao guia em digitacao
if cTipo  == 'D'

	if SIX->(MsSeek("BD7G"))
		
		BD7->(dbSetOrder(16)) //BD7_FILIAL+BD7_LAPRO+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		lRet := BD7->( msSeek( xFilial('BD7') + 'S' + cChave) ) .and. !empty(BD7->BD7_CHVPRO) // !empty(BD7->BD7_CHVPRO) para clientes que nao implanto a nova CTB
		
	endIf
	
//ativa e pronta
elseIf cTipo  == 'A'

	if SIX->(MsSeek("BD7H"))
		
		BD7->(dbSetOrder(17)) //BD7_FILIAL+BD7_LA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		lRet := BD7->( msSeek( xFilial('BD7') + 'S' + cChave) ) .and. !empty(BD7->BD7_CHVLA)
		
	endIf
	
//digitacao e ativa e pronta	
elseIf cTipo  == 'T'

	if SIX->(MsSeek("BD7G"))
		
		BD7->(dbSetOrder(16)) //BD7_FILIAL+BD7_LAPRO+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		lRet := BD7->( msSeek( xFilial('BD7') + 'S' + cChave) ) .and. (!empty(BD7->BD7_CHVPRO) .or. !empty(BD7->BD7_CHVLA) )
		
	endIf
	
	if SIX->(MsSeek("BD7H")) .and. !lRet
		
		BD7->(dbSetOrder(17)) //BD7_FILIAL+BD7_LA+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		lRet := BD7->( msSeek( xFilial('BD7') + 'S' + cChave) ) .and. (!empty(BD7->BD7_CHVPRO) .or. !empty(BD7->BD7_CHVLA) )
		
	endIf


endIf	
	  
return(lRet)

/*/{Protheus.doc} setEMovCTB
Realiza a exclusao do movimento contabil ligado a um lancamento da BD7

@author  PLS TEAM
@version P12
@since   25.07.16
/*/
static function setEMovCTB( cTipo, cChave )
local nI		:= 0
local nOpc	 	:= 5
local nPos		:= 0
local nTamDATA 	:= CT2->(tamSX3("CT2_DATA")[1])
local nTamLOTE	:= CT2->(tamSX3("CT2_LOTE")[1])
local nTamSBLOTE:= CT2->(tamSX3("CT2_SBLOTE")[1])
local nTamDOC	:= CT2->(tamSX3("CT2_DOC")[1])
local cLote		:= ''
local cSubLote	:= ''
local cDoc		:= ''
local cChvCTB	:= ''
local cChvCTBC	:= ''
local aItens 	:= {}
local aCab 	 	:= {}
local dDataLanc	:= ctod('')
local lRet		:= .t.
local lAtu		:= .f.
local lAtuC		:= .f.

private lMsErroAuto := .f.

if !empty(cChave)

	if BD7->( msSeek( xFilial('BD7') + cChave) )
	
		while !BD7->(eof()) .and. allTrim(xFilial('BD7') + cChave) $ allTrim( BD7->&(indexKey() ) )

			lAtu 	:= .f.
			lAtuC 	:= .f.
			
			//alteracao da guia
			if cTipo == "D" 
			
				if !empty(BD7->BD7_CHVPRO) .and. cChvCTB != BD7->BD7_CHVPRO
					cChvCTB := BD7->BD7_CHVPRO
					lAtu 	:= .t.
				endIf
				
			//retorno de fase		
			elseIf cTipo == "A"  
	
				if !empty(BD7->BD7_CHVLA) .and. cChvCTB != BD7->BD7_CHVLA
					cChvCTB := BD7->BD7_CHVLA
					lAtu 	:= .t.
				endIf
				
			//tratamento para provisao e custo
			elseIf cTipo == "T"  

				if !empty(BD7->BD7_CHVPRO) .and. cChvCTB != BD7->BD7_CHVPRO
					cChvCTB := BD7->BD7_CHVPRO
					lAtu := .t.
				endIf
	
				if !empty(BD7->BD7_CHVLA) .and. cChvCTB != BD7->BD7_CHVLA .and. cChvCTBC != BD7->BD7_CHVLA
					cChvCTBC := BD7->BD7_CHVLA
					lAtuC := .t.
				endIf
				
			endIf
			
			//exclui movimento
			if lAtu
			
				dDataLanc 	:= stod(left(cChvCTB, nTamDATA))
				cLote		:= subStr(cChvCTB, nTamDATA + 1, nTamLOTE)
				cSubLote	:= subStr(cChvCTB, (nTamDATA + nTamLOTE)+ 1, nTamSBLOTE)
				cDoc		:= subStr(cChvCTB, (nTamDATA + nTamLOTE + nTamSBLOTE) + 1, nTamDOC)
				aCab		:= {}
				
				aadd(aCab, {'DDATALANC', dDataLanc , nil})
				aadd(aCab, {'CLOTE', 	 cLote, nil})
				aadd(aCab, {'CSUBLOTE',  cSubLote, nil})
				aadd(aCab, {'CDOC', 	 cDoc, nil})
				
				msExecAuto({|x, y, z| CTBA102(x, y, z)}, aCab, aItens, nOpc)
				
				if lMsErroAuto
					mostraErro()
					return .f.
				endIf
				
			endIf
			
			//exclui movimento
			if lAtuC
			
				dDataLanc 	:= stod(left(cChvCTBC, nTamDATA))
				cLote		:= subStr(cChvCTBC, nTamDATA + 1, nTamLOTE)
				cSubLote	:= subStr(cChvCTBC, (nTamDATA + nTamLOTE)+ 1, nTamSBLOTE)
				cDoc		:= subStr(cChvCTBC, (nTamDATA + nTamLOTE + nTamSBLOTE) + 1, nTamDOC)
				aCab		:= {}
				
				aadd(aCab, {'DDATALANC', dDataLanc , nil})
				aadd(aCab, {'CLOTE', 	 cLote, nil})
				aadd(aCab, {'CSUBLOTE',  cSubLote, nil})
				aadd(aCab, {'CDOC', 	 cDoc, nil})
				
				msExecAuto({|x, y, z| CTBA102(x, y, z)}, aCab, aItens, nOpc)
				
				if lMsErroAuto
					mostraErro()
					return .f.
				endIf
				
			endIf	
			
		BD7->(dbSkip())
		endDo
		
	endIf
	
endIf

return(lRet)

/*/{Protheus.doc} PlPreEspBl
Verifica se a especialidade enviada esta bloqueada no cadastro do Prestador
com base na data informada
@type function
@author victor.silva
@since 14/09/2016

/*/
function PlPreEspBl(cCodPre,cCodInt,cCodLoc,cCodEsp,dDatRef)
local lRet		:= .T.
local nIdx		:= 0
local cChave	:= ""

default cCodInt	:= PLSIntPad()
default cCodLoc	:= ""
default cCodEsp	:= ""
default dDatRef	:= dDataBase

//Se a especialidade chegar em branco, nao precisa fazer a validacao
if empty(cCodEsp)
	return .F.
endif

//Define indice de pesquisa conforme parametros
if empty(cCodLoc)
	nIdx		:= 3 //BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO
	cChave	:= cCodInt + cCodEsp + cCodPre
else
	nIdx		:= 2 //BAX_FILIAL+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODIGO
	cChave	:= cCodInt + cCodLoc + cCodEsp + cCodPre
endif

//Buscando a especialidade no Prestador
dbSelectArea("BAX")
BAX->(dbSetOrder(nIdx))
if BAX->(MsSeek(xFilial("BAX") + cChave))
	if (empty(BAX->BAX_DATBLO) .Or. (!empty(BAX->BAX_DATBLO) .And. BAX->BAX_DATBLO > dDatRef))
		lRet := .F.
	endif
	//Se nao achou a especialidade nao precisa validar
else
	lRet	:= .F.
endif

return lRet

/*/{Protheus.doc} PLSTXADM
Retorna o percentual da taxa administrativa
@author PLS TEAM
@since 19/10/2016
@version 1.0
/*/
function PLSTXADM(cTipPre,cCodPad,cCodPro,cCodEsp,nVlrApr,nUsrea,cFinate,cCodRda,cRdaEdi,aDadUsr,dDatAnalise)
local nNiveis		:= 0
local nPrTxPag		:= 0
local cCdProduto	:= iIf(len(aDadUsr) >= 11, aDadUsr[11], "")
local cModPag		:= iIf(len(aDadUsr) >= 48, aDadUsr[48], "")
local cRegGop 		:= iIf(len(aDadUsr) >= 63, aDadUsr[63], "")
local cGruOpe 		:= iIf(len(aDadUsr) >= 64, aDadUsr[64], "")
local aRetFun		:= {}
local aNiveis 		:= {}

//quando for intercambio
if cTipPre == getNewPar("MV_PLSTPIN","OPE")
	
	aNiveis := PLSESPNIV(cCodPad)
	nNiveis := (aNiveis[1]+1)
	
	//pagamento
	// 1 - Pagamento
	// 2 - Recebimento
	aRetFun := PLSGRUOPE("1",BAU->BAU_CODOPE,dDatAnalise,nNiveis,aNiveis,cCodPro,cModPag,cCodPad,cCodEsp,"",;
						 cCdProduto,nVlrApr,"",nil, .t., cFinate, cCodRda, cRdaEdi, nil, nil, .t.)
	
	nPrTxPag := aRetFun[4]
	
//rede de atendimento normal
elseIf BAW->( fieldPos('BAW_TXADMT') ) > 0
	
	BAW->( dbSetOrder(1) ) //BAW_FILIAL+BAW_CODIGO+BAW_CODINT
	
	if BAW->( msSeek( xFilial("BAW") + BAU->BAU_CODIGO + plsIntPad() ) )
		
		while !BAW->( eof() ) .and. BAW->(BAW_FILIAL+BAW_CODIGO+BAW_CODINT) == xFilial("BAW") + BAU->BAU_CODIGO + plsIntPad()
			
			if PLSINTVAL("BAW","BAW_VIGINI","BAW_VIGFIN",dDataBase)
				
				nPrTxPag := BAW->BAW_TXADMT
				
				exit
			endIf
			
		BAW->(dbSkip())
		endDo
		
	endIf
	
endIf
	
return nPrTxPag

/*/{Protheus.doc} PLSPEINPT
Retorna o percentual do inss patronal
@author PLS TEAM
@since 19/10/2016
@version 1.0
/*/
function PLSPEINPT()
local nPerInss := 0
local aAreaSA2 := SA2->(getArea())
local aAreaSED := SED->(getArea())

local lA2_CALCINP := SA2->( fieldPos('A2_CALCINP') ) > 0
local lED_CALCINP := SED->( fieldPos('ED_CALCINP') ) > 0
local lED_PERCINP := SED->( fieldPos('ED_PERCINP') ) > 0

if lA2_CALCINP .and. lED_CALCINP .and. lED_PERCINP .and. !empty( BAU->(BAU_CODSA2 + BAU_LOJSA2) )

	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	if SA2->( msSeek( xFilial('SA2') + BAU->(BAU_CODSA2 + BAU_LOJSA2) ) ) .and. SA2->A2_CALCINP == '1' .and. !empty(SA2->A2_NATUREZ)
	
		SED->(dbSetOrder(1)) //ED_FILIAL+ED_CODIGO
		if SED->( msSeek( xFilial('SED') + SA2->A2_NATUREZ ) ) .and. SED->ED_CALCINP == '1'
			nPerInss :=  SED->ED_PERCINP
		endIf
		
	endIf

endIf

SA2->( restArea(aAreaSA2) )
SED->( restArea(aAreaSED) )

return nPerInss

/*/{Protheus.doc} PLSBAWRD()
Verifica se o tipo da RDA e operadora

@type function
@author PLS TEAM
@since 14.12.2016
@version 1.0
/*/
function PLSBAWRD()
local lRet := BAU->BAU_TIPPRE != getNewPar("MV_PLSTPIN","OPE")
return(lRet)

/*/{Protheus.doc} PlsIntGen
Rotina de interação genérica
@author Fábio Siqueira dos Santos
@since 24/11/2016
@version 1.0
@param 
@return boolean, retorna verdadeiro 
@see para maiores detalhes sobre a auditoria genérica e suas funcionalidades, pesquisar no TDN: http://tdn.totvs.com/pages/viewpage.action?pageId=200913455
/*/
Static Function PlsIntGen(cTpGuia)
Local cAliasIte		:= ""
Local cChaveIte		:= ""
Local aChvInd		:= {}
Local cChave		:= ""
Local nProc			:= 0
Local nFor			:= 0
Local o790C 		:= PLSA790C():New()
Local aCabPro		:= {}
Local aDadPro		:= {}
Local aTrbPro		:= {}
Local cSetor 		:= ""
Local cAltPubl		:= ""
Local cCodOpe 		:= ""
Local nLinhaIni		:= 0
Local nColunaIni	:= 0
Local aDadProc		:= {}
Local oDlg
Local oList
Local cCadastro		:= Space(03)
Local aButtons		:= {}
Local cF3			:= 'BBP'
Local cCampoMot		:= Space(03)
Local nPosTab		:= 0
Local nPosProc		:= 0
Local nPosDesc		:= 0
Local nPosSequen	:= 0
Local lCheck		:= .F.
Local nOpca			:= 0
Local aDadH			:= {}
Local aSize			:= {}
Local cNomOpe		:= ""
Local cAliasPai		:= B53->B53_ALIMOV
Local nCont			:= 0
Local bCol			:= ""

//³Atualiza informacoes da classe
o790C:SetAtuPClass()

cAliasIte := SubStr(B53->B53_ALIITE,1,3)
SIX->(DbSetOrder(1))
SIX->(DbSeek(B53->B53_ALIITE))
cChaveIte := SIX->CHAVE

&(cAliasIte)->( DbSetOrder(Val(SubStr(B53->B53_ALIITE,4,Len(B53->B53_ALIITE)))))
&(cAliasIte)->(DbSeek(xFilial(cAliasIte)+Alltrim(B53->B53_NUMGUI)))

aChvInd  := PLSIndGen(1,.T.,o790C) 

Store Header cAliasIte TO aCabPro For .T.
Store COLS cAliasIte TO aDadPro FROM aCabPro VETTRAB aTrbPro While !&(cAliasIte)->(Eof()) .And. &(cAliasIte)->(&(aChvInd)) == xFilial(cAliasIte)+Alltrim(B53->B53_NUMGUI) 

/*Buscando o Setor e a Permissão para Alterar o Público*/
BX4->(DbSetOrder(1))
cChave := xFilial("BX4") + RETCODUSR() + PLSINTPAD()

If BX4->(DbSeek(cChave))
	cSetor 		:= BX4->BX4_CODDEP
	cAltPubl	:= AllTrim(BX4->BX4_ALTPUB)
	cCodOpe 	:= BX4->BX4_CODOPE
EndIf

aSize := MsAdvSize()

nLinhaIni := aSize[1]  + 005  //005
nColunaIni := aSize[2]  + 005 //035

aSize[3] := aSize[3]
aSize[4] := Round(aSize[4] * 0.92, 0)
aSize[5] := Round(aSize[5] * 0.57/*0.92*/, 0)
aSize[6] := Round(aSize[6] , 0) //* 0.82
aSize[7] := Round(aSize[7] * 0.92, 0)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6]*0.9,aSize[5] of oMainWnd PIXEL

@ nColunaIni, nLinhaIni SAY "Procedimentos" SIZE 100,010 PIXEL OF oDlg //Desc. Espec

nPosAud := Ascan( aCabPro,{ |x| x[2] == cAliasIte+"_AUDITO"} )
nPosSeq := Ascan( aCabPro,{ |x| x[2] == cAliasIte+"_SEQUEN"} )

For nProc := 1 to Len(aDadPro) //Com base na posição do cabeçalho, busca o conteúdo.
	If aDadPro[nProc,nPosAud] == "1" 
		aadd(aDadProc, aDadPro[nProc])
	EndIf
Next nProc

oList := TCBROWSE():New(nColunaIni + 010,nLinhaIni,/*395*/aSize[5]*0.49 ,50 ,,;
	{}, {40,40,40},;
	oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

ADD COLUMN To oList BitMap Data { || LoadBitMap( GetResources(), Iif(!aDadProc[oList:nAt,Len(aDadProc[oList:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 ALIGN CENTERED NOHILITE

For nCont := 1 To Len(aCabPro)
	bCol :=  "{||oList:AddColumn(TcColumn():New(aCabPro["+AllTrim(Str(nCont))+",1],{|| aDadProc[oList:nAt,"+AllTrim(Str(nCont))+"] },+aCabPro["+AllTrim(Str(nCont))+",3],nil,nil,nil,aCabPro["+AllTrim(Str(nCont))+",4],.F.,.F.,nil,nil,nil,.F.,nil) ) }"
	eval( &bCol )
Next

oList:SetArray(aDadProc)

oList:BLDBLCLICK := { || MarcaLinha(oList:nAt,aDadProc,lCheck) , oList:Refresh() }

@ nColunaIni + 70, nLinhaIni SAY "Incluir Interação" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
oPanel  := TPanel():New( nColunaIni + 80, nLinhaIni, "",oDlg, , .F., , , , aSize[5]*0.48, 094, .F., .F. )//*0.49

@ 010, 010 SAY oSay3 PROMPT "Público:" SIZE 025, 007 OF oPanel PIXEL
@ 017, 010 MSCOMBOBOX oParecer VAR cTpPublico ITEMS {"", "Beneficiário", "Prestador" } SIZE 055, 010 OF oPanel;
	WHEN cAltPubl = '1' .and. cTpGuia = 'AD' .AND. Alltrim(FUNNAME()) != "TMKA271"; 
	ON CHANGE IF(!PlVldInt(oList:nAt, aDadProc, cTpPublico, @cParecer, oList),cTpPublico := "",)  PIXEL OF oPanel

@ 010, 070 SAY oSay4 PROMPT "Resposta Prest." SIZE 025, 007 OF oPanel PIXEL
@ 017, 070 MSCOMBOBOX oParecer VAR cParecer ITEMS {"Não","Sim"}  SIZE 030, 010 OF oPanel;
	WHEN /*.T.*/ cTpPublico = "Prestador"  PIXEL OF oPanel

@ 010, 105 SAY oSay5 PROMPT "Motivo Padrão:" SIZE 040, 007 OF oPanel PIXEL
@ 017, 105 MSGET cCampoMot VAR cCadastro F3 cF3 VALID ValMotPad(cCadastro, 'I') SIZE 030,010 PIXEL OF oPanel

@ 017, 135 MSGET cDesMotPad /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE aSize[5]*0.23 /*180*/,010 PIXEL OF oPanel

@ 040,010 SAY "Obs.:" SIZE 100,010 PIXEL OF oPanel //Desc. Espec
@ 047,010 GET cObsMotPad Memo SIZE 200,040 PIXEL OF oPanel

@ nColunaIni + 195, nLinhaIni SAY "Histórico de Interações" SIZE 100,010 PIXEL OF oDlg //Desc. Espec

oListHist := TCBROWSE():New(nColunaIni + 210,nLinhaIni,aSize[5]*0.49 ,50 ,,;
	{},{40,40},;
	oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

oListHist:AddColumn(TcColumn():New('Setor',{ || aDadH[oListHist:nAt, 1] },"@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Data Interação'  ,{ || aDadH[oListHist:nAt, 2] },"@C",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Hora Interação'  ,{ || aDadH[oListHist:nAt, 6] },"@C",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Usuário Interação'  ,{ || aDadH[oListHist:nAt, 7] },"@C",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Mot. Padrão'   ,{ || aDadH[oListHist:nAt, 3] },"@C",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Observação'   ,{ || aDadH[oListHist:nAt, 4] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))

If cTpGuia = 'AD'
	oListHist:BLDBLCLICK := { || If( Len(aDadH) > 0, PLSAVISINT(aDadH[oListHist:nAt, Len(aDadH[oListHist:nAt])], cAltPubl), ) /*, oList:Refresh()*/ } 
EndIf

oList:bChange :=  {|| oListHist:SetArray(FILLITERA(B53->B53_NUMGUI + aDadProc[oList:nAt, nPosSeq], aDadH, cAliasPai, B53->B53_ROTGEN)), oListHist:Refresh()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1, If(CHKSELECT(aDadProc, cDesMotPad, cObsMotPad ),oDlg:End(),nOpca := 2)  /*oDlg:End()*/ ,.F.}, {|| oDlg:End()},.F.,aButtons) Centered

If nOpca == K_OK

	Begin Transaction
		For nFor := 1 To Len(aDadProc)
			If aDadProc[nFor,Len(aDadProc[nFor])]//aDadProc[nFor, 5]

				cSeq := PLSBBRSeq(Nil, Nil, Nil, Nil, Padl(aDadProc[nFor, nPosSeq], 3, "0"), B53->B53_ROTGEN, B53->B53_NUMGUI)
				BBR->(RecLock("BBR",.T.))

				If cTpPublico == "Prestador"
					BBR->BBR_TPDIRP := 'P'
				Else
					If empty(cTpPublico)
						BBR->BBR_TPDIRP := Space(TamSx3("BBR_TPDIRP")[1])
					Else
						BBR->BBR_TPDIRP := 'B'
					EndIf
				EndIf

				//Alteração necessária pois no momento de anexar um arquivo pelo portal
				//do beneficiário, não existe vinculo direto entre o registrocorrente da interação e o procedimento.
				//Desta forma, dificultou muito a alteração do status no momento após anexar um arquivo.
				If cParecer = "Sim" .OR. BBR->BBR_TPDIRP == 'B'
					BBR->BBR_RESPRE := .T.
					
					If BBR->BBR_TPDIRP == 'P'  
						BBR->BBR_ANEXAD := .T.
					EndIf 
				Else
					BBR->BBR_RESPRE := .F.
				EndIf

				BBR->BBR_FILIAL  := xfilial("BBR")
				BBR->BBR_SETOR  := Posicione("SX5",1,xFilial("SX5")+"BL"+cSetor/*BX4->BX4_CODDEP*/,"X5_DESCRI")
				BBR->BBR_CODUSU := cCodOpe
				BBR->BBR_SEQMOP := cCadastro
				BBR->BBR_DTITER := DDATABASE
				BBR->BBR_HRITER := TIME()
				BBR->BBR_NUMGUI	:= B53->B53_NUMGUI
				BBR->BBR_SEQPRO := Padl(aDadProc[nFor, nPosSeq], 3, "0")
				BBR->BBR_CODPRO := cAliasIte + AllTrim(Str(&(cAliasIte)->(Recno())))
				BBR->BBR_TPGUIA := cTpGuia //"04"
				BBR->BBR_OBSERV := cObsMotPad
				BBR->BBR_ALIMOV := cAliasPai
				BBR->BBR_CODOPE := PlsIntPad()//PADL(CVALTOCHAR(aCampos[1][2]), TamSx3(aCampos[1][1])[1],"0")//BE4_CODOPE
				BBR->BBR_ANOAUT := AllTrim(Str(Year(Date())))//PADR(CVALTOCHAR(aCampos[2][2]), TamSx3(aCampos[2][1])[1],) //BE4_ANOINT
				BBR->BBR_MESAUT := AllTrim(Str(Month(Date())))//PADL(CVALTOCHAR(aCampos[3][2]), TamSx3(aCampos[3][1])[1],"0") //BE4_MESINT
				BBR->BBR_NUMAUT := "0000"//PADL(CVALTOCHAR(aCampos[4][2]), TamSx3(aCampos[4][1])[1],"0") //BE4_NUMINT
				BBR->BBR_SEQUEN := cSeq

				BBR->(MsUnLock())

				PLSATUAUD(cTpPublico, cParecer, '',cObsMotPad)

				MsgInfo(STR0085)  //'Interação salva com sucesso.'
			EndIf
		Next nFor
	End Transaction
EndIf

Return .T.

/*/{Protheus.doc} PLSIndGen
O sistema pega a chave do indice informado via parametro e depois, o quebra numa chave, de acordo com o tamanho da B53_NUMGUI
//Se nTpIdx for 1, pega índice da tabela de itens. Se for 2, pega indice da tabela de críticas
@author Fábio Siqueira dos Santos
@since 24/11/2016
@version 1.0
@param 
@return string, retorna chave do índice 

/*/
Static Function PLSIndGen(nTpIdx, lApenIdx, o790C)
Local aIndex		:= IIF(nTpIdx == 1, (o790C:cAIte)->(indexkey(o790C:nIdxIte)) , (o790C:cACri)->(indexkey(o790C:nIdxCri)) )
Local cCampos		:= ""
Local nTamFor		:= Len(Alltrim(B53->B53_NUMGUI))
Local nTamCmp		:= 0
Local nI			:= 0
Local nSoma		:= 0
Local cCmpIdx		:= ""
Default lApenIdx	:= .F.

aIndex := Separa(aIndex,"+",.F.) //Separa os campos, formando vários arrays

//Agora, de acordo com o tamanho do campo B53_NUMGUI, foi vendo que partes dos índices formam a chave
//de pesquisa. Quando for maior ou igual ao tamanho do B53_NUMGUI, o processo é interrompido.
For nI := 1 TO nTamFor
  nSoma += (TamSX3(aIndex[nI])[1])
  cCampos += aIndex[nI] + "-" + Alltrim(Str(TamSX3(aIndex[nI])[1])) + ","
  cCmpIdx += aIndex[nI] + "+"
  If (nSoma >= nTamFor)
    Exit
  EndIf
Next  

If (lApenIdx)  //Quando preciso apenas da chave da forma natural, tipo bbb_filia+bbb_codope
  cCampos := cCmpIdx
EndIf
  
Return (SubStr(cCampos,1,Len(cCampos)-1))

/*/{Protheus.doc} PLATBD7SE2
*******************************************************************
REMOVER NO FUTURO DESTE FONTE
Funcao nao esta mais sendo utilizada foi transferida para PLSCTBFUN
*******************************************************************
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
function PLATBD7SE2(aDadPLS, cChaveSE2)
local aArea		 := getArea()
local lBD7_CHKSE2:= BD7->(fieldPos("BD7_CHKSE2")) > 0
local nI		 := 0
local cSql		 := ''

default cChaveSE2:= ''

if lBD7_CHKSE2 .and. len(aDadPLS) > 0
	
	SC7->(dbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	
	begin transaction
	
	for nI := 1 to len(aDadPLS) 
	
		if SC7->( msSeek( xFilial('SC7') + aDadPLS[nI,1] + aDadPLS[nI,2] ) )

			cSql   := " UPDATE " + retSQLName("BD7")  
			cSql   += "    SET BD7_CHKSE2 = '" + cChaveSE2 + "' " 
			cSql   += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
			cSql   += "    AND BD7_OPELOT = '" + SC7->C7_PLOPELT + "' "
			cSql   += "    AND BD7_NUMLOT = '" + SC7->C7_LOTPLS  + "' "
			cSql   += "    AND BD7_CODRDA = '" + SC7->C7_CODRDA  + "' "
			cSql   += "    AND D_E_L_E_T_ = ' ' "
			
			if ( tcSqlExec(cSql) ) < 0

				FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01',"Erro na execução do update PLATBD7SE2 -> [ " + tcSqlERROR() + "]" , 0, 0, {})
				
			elseIf allTrim( TCGetDB() ) == "ORACLE"

				TCSQLExec("COMMIT")
					
			endif
				
		endIf
		
	next
		
	end transaction
	
endif

restArea(aArea)

return

/*/{Protheus.doc} setCTRVAr
Variavel static conforme funcao
@type function
@author TOTVS
@since 28.08.01
@version 1.0
/*/
function setCTRVAr(cTp)
__PLSA498GUI := .f.

if cTp == "PLSA498GUI"
	__PLSA498GUI := .t.
endIf	
	
return

/*/{Protheus.doc} PlsStatGui
Retorna a descrição de status da guia
@type function
@author TOTVS
@since 28.08.01
@version 1.0
/*/
Function PlsStatGui(cStatus, cCabec)
Local cDesc		:= ''	// Descrição do Status da Guia
						// BEA - 1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada;4=Aguardando finalizacao atendimento;5=Aguardando Liq. Titulo a Receber
						// B0D - 1-Autorizado - 2-Não Autorizado
						// B4A - 1=Autorizada;2=Autorizada Parcialmente;3=Nao Autorizada
Default cStatus	:= '1'	// Conteúdo do campo _STATUS da guia
Default cCabec	:= ''	// Cabeçalho da tabela da guia

Do Case

	Case cCabec == "BEA" .or. cCabec == "B4Q"
		
		Do Case
			Case cStatus == '1'
				cDesc	:= 'Autorizado'
			Case cStatus == '2'
				cDesc	:= 'Autorizado Parcialmente'
			Case cStatus == '3'
				cDesc	:= 'Negado'
			Case cStatus == '4'
				cDesc	:= 'Em Análise'// 'Aguardando Finalizacao Atendimento'
			Case cStatus == '5'
				cDesc	:= 'Em Análise'//'Aguardando Liq. Titulo a Receber'
			Case cStatus == '6'
				cDesc	:= 'Em Análise'//'Em analise pela auditoria'				
			OtherWise
				cDesc	:= 'Status nao Definido'
		EndCase
		
	Case cCabec == "B0D"
	
		Do Case
			Case cStatus == '1'
				cDesc	:= 'Autorizado'
			Case cStatus == '2'
				cDesc	:= 'Negado'
			OtherWise
				cDesc	:= 'Status nao Definido'
		EndCase

	Case cCabec == "B4A"
	
		Do Case
			Case cStatus == '1'
				cDesc	:= 'Autorizado'
			Case cStatus == '2'
				cDesc	:= 'Autorizado Parcialmente'
			Case cStatus == '3'
				cDesc	:= 'Negado'
			Case cStatus == '6'
				cDesc	:= 'Em Análise'				
			OtherWise
				cDesc	:= 'Status nao Definido'
		EndCase

	OtherWise
	
		cDesc := 'Cabeçalho Não Informado'
		
EndCase

Return(cDesc)


/*/{Protheus.doc} plChkHECO
ajusta aheader e acols conforme aliasChange
@type function
@author TOTVS
@since 28.08.17
@version 1.0
/*/
function plChkHECO(cAlias,cAliasChange,aHeaderAux,aColsAux)
local aArea		 := getArea()
local nFor		 := 0
local nForH		 := 0
local cExcHeader := ""
local cMat		 := ""
local aAux 		 := aClone(aHeaderAux)
local aAuxNew	 := {}
local aAuxCol  	 := {}
local aColsNew 	 := {}

dbSelectArea(cAliasChange)

for nFor := 1 to len(aAux)
	
	cMat := "{|| AaDd(aAuxNew,{"
	
	aAux[nFor,2] := strTran(aAux[nFor,2],cAlias,cAliasChange)
	
	if type(aAux[nFor,2]) <> 'U'
	
		for nForH := 1 to len(aAux[nFor])
		
			cMat += 'aAux[' + allTrim( str(nFor) ) + ',' + allTrim( str(nForH) ) + '],'
			
		next
		
		cMat := subStr(cMat,1,len(cMat)-1) + '}) } '
		
		eval(&cMat)
		
	else
		cExcHeader += '(' + allTrim( str(nFor) ) + ')'
	endIf
	
next

if len(aAuxNew) > 0
	aHeaderAux := aClone(aAuxNew)
endIf

if ! empty(cExcHeader)

	aAuxCol  := aClone(aColsAux)

	for nFor := 1 to len(aAuxCol)

		cMat := '{|| AaDd(aColsNew, {'

		for nForH := 1 to len(aAuxCol[nFor])

			if ! '(' + allTrim( str(nForH)) + ')' $ cExcHeader
			
				cMat += 'aAuxCol[' + allTrim( str(nFor) ) + ',' + allTrim( str(nForH) ) + '],'
				
			endIf

		next

		cMat := subStr(cMat,1,len(cMat)-1) + '}) }'
		
		eval(&cMat)
		
	next

	if len(aColsNew) > 0
		aColsAux := aClone(aColsNew)
	endIf
	
endIf

restArea(aArea)

return	

/*/{Protheus.doc} PLBYEPU
Se o evento ja foi autorizado nao checa regra novamente

@type 		function
@author  	PLS TEAM
@version 	P12
@since		18.10.16
/*/
function PLBYEPU(cTipoGuia, cChavLib, aProcByp, cCodPad, cCodPro, cCodDente, cCodFace, lOutDesp, cChavGuia)
local nPos			:= 0
local cOpeMov		:= ""
local cAnoMov		:= ""
local cMesMov		:= ""
local cNumMov		:= ""
local cNivAut		:= ""
local cChvNiv		:= ""
local cSql			:= ""
local oBHMPRE_AUT 	:= PLRetHash(1)
local lRet			:= PLGetHash(cChavLib,@aProcByp,oBHMPRE_AUT)
local objBoRes 	:= nil
local aChavLib := {}

default cCodPad		:= ""
default cCodPro		:= ""
default cCodDente	:= ""
default cCodFace	:= ""
default lOutDesp	:= .f.
default cChavGuia	:= ""

//Aqui, quando é proveniente das Outras Despesas na GRI, necessitamos trocar o código pela solicitação da internação, para encontrar anexos
if lOutDesp .and. cTipoGuia $ G_RES_INTER  
	BE4->(dbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
	if ( BE4->(msSeek( xFilial("BE4") + cChavLib )) )
		objBoRes := BO_ResumoInter():New()   
		aChavLib := strtoArray(objBoRes:getNumInt(BE4->BE4_GUIINT, '1'), "|")
		cChavLib := aChavLib[1]
		cOpeMov  := Left(cChavLib,4)
		cAnoMov  := SubStr(cChavLib,5,4)
		cMesMov  := SubStr(cChavLib,9,2)
		cNumMov  := Right(cChavLib,8)
	endif

else	                                                                                                        

	if cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON .and. BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) != cChavLib
	
		BEA->(dbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+dtos(BEA_DATPRO)+BEA_HORPRO
		if ! BEA->( msSeek( xFilial("BEA") + cChavLib ) )
			lRet := .t.	
		endIf
		
	elseIf cTipoGuia $ G_HONORARIO + "|" + G_RES_INTER .and. BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) != cChavLib	
		
		BEA->(dbSetOrder(6)) //BEA_FILIAL+BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT+DTOS(BEA_DATPRO)+BEA_HORPRO
		if ! BEA->( msSeek( xFilial("BEA") + cChavLib ) )
			lRet := .t.	
		endIf
		
	endIf
	
endif	



//Quando tenho dois procedimentos, um aprovado e outro EM analise, não fecho a 090 e audito o procedimento aprovando, ao voltar na 090 é apresentado erro de auditoria. 
//Aqui forçamos para que, caso não encontre o procedimento no array, recarregue o mesmo com todos os autorizados.

if !empty(cCodPad) .and. ! empty(cCodPro)
	nPos := aScan(aProcByp,{|x| allTrim(x[1]) + allTrim(x[2]) == allTrim(cCodPad) + allTrim(cCodPro) .and. allTrim(x[9]) + allTrim(x[10]) == allTrim(cCodDente) + allTrim(cCodFace) }) 
	lRet := ( nPos  > 0 )
endif
	
if ! lRet

	//Definicao dos Alias e da chave de busca da liberacao
	if (!lOutDesp)
		do case	 
	
			case cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON
				
				cChavLib := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
				cOpeMov  := BEA->BEA_OPEMOV
				cAnoMov  := BEA->BEA_ANOAUT
				cMesMov  := BEA->BEA_MESAUT 
				cNumMov	 := BEA->BEA_NUMAUT
				
			case cTipoGuia $ G_HONORARIO + "|" + G_RES_INTER
				
				cChavLib := BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
				cOpeMov  := BEA->BEA_OPEINT
				cAnoMov  := BEA->BEA_ANOINT
				cMesMov  := BEA->BEA_MESINT 
				cNumMov	 := BEA->BEA_NUMINT
			
		endCase
	endif
	
	
	if ! empty(cChavLib)
	
		cSql := " SELECT BE2_CODPAD CODPAD, BE2_CODPRO CODPRO, BE2_QTDPRO QTDPRO, BE2_TIPGUI TIPGUI, BE2_OPEMOV CODOPE,"
		cSql += "        BE2_DATPRO DATPRO, BE2_NIVAUT NIVAUT, BE2_CHVNIV CHVNIV, BE2_DENREG DENREG, BE2_FADENT FADENT "
		cSql += "   FROM " + BE2->(retSqlName('BE2')) + " BE2 "
		cSql += "  WHERE BE2_FILIAL = '" + xFilial('BE2') + "' "
		cSql += "    AND BE2_OPEMOV = '" + cOpeMov + "' "
		
		if cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON
			cSql += " AND BE2_ANOAUT = '" + cAnoMov + "' "
			cSql += " AND BE2_MESAUT = '" + cMesMov + "' "
			cSql += " AND BE2_NUMAUT = '" + cNumMov + "' "
			cSql += " AND BE2_LIBERA = '1' "
		else
			cSql += " AND BE2_ANOINT = '" + cAnoMov + "' "
			cSql += " AND BE2_MESINT = '" + cMesMov + "' "
			cSql += " AND BE2_NUMINT = '" + cNumMov + "' "
		endIf
		
		cSql += "    AND BE2_STATUS = '1' "
		cSql += "    AND BE2.D_E_L_E_T_ = ' ' "
			
		cSql += "   UNION ALL "
			
		cSql += " SELECT B4C_CODPAD CODPAD, B4C_CODPRO CODPRO, B4C_QTDPRO QTDPRO, B4A_TIPGUI TIPGUI, B4A_OPEMOV CODOPE,"
		cSql += "        B4A_DATPRO DATPRO, B4C_NIVAUT NIVAUT, B4C_CHVNIV CHVNIV, '' DENREG, '' FADENT "
		cSql += "   FROM " + B4A->(retSqlName('B4A')) + " B4A "
		
		cSql += " INNER JOIN " + B4C->(retSqlName('B4C')) + " B4C "
		cSql += "         ON B4C_FILIAL = '" + xFilial('B4C') + "' " 
		cSql += "        AND B4C_OPEMOV = B4A_OPEMOV "
		cSql += "        AND B4C_ANOAUT = B4A_ANOAUT "
		cSql += "        AND B4C_MESAUT = B4A_MESAUT "
		cSql += "        AND B4C_NUMAUT = B4A_NUMAUT "
		cSql += "        AND B4C_STATUS = '1' "
		cSql += "        AND B4C.D_E_L_E_T_ = ' ' "
		
		cSql += "  WHERE B4A_FILIAL = '" + xFilial('B4A') + "' "
		cSql += "    AND B4A_GUIREF = '" + cChavLib + "' "
		if (!empty(cChavGuia))
			cSql += " OR B4A_GUIREF = '" + cChavGuia + "' "	
		endif	
		cSql += "    AND B4A.D_E_L_E_T_ = ' ' "
		
		//prorrogacao
		if cTipoGuia $ G_RES_INTER + '|' + G_HONORARIO
			
			cSql += " UNION ALL "
				
			cSql += " SELECT BQV_CODPAD CODPAD, BQV_CODPRO CODPRO, BQV_QTDPRO QTDPRO, '11' TIPGUI, B4Q_OPEMOV CODOPE,"
			cSql += "        B4Q_DATPRO DATPRO, BQV_NIVAUT NIVAUT, BQV_CHVNIV CHVNIV, '' DENREG, '' FADENT "
			cSql += "   FROM " + B4Q->(retSqlName('B4Q')) + " B4Q "
			
			cSql += " INNER JOIN " + BQV->(retSqlName('BQV')) + " BQV "
			cSql += "         ON BQV_FILIAL = '" + xFilial('BQV') + "' " 
			cSql += "        AND BQV_CODOPE = B4Q_OPEMOV "
			cSql += "        AND BQV_ANOINT = B4Q_ANOAUT "
			cSql += "        AND BQV_MESINT = B4Q_MESAUT "
			cSql += "        AND BQV_NUMINT = B4Q_NUMAUT "
			cSql += "        AND BQV_STATUS = '1' "
			cSql += "        AND BQV.D_E_L_E_T_ = ' ' "
			
			cSql += " WHERE B4Q_FILIAL = '" + xFilial('B4Q') + "' "
			cSql += "   AND B4Q_GUIREF = '" + cChavLib + "' "
			cSql += "   AND B4Q.D_E_L_E_T_ = ' ' "
			
			cSql += "   UNION ALL "
			
			cSql += " SELECT B4C_CODPAD CODPAD, B4C_CODPRO CODPRO, B4C_QTDPRO QTDPRO, B4A_TIPGUI TIPGUI, B4A_OPEMOV CODOPE,"
			cSql += "        B4A_DATPRO DATPRO, B4C_NIVAUT NIVAUT, B4C_CHVNIV CHVNIV, '' DENREG, '' FADENT "
			cSql += "   FROM " + B4A->(retSqlName('B4A')) + " B4APRO "
			
			cSql += " INNER JOIN " + B4C->(retSqlName('B4C')) + " B4CPRO "
			cSql += "         ON B4CPRO.B4C_FILIAL = '" + xFilial('B4C') + "' " 
			cSql += "        AND B4CPRO.B4C_OPEMOV = B4APRO.B4A_OPEMOV "
			cSql += "        AND B4CPRO.B4C_ANOAUT = B4APRO.B4A_ANOAUT "
			cSql += "        AND B4CPRO.B4C_MESAUT = B4APRO.B4A_MESAUT "
			cSql += "        AND B4CPRO.B4C_NUMAUT = B4APRO.B4A_NUMAUT "
			cSql += "        AND B4CPRO.B4C_STATUS = '1' "
			cSql += "        AND B4CPRO.D_E_L_E_T_ = ' ' "
			
			cSql += " WHERE B4APRO.B4A_FILIAL = '" + xFilial('B4A') + "' "
			cSql += "   AND B4APRO.B4A_GUIREF = '" + cChavLib + "' "
			cSql += "   AND B4APRO.D_E_L_E_T_ = ' ' "
			
		endIf	
//changeQuery(cSql)
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TRBPAS",.f.,.t.)
		
		while ! TRBPAS->(eof()) 
							
			aadd(aProcByp, { TRBPAS->CODPAD, TRBPAS->CODPRO, TRBPAS->QTDPRO, TRBPAS->TIPGUI, TRBPAS->CODOPE, stod(TRBPAS->DATPRO), TRBPAS->NIVAUT, TRBPAS->CHVNIV, TRBPAS->DENREG, TRBPAS->FADENT } )
			
		TRBPAS->(dbSkip())
		endDo
		
		TRBPAS->(dbCloseArea())
		
		PLSetHash(cChavLib,aProcByp,@oBHMPRE_AUT)
		
	endIf
	
endIf

if ! empty(cCodPad) .and. ! empty(cCodPro)

	nPos := aScan(aProcByp,{|x| allTrim(x[1]) + allTrim(x[2]) == allTrim(cCodPad) + allTrim(cCodPro) .and. allTrim(x[9]) + allTrim(x[10]) == allTrim(cCodDente) + allTrim(cCodFace) }) 
	lRet := ( nPos  > 0 )
	
	if lRet
		cNivAut := aProcByp[nPos,7]
		cChvNiv := aProcByp[nPos,8]
	endIf
		 
endIf	
	
return( { lRet, cNivAut, cChvNiv } )


/*/{Protheus.doc} PLRDESBOX
retorna a descricao de um xbox
@type 		function
@author  	PLS TEAM
@since		18.10.16
/*/
function PLRDESBOX(aMat,cField,cConteudo)
local nPos		:= 0
local cDescri 	:= ""

if len(aMat) == 0
	aMat := retSx3Box( X3CBox( posicione('SX3',2,cField,'X3_CBOX') ),,,1 )
endIf
	
nPos := aScan(aMat, {|x| x[2] == cConteudo })
if nPos > 0
	cDescri := aMat[nPos,3]
endIf

return(cDescri)

/*/{Protheus.doc} PLGetDec
retorna a decimal do campo
@type function
@author PLSTEAM
@since 03.01.17
@version 1.0
/*/
function PLGetDec(cField)
return getSx3Cache(cField, 'X3_DECIMAL')

/*/{Protheus.doc} PlRetSX5
retorna a descrição do SX5
@type function
@author Lucas
@since 20.03.18
@version 1.0
/*/
function PlRetSX5(cTab,cChave)
local aRet	:= {}
local nPos	:= 0
local cDesc	:= ""

aRet := FWGetSX5(cTab)
nPos := aScan(aRet,{|x| AllTrim(x[3]) == AllTrim(UPPER(cChave))}) 
if nPos > 0
	cDesc := aRet[nPos][4]
endif

return cDesc

Function P090MTVCAN()
Local aArea := GetArea()
Local cMotTiss 	:= Space(15)
Local cTexto 	:= Space(TamSx3("BEA_CANEDI")[1])
Local nOk		:= 0
Private cCodTab	:= "38"

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DbSelectArea("BTP")
BTP->(DbSetOrder(2))

DEFINE MSDIALOG oDlgMot TITLE STR0080 From 120, 000 To 250 , 550 Of oMainWnd Pixel   //"Informe o motivo do cancelamento"

@ 010, 010 Say STR0081 Of oDlgMot Pixel COLOR CLR_BLUE    // "Motivo TISS"
@ 020, 010 MsGet oProd VAR cMotTiss Size 40, 009 VALID PLVLDMOT(cMotTiss,@cTexto) F3 "BTQPLS" OF oDlgMot Pixel COLOR CLR_BLACK

@ 010, 055 Say STR0082  Of oDlgMot Pixel COLOR CLR_BLUE    // "Descrição motivo"
@ 020, 055 MsGet oDes VAR cTexto  Size 205, 009 OF oDlgMot Pixel COLOR CLR_BLACK


oBtnOk := tButton():New(@37, 115, STR0083, oDlgMot, {|| nOk := 1, Iif(!Empty(cMotTiss) .OR. !Empty(cTexto),oDlgMot:End(),Nil)}, 050, 012,,,, .T.)    //"Confirma"

ACTIVATE MSDIALOG oDlgMot CENTERED

If nOk <> 1
	cMotTiss := ""
	cTexto := ""
EndIf

RestArea(aArea)
Return({cMotTiss,cTexto})

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDMOT

Valido o motivo digitado

@author  	PLS TEAM
@version 	P11.8
@since		02/16
/*/
//-------------------------------------------------------------------
Static Function PLVLDMOT(cMotivo, cTexto)
Local lRet := .F.

BTQ->(DbSetOrder(1))
lRet := BTQ->(MsSeek(xFilial("BTQ") + "38" + cMotivo))
cTexto := BTQ->BTQ_DESTER

Return(lRet)

/*/{Protheus.doc} PLSGETRAS
Retorna beneficiários com o código de rastreio de reembolso
@author Thiago Ribas
@since 21/03/2012
/*/
Function PLSGETRAS(cCodRdas, cDtRecibo) 

LOCAL cSqlRas := ""
DEFAULT cDtRecibo := ""

cSqlRas := " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,BA1_NOMUSR, BA3_CODPLA, BA1_DATINC, BA1_DATBLO"
cSqlRas += " FROM " + RetSqlName("BA1")
cSqlRas += " INNER JOIN " + RetSqlName("BA3")
cSqlRas += " ON BA3_CODINT = BA1_CODINT AND BA3_CODEMP = BA1_CODEMP AND BA3_MATRIC = BA1_MATRIC"
cSqlRas += " WHERE"
cSqlRas += " BA3_CODRAS = '" + cCodRdas + "' AND  BA3_DATBLO >= '" + cDtRecibo + "' AND "

If !Empty(cDtRecibo)
	cSqlRas += " BA1_DATINC <= '" + cDtRecibo + "' AND "
EndIf

cSqlRas += RetSqlName("BA3")+".D_E_L_E_T_ = ' ' AND " + RetSqlName("BA1")+".D_E_L_E_T_ = ' '"
cSqlRas += " ORDER BY BA3_CODPLA"

Return cSqlRas


/*/{Protheus.doc} PLHATVLDP
Verifica se encontra na tabela B2Z a liberação, quando o parâmetro MV_PLSHAT estiver ativo, indicando que a Operadora usa o HAT.
@type function
@author PLSTEAM
@since 12/2018
@version 1.0
/*/
function PLHATVLDP(cTipGuia, cOpeMov, cCodRDA, cSenha, cNumAut, cMatric, cCdTbPd, cCodPro, lAtuSld, nSldPrev, nQtdAtuz)
local aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
local aAreaB2Z	:= B2Z->(getarea())
local cSql			:= ""
local cNivAut 	:= ""
local cChvNiv 	:= ""
local cPadBkp		:= ""
local cCodPad		:= ""
local lRet			:= .f.
local nQtd			:= 0
local nI			:= 1
local nPosB2Z		:= 0
local nTemp		:= 0
default lAtuSld	:= .f.
default nQtdAtuz	:= 0

//Fazer o De/para do código da tabela e procedimento. HAT grava conforme terminologia TISS....
if( !empty(cCdTbPd) .and. !empty(cCodPro) )
	cPadBkp := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCdTbPd)
	cCodPro := PLSGETVINC("BTU_CDTERM", "BR8", .F., cPadBkp,  Alltrim(cCdTbPd + cCodPro), .F. ,aTabDup, @cPadBkp)
endif	

cSql := " SELECT B2Z_QTDAUT, B2Z_SALDO " + iif(lAtuSld, ", R_E_C_N_O_ REC", "") 
cSql += " FROM  " + RetSqlname("B2Z")
cSql += " WHERE B2Z_FILIAL = '" + xFilial("B2Z") + "' "
cSql += " AND B2Z_OPEMOV = '" + cOpeMov + "' "
//cSql += " AND B2Z_CODRDA = '" + cCodRDA + "' "
if ( !empty(cSenha) )
	cSql += " AND B2Z_SENHA = '" + cSenha + "' "
else
	cSql += " AND B2Z_NUMAUT = '" + cNumAut + "' "
endif
cSql += " AND B2Z_MATRIC = '" + cMatric + "' "
if ( !empty(cCdTbPd) .and. !empty(cCodPro) )
	cSql += " AND B2Z_CODPAD = '" + cPadBkp + "' "
	cSql += " AND B2Z_CODPRO = '" + cCodPro + "' "
endif
cSql += " AND D_E_L_E_T_ = ' ' "

//Chamo Função de Query
cSql:= ChangeQuery(cSql)
TcQuery cSql New Alias "TabProcB2Z"

if !TabProcB2Z->(eof())
	lRet := .t.
	cNivAut := "HAT"
	cChvNiv := "HATAUT"	
	nQtd += TabProcB2Z->B2Z_SALDO
	iif(lAtuSld, nPosB2Z := TabProcB2Z->REC, "")  
endif

if lAtuSld .and. nPosB2Z > 0 
	B2Z->(dbgoto(nPosB2Z))
	B2Z->(reclock("B2Z", .f.))
		if nQtdAtuz == 0
			nQtd -= nSldPrev
			B2Z->B2Z_SALDO := nQtd
		else
			nTemp := B2Z->B2Z_SALDO + nQtdAtuz
			B2Z->B2Z_SALDO := nTemp
		endif						
	B2Z->( msunLock() )									
endif

TabProcB2Z->(dbclosearea())

RestArea(aAreaB2Z)
return	({lRet, cNivAut, cChvNiv, nQtd})


//Função genérica para inclusão da pesquisa de SE2 em queries que necessitem da busca.
function keybreak(cCmpChave)
Local cSubs		 := ""
Local cTypDB	 := UPPER(TcGetDB())
Local cSubStr	 := iif( 'MSSQL' $ cTypDB, 'SUBSTRING(','SUBSTR(')
Local nTamE2_FIL := TamSX3("E2_FILIAL") [1]
Local nTamE2_PRE := TamSX3("E2_PREFIXO")[1]
Local nTamE2_NUM := TamSX3("E2_NUM")	[1]
Local nTamE2_PAR := TamSX3("E2_PARCELA")[1]
Local nTamE2_TIP := TamSX3("E2_TIPO")   [1]
Local nTamE2_FOR := TamSX3("E2_FORNECE")[1]
Local nTamE2_LOJ := TamSX3("E2_LOJA")   [1]

cSubs += " E2_FILIAL      = " + cSubStr + cCmpChave + ",1," + alltrim( str( nTamE2_FIL ) ) + " ) "
cSubs += " AND E2_PREFIXO = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + 2) ) + ", " + alltrim(str(nTamE2_PRE ) ) + " ) "
cSubs += " AND E2_NUM     = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + nTamE2_PRE + 3) ) + ", " +  alltrim(str(nTamE2_NUM ) ) + " ) "
cSubs += " AND E2_PARCELA = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + nTamE2_PRE + nTamE2_NUM + 4) ) + ", " +  alltrim(str(nTamE2_PAR ) ) + " ) "
cSubs += " AND E2_TIPO    = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + nTamE2_PRE + nTamE2_NUM + nTamE2_PAR + 5) ) + ", " +  alltrim(str(nTamE2_TIP ) ) + " ) "
cSubs += " AND E2_FORNECE = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + nTamE2_PRE + nTamE2_NUM + nTamE2_PAR + nTamE2_TIP + 6) ) + ", " +  alltrim(str(nTamE2_FOR) )  + " ) "
cSubs += " AND E2_LOJA    = " + cSubStr + cCmpChave + ", "  + alltrim( str( nTamE2_FIL + nTamE2_PRE + nTamE2_NUM + nTamE2_PAR + nTamE2_TIP + nTamE2_FOR + 7) ) + ", " +  alltrim(str(nTamE2_LOJ ) ) + " ) "

return cSubs

/*/{Protheus.doc} PLSRETRAS
Retorna o código das famílias que possuem código de rastreio
/*/
Function PLSRETRAS(cCodRdas)  

LOCAL   cSqlRas    := ""
LOCAL   cRetMatric := ""

DEFAULT cCodRdas   := ""

cSqlRas := " SELECT BA3_CODINT, BA3_CODEMP, BA3_MATRIC"
cSqlRas += " FROM " + RetSqlName("BA3")
cSqlRas += " WHERE"
cSqlRas += " BA3_CODRAS = '" + cCodRdas + "' AND "
cSqlRas += RetSqlName("BA3")+".D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSqlRas),"TRBRAS",.F.,.T.)
	
While !TRBRAS->(EOF())

	cRetMatric += "'" + TRBRAS->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC) + "',"
	
	TRBRAS->(DbSkip())
EndDo

//retira a ultima virgula
If !EMPTY(cRetMatric)
	cRetMatric := substr(cRetMatric, 1, LEN(cRetMatric) - 1)
EndIf

TRBRAS->(DbCloseArea())

Return cRetMatric
