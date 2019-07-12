#Include 'Protheus.ch'

CLASS FunctionsTestCase FROM FWDefaultTestCase
	
	METHOD FunctionsTestCase()
	METHOD SetUpClass()
	METHOD TearDownClass()

    METHOD PLSRETTIT()
    METHOD PLSGRAVERR()
    METHOD PLSINTVLD()
    METHOD PLSVLDINT()
    METHOD PLSNAODISP()
    METHOD PLSISAUTO()
    METHOD PLSOBRIGAT()
    METHOD PLSINTAUT()
    METHOD PLSINTPAD()
    METHOD PLSRTMASPR()
    METHOD PLSSINC()
    METHOD PLSDIGI()
    METHOD PLSZERO()
    METHOD PLSIGUALA()
    METHOD PLSXUSRBLO()
    METHOD PLSRETGLO()
    METHOD PLSCHKCRI()
    METHOD PCLPGAUTO()
    METHOD PCLPOSGLO()
    METHOD PLSPOSGLO()
    METHOD PLSBCTDESC()
    METHOD PLSCODSUP()
    METHOD PLSVLDSUP()
    METHOD PLSPROAM()
    METHOD PLSSXBSRA()
    METHOD PLFINDSRA()
    METHOD PLFILFIL()
    METHOD PLSENDMAIL()
    METHOD PLGERAMAIL()
    METHOD PLLEGRPMAIL()
    METHOD PLRELRDA()
    METHOD PLRELCOS()
    METHOD PLRELBEN()
    METHOD PLPROFSAUD()
    METHOD PROFALL()
    METHOD PLVLDREQ()
    METHOD PLVLDUSRW()
    METHOD PLSVLTNT()
    METHOD PLVLDSDT()
    METHOD PLVLDUSRP()
    METHOD PLIMPWEB()
    METHOD PLSUSRBKP()
    METHOD CONVDAD()
    METHOD PLSHISGRV()
    METHOD PLSHISDEL()
    METHOD PLSHISCON()
    METHOD PLVLDPFS()
    METHOD PLVLDPRE()
    METHOD PLSATUSS()
    METHOD PLSATUCS()
    METHOD PLIDSALD()
    METHOD PLSSOLV()
    METHOD PLSTRBDIOP()
    METHOD MASKDIOPS()
    METHOD PLGRVLOG()
    METHOD PLGRVLGB()
    METHOD PLRDATP()
    METHOD PLSCARBD6()
    METHOD PLSXBKC()
    METHOD PLSNEGCOM()
    METHOD PLSSELOPT()
ENDCLASS

METHOD FunctionsTestCase() CLASS FunctionsTestCase
	_Super:FWDefaultTestCase()

    self:AddTestMethod( 'PLSRETTIT',,'Teste da funcao PLSRETTIT.' ) 
    self:AddTestMethod( 'PLSGRAVERR',,'Teste da funcao PLSGRAVERR.' ) 
    self:AddTestMethod( 'PLSINTVLD',,'Teste da funcao PLSINTVLD.' ) 
    self:AddTestMethod( 'PLSVLDINT',,'Teste da funcao PLSVLDINT.' ) 
    self:AddTestMethod( 'PLSNAODISP',,'Teste da funcao PLSNAODISP.' ) 
    self:AddTestMethod( 'PLSISAUTO',,'Teste da funcao PLSISAUTO.' ) 
    self:AddTestMethod( 'PLSOBRIGAT',,'Teste da funcao PLSOBRIGAT.' ) 
    self:AddTestMethod( 'PLSINTAUT',,'Teste da funcao PLSINTAUT.' ) 
    self:AddTestMethod( 'PLSINTPAD',,'Teste da funcao PLSINTPAD.' ) 
    self:AddTestMethod( 'PLSRTMASPR',,'Teste da funcao PLSRTMASPR.' ) 
    self:AddTestMethod( 'PLSSINC',,'Teste da funcao PLSSINC.' ) 
    self:AddTestMethod( 'PLSDIGI',,'Teste da funcao PLSDIGI.' ) 
    self:AddTestMethod( 'PLSZERO',,'Teste da funcao PLSZERO.' ) 
    self:AddTestMethod( 'PLSIGUALA',,'Teste da funcao PLSIGUALA.' ) 
    self:AddTestMethod( 'PLSXUSRBLO',,'Teste da funcao PLSXUSRBLO.' ) 
    self:AddTestMethod( 'PLSRETGLO',,'Teste da funcao PLSRETGLO.' ) 
    self:AddTestMethod( 'PLSCHKCRI',,'Teste da funcao PLSCHKCRI.' ) 
    self:AddTestMethod( 'PCLPGAUTO',,'Teste da funcao PCLPGAUTO.' ) 
    self:AddTestMethod( 'PCLPOSGLO',,'Teste da funcao PCLPOSGLO.' ) 
    self:AddTestMethod( 'PLSPOSGLO',,'Teste da funcao PLSPOSGLO.' ) 
    self:AddTestMethod( 'PLSBCTDESC',,'Teste da funcao PLSBCTDESC.' ) 
    self:AddTestMethod( 'PLSCODSUP',,'Teste da funcao PLSCODSUP.' ) 
    self:AddTestMethod( 'PLSVLDSUP',,'Teste da funcao PLSVLDSUP.' ) 
    self:AddTestMethod( 'PLSPROAM',,'Teste da funcao PLSPROAM.' ) 
    self:AddTestMethod( 'PLSSXBSRA',,'Teste da funcao PLSSXBSRA.' ) 
    self:AddTestMethod( 'PLFINDSRA',,'Teste da funcao PLFINDSRA.' ) 
    self:AddTestMethod( 'PLFILFIL',,'Teste da funcao PLFILFIL.' ) 
    self:AddTestMethod( 'PLSENDMAIL',,'Teste da funcao PLSENDMAIL.' ) 
    self:AddTestMethod( 'PLGERAMAIL',,'Teste da funcao PLGERAMAIL.' ) 
    self:AddTestMethod( 'PLLEGRPMAIL',,'Teste da funcao PLLEGRPMAIL.' ) 
    self:AddTestMethod( 'PLRELRDA',,'Teste da funcao PLRELRDA.' ) 
    self:AddTestMethod( 'PLRELCOS',,'Teste da funcao PLRELCOS.' ) 
    self:AddTestMethod( 'PLRELBEN',,'Teste da funcao PLRELBEN.' ) 
    self:AddTestMethod( 'PLPROFSAUD',,'Teste da funcao PLPROFSAUD.' ) 
    self:AddTestMethod( 'PROFALL',,'Teste da funcao PROFALL.' ) 
    self:AddTestMethod( 'PLVLDREQ',,'Teste da funcao PLVLDREQ.' ) 
    self:AddTestMethod( 'PLVLDUSRW',,'Teste da funcao PLVLDUSRW.' ) 
    self:AddTestMethod( 'PLSVLTNT',,'Teste da funcao PLSVLTNT.' ) 
    self:AddTestMethod( 'PLVLDSDT',,'Teste da funcao PLVLDSDT.' ) 
    self:AddTestMethod( 'PLVLDUSRP',,'Teste da funcao PLVLDUSRP.' ) 
    self:AddTestMethod( 'PLIMPWEB',,'Teste da funcao PLIMPWEB.' ) 
    self:AddTestMethod( 'PLSUSRBKP',,'Teste da funcao PLSUSRBKP.' ) 
    self:AddTestMethod( 'CONVDAD',,'Teste da funcao CONVDAD.' ) 
    self:AddTestMethod( 'PLSHISGRV',,'Teste da funcao PLSHISGRV.' ) 
    self:AddTestMethod( 'PLSHISDEL',,'Teste da funcao PLSHISDEL.' ) 
    self:AddTestMethod( 'PLSHISCON',,'Teste da funcao PLSHISCON.' ) 
    self:AddTestMethod( 'PLVLDPFS',,'Teste da funcao PLVLDPFS.' ) 
    self:AddTestMethod( 'PLVLDPRE',,'Teste da funcao PLVLDPRE.' ) 
    self:AddTestMethod( 'PLSATUSS',,'Teste da funcao PLSATUSS.' ) 
    self:AddTestMethod( 'PLSATUCS',,'Teste da funcao PLSATUCS.' ) 
    self:AddTestMethod( 'PLIDSALD',,'Teste da funcao PLIDSALD.' ) 
    self:AddTestMethod( 'PLSSOLV',,'Teste da funcao PLSSOLV.' ) 
    self:AddTestMethod( 'PLSTRBDIOP',,'Teste da funcao PLSTRBDIOP.' ) 
    self:AddTestMethod( 'MASKDIOPS',,'Teste da funcao MASKDIOPS.' ) 
    self:AddTestMethod( 'PLGRVLOG',,'Teste da funcao PLGRVLOG.' ) 
    self:AddTestMethod( 'PLGRVLGB',,'Teste da funcao PLGRVLGB.' ) 
    self:AddTestMethod( 'PLRDATP',,'Teste da funcao PLRDATP.' ) 
    self:AddTestMethod( 'PLSCARBD6',,'Teste da funcao PLSCARBD6.' ) 
    self:AddTestMethod( 'PLSXBKC',,'Teste da funcao PLSXBKC.' ) 
    self:AddTestMethod( 'PLSNEGCOM',,'Teste da funcao PLSNEGCOM.' ) 
    self:AddTestMethod( 'PLSSELOPT',,'Teste da funcao PLSSELOPT.' ) 	
Return

METHOD SetUpClass() CLASS FunctionsTestCase
Return _Super:SetUpClass()

METHOD TearDownClass() CLASS FunctionsTestCase
	Local oResult := FWTestHelper():New()

    oResult:UTRestParam(oResult:aParam)
	DelClassIntf()
	
Return oResult
//Test CONVDAD
METHOD CONVDAD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local uVal := Nil

	oResult:activate()
	
	CONVDAD(uVal)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test MASKDIOPS
METHOD MASKDIOPS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cVlr := ''

	oResult:activate()
	
	MASKDIOPS(cVlr)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PCLPGAUTO
METHOD PCLPGAUTO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PCLPGAUTO()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PCLPOSGLO
METHOD PCLPOSGLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PCLPOSGLO()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLFILFIL
METHOD PLFILFIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cRet := ''

	oResult:activate()
	
	PLFILFIL(cRet)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLFINDSRA
METHOD PLFINDSRA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local aIndexSra := {}
    Local nAt := 0
    Local cChave := ''
    Local bFiltraBrw := Nil
    Local oSelect := Nil

	oResult:activate()
	
	PLFINDSRA(aIndexSra,nAt,cChave,bFiltraBrw,oSelect)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLGERAMAIL
METHOD PLGERAMAIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLGERAMAIL()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLGRVLGB
METHOD PLGRVLGB() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cMsg := ''
    Local cTpLog := ''

	oResult:activate()
	
	PLGRVLGB(cMsg,cTpLog)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLGRVLOG
METHOD PLGRVLOG() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cMsg := ''
    Local cTpLog := ''
    Local nTp := 0

	oResult:activate()
	
	PLGRVLOG(cMsg,cTpLog,nTp)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLIDSALD
METHOD PLIDSALD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local dDatsld := stod('')
    Local cTpProc := ''

	oResult:activate()
	
	PLIDSALD(dDatsld,cTpProc)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLIMPWEB
METHOD PLIMPWEB() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local lImpGui := .F.
    Local cGuia := ''

	oResult:activate()
	
	PLIMPWEB(lImpGui,cGuia)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLLEGRPMAIL
METHOD PLLEGRPMAIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cEmail := ''

	oResult:activate()
	
	PLLEGRPMAIL(cEmail)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLPROFSAUD
METHOD PLPROFSAUD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodRda := ''
    Local cCodLoc := ''
    Local cBusca := ''
    Local cTipoBusca := ''
    Local nTp := 0
    Local cTipGui := ''

	oResult:activate()
	
	PLPROFSAUD(cCodRda,cCodLoc,cBusca,cTipoBusca,nTp,cTipGui)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRDATP
METHOD PLRDATP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLRDATP()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRELBEN
METHOD PLRELBEN() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodUsr := ''

	oResult:activate()
	
	PLRELBEN(cCodUsr)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRELCOS
METHOD PLRELCOS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodUsr := ''

	oResult:activate()
	
	PLRELCOS(cCodUsr)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRELRDA
METHOD PLRELRDA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodUsr := ''

	oResult:activate()
	
	PLRELRDA(cCodUsr)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSATUCS
METHOD PLSATUCS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cStaLib := ''
    Local cAliCab := ''

	oResult:activate()
	
	PLSATUCS(cStaLib,cAliCab)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSATUSS
METHOD PLSATUSS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local naoUsado := 0
    Local lSaldo := .F.
    Local lStaLib := .F.
    Local nSaldo := 0
    Local cStaLib := ''
    Local lInter := .F.
    Local cChkLib := ''
    Local nIdx := 0
    Local lChkBE2 := .F.
    Local nRecno := 0
    Local nIdxBe2 := 0
    Local nIncre := 0
    Local cCodPad := ''
    Local cCodPro := ''
    Local cDente := ''
    Local cFace := ''
    Local cOffline := ''

	oResult:activate()
	
	PLSATUSS(naoUsado,lSaldo,lStaLib,nSaldo,cStaLib,lInter,cChkLib,nIdx,lChkBE2,nRecno,nIdxBe2,nIncre,cCodPad,cCodPro,cDente,cFace,cOffline)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSBCTDESC
METHOD PLSBCTDESC() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSBCTDESC()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSCARBD6
METHOD PLSCARBD6() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cNumPeg := ''

	oResult:activate()
	
	PLSCARBD6(cNumPeg)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSCHKCRI
METHOD PLSCHKCRI() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local aDadPar := {}

	oResult:activate()
	
	PLSCHKCRI(aDadPar)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSCODSUP
METHOD PLSCODSUP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodigo := ''
    Local cGruGen := ''

	oResult:activate()
	
	PLSCODSUP(cCodigo,cGruGen)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSDIGI
METHOD PLSDIGI() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodigo := ''
    Local nModulo := 0

	oResult:activate()
	
	PLSDIGI(cCodigo,nModulo)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSENDMAIL
METHOD PLSENDMAIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local oPrinta := Nil
    Local lDireto := .F.

	oResult:activate()
	
	PLSENDMAIL(oPrinta,lDireto)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSGRAVERR
METHOD PLSGRAVERR() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cTipo := ''
    Local uValor := Nil
    Local aMsgErro := {}

	oResult:activate()
	
	PLSGRAVERR(cTipo,uValor,aMsgErro)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISCON
METHOD PLSHISCON() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cIdeRot := ''
    Local cCodCha := ''
    Local cTitulo := ''

	oResult:activate()
	
	PLSHISCON(cIdeRot,cCodCha,cTitulo)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISDEL
METHOD PLSHISDEL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cIdeRot := ''
    Local cCodCha := ''

	oResult:activate()
	
	PLSHISDEL(cIdeRot,cCodCha)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISGRV
METHOD PLSHISGRV() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cIdeRot := ''
    Local cCodCha := ''
    Local cSeq := ''
    Local cHistor := ''
    Local lHist := .F.

	oResult:activate()
	
	PLSHISGRV(cIdeRot,cCodCha,cSeq,cHistor,lHist)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSIGUALA
METHOD PLSIGUALA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cVar := ''
    Local uVal := Nil

	oResult:activate()
	
	PLSIGUALA(cVar,uVal)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSINTAUT
METHOD PLSINTAUT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodOpe := ''

	oResult:activate()
	
	PLSINTAUT(cCodOpe)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSINTPAD
METHOD PLSINTPAD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSINTPAD()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSINTVLD
METHOD PLSINTVLD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodInt := ''
    Local cCodOpe := ''

	oResult:activate()
	
	PLSINTVLD(cCodInt,cCodOpe)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSISAUTO
METHOD PLSISAUTO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSISAUTO()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSNAODISP
METHOD PLSNAODISP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cFuncao := ''

	oResult:activate()
	
	PLSNAODISP(cFuncao)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSNEGCOM
METHOD PLSNEGCOM() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cSequen := ''
    Local cCodPad := ''
    Local cCodPro := ''
    Local cStatus := ''
    Local dDatPro := stod('')
    Local nOpc := 0
    Local cChave := ''
    Local lVisItens := .F.
    Local cCodRda := ''
    Local cCodEsp := ''
    Local cCodLocal := ''
    Local cMatrUs := ''
    Local cAlias := ''
    Local lTela := .F.
    Local lBD7 := .F.

	oResult:activate()
	
	PLSNEGCOM(cSequen,cCodPad,cCodPro,cStatus,dDatPro,nOpc,cChave,lVisItens,cCodRda,cCodEsp,cCodLocal,cMatrUs,cAlias,lTela,lBD7)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSOBRIGAT
METHOD PLSOBRIGAT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local aGets := {}
    Local aTela := {}
    Local tObg := Nil
    Local lPlsServer := .F.
    Local aMsgErro := {}

	oResult:activate()
	
	PLSOBRIGAT(aGets,aTela,tObg,lPlsServer,aMsgErro)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSPOSGLO
METHOD PLSPOSGLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodOpe := ''
    Local cCodGlo := ''
    Local cDescri := ''
    Local cLocalExec := ''
    Local cAtivo := ''
    Local cTpLocExec := ''
    Local cAudito := ''
    Local lAnaAmbos := .F.

	oResult:activate()
	
	PLSPOSGLO(cCodOpe,cCodGlo,cDescri,cLocalExec,cAtivo,cTpLocExec,cAudito,lAnaAmbos)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSPROAM
METHOD PLSPROAM() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cAno := ''
    Local cMes := ''

	oResult:activate()
	
	PLSPROAM(cAno,cMes)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRETGLO
METHOD PLSRETGLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodOpe := ''
    Local cCodGlo := ''

	oResult:activate()
	
	PLSRETGLO(cCodOpe,cCodGlo)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRETTIT
METHOD PLSRETTIT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cAlias := ''

	oResult:activate()
	
	PLSRETTIT(cAlias)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRTMASPR
METHOD PLSRTMASPR() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodPad := ''
    Local cCodPSA := ''

	oResult:activate()
	
	PLSRTMASPR(cCodPad,cCodPSA)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSELOPT
METHOD PLSSELOPT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cTexTit := ''
    Local cTexChk := ''
    Local aMatLin := {}
    Local aMatCol := {}
    Local nOpc := 0
    Local lChkQt := .F.
    Local lMosMt := .F.
    Local lVisItens := .F.
    Local oDlgTB := Nil
    Local nLinI := 0
    Local nColI := 0
    Local nLinF := 0
    Local nColF := 0

	oResult:activate()
	
	PLSSELOPT(cTexTit,cTexChk,aMatLin,aMatCol,nOpc,lChkQt,lMosMt,lVisItens,oDlgTB,nLinI,nColI,nLinF,nColF)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSINC
METHOD PLSSINC() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cProg := ''
    Local cAlias1 := ''
    Local cAlias2 := ''
    Local lEmpty := .F.
    Local lLeTab := .F.
    Local nRecAlia1 := 0
    Local nIndAlia1 := 0
    Local cChvAlia1 := ''
    Local nRecAlia2 := 0
    Local nIndAlia2 := 0
    Local cChvAlia2 := ''

	oResult:activate()
	
	PLSSINC(cProg,cAlias1,cAlias2,lEmpty,lLeTab,nRecAlia1,nIndAlia1,cChvAlia1,nRecAlia2,nIndAlia2,cChvAlia2)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSOLV
METHOD PLSSOLV() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodInt := ''
    Local dDatsld := stod('')

	oResult:activate()
	
	PLSSOLV(cCodInt,dDatsld)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSXBSRA
METHOD PLSSXBSRA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSSXBSRA()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSTRBDIOP
METHOD PLSTRBDIOP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cTipo := ''
    Local cCodInt := ''

	oResult:activate()
	
	PLSTRBDIOP(cTipo,cCodInt)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSUSRBKP
METHOD PLSUSRBKP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cMatricula := ''
    Local dData := stod('')
    Local aTabelas := {}

	oResult:activate()
	
	PLSUSRBKP(cMatricula,dData,aTabelas)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSVLDINT
METHOD PLSVLDINT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodInt := ''
    Local lPlsServer := .F.

	oResult:activate()
	
	PLSVLDINT(cCodInt,lPlsServer)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSVLDSUP
METHOD PLSVLDSUP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodigo := ''
    Local cGruGen := ''

	oResult:activate()
	
	PLSVLDSUP(cCodigo,cGruGen)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSVLTNT
METHOD PLSVLTNT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSVLTNT()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSXBKC
METHOD PLSXBKC() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLSXBKC()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSXUSRBLO
METHOD PLSXUSRBLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cAno := ''
    Local cMes := ''
    Local dDatBlo := stod('')
    Local cMotBlo := ''

	oResult:activate()
	
	PLSXUSRBLO(cAno,cMes,dDatBlo,cMotBlo)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSZERO
METHOD PLSZERO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cVar := ''
    Local nTam := 0

	oResult:activate()
	
	PLSZERO(cVar,nTam)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDPFS
METHOD PLVLDPFS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cAlias := ''
    Local cChave := ''
    Local nOrdem := 0
    Local dDatPro := stod('')

	oResult:activate()
	
	PLVLDPFS(cAlias,cChave,nOrdem,dDatPro)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDPRE
METHOD PLVLDPRE() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local aMat := {}
    Local cTpAca := ''
    Local cOrdDesc := ''

	oResult:activate()
	
	PLVLDPRE(aMat,cTpAca,cOrdDesc)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDREQ
METHOD PLVLDREQ() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cNumReq := ''

	oResult:activate()
	
	PLVLDREQ(cNumReq)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDSDT
METHOD PLVLDSDT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()



	oResult:activate()
	
	PLVLDSDT()

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDUSRP
METHOD PLVLDUSRP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cCodUsr := ''
    Local cViaCar := ''
    Local cNomeCar := ''
    Local cLocalExec := ''
    Local cAreaAbr := ''
    Local cTpLocExec := ''
    Local cTipo := ''
    Local cTipAtd := ''
    Local DatGuia := stod('')
    Local BloqGui := Nil
    Local cTriCar := ''

	oResult:activate()
	
	PLVLDUSRP(cCodUsr,cViaCar,cNomeCar,cLocalExec,cAreaAbr,cTpLocExec,cTipo,cTipAtd,DatGuia,BloqGui,cTriCar)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDUSRW
METHOD PLVLDUSRW() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cLogUsr := ''
    Local cSenhaPLS := ''

	oResult:activate()
	
	PLVLDUSRW(cLogUsr,cSenhaPLS)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PROFALL
METHOD PROFALL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local cBusca := ''

	oResult:activate()
	
	PROFALL(cBusca)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult
