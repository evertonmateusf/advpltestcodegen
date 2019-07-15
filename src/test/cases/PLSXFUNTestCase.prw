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
//Test MASKDIOPS
METHOD MASKDIOPS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CVLR := ''

	oResult:activate()
	
	MASKDIOPS(CVLR)

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

    Local CRET := ''

	oResult:activate()
	
	PLFILFIL(CRET)

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

    Local CMSG := ''
    Local CTPLOG := ''

	oResult:activate()
	
	PLGRVLGB(CMSG,CTPLOG)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLGRVLOG
METHOD PLGRVLOG() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CMSG := ''
    Local CTPLOG := ''
    Local NTP := 0

	oResult:activate()
	
	PLGRVLOG(CMSG,CTPLOG,NTP)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLIDSALD
METHOD PLIDSALD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local DDATSLD := stod('')
    Local CTPPROC := ''

	oResult:activate()
	
	PLIDSALD(DDATSLD,CTPPROC)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLIMPWEB
METHOD PLIMPWEB() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local LIMPGUI := .F.
    Local CGUIA := ''

	oResult:activate()
	
	PLIMPWEB(LIMPGUI,CGUIA)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLLEGRPMAIL
METHOD PLLEGRPMAIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CEMAIL := ''

	oResult:activate()
	
	PLLEGRPMAIL(CEMAIL)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLPROFSAUD
METHOD PLPROFSAUD() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODRDA := ''
    Local CCODLOC := ''
    Local CBUSCA := ''
    Local CTIPOBUSCA := ''
    Local NTP := 0
    Local CTIPGUI := ''

	oResult:activate()
	
	PLPROFSAUD(CCODRDA,CCODLOC,CBUSCA,CTIPOBUSCA,NTP,CTIPGUI)

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

    Local CCODUSR := ''

	oResult:activate()
	
	PLRELBEN(CCODUSR)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRELCOS
METHOD PLRELCOS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODUSR := ''

	oResult:activate()
	
	PLRELCOS(CCODUSR)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLRELRDA
METHOD PLRELRDA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODUSR := ''

	oResult:activate()
	
	PLRELRDA(CCODUSR)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSATUCS
METHOD PLSATUCS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CSTALIB := ''
    Local CALICAB := ''

	oResult:activate()
	
	PLSATUCS(CSTALIB,CALICAB)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSATUSS
METHOD PLSATUSS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local NAOUSADO := 0
    Local LSALDO := .F.
    Local LSTALIB := .F.
    Local NSALDO := 0
    Local CSTALIB := ''
    Local LINTER := .F.
    Local CCHKLIB := ''
    Local NIDX := 0
    Local LCHKBE2 := .F.
    Local NRECNO := 0
    Local NIDXBE2 := 0
    Local NINCRE := 0
    Local CCODPAD := ''
    Local CCODPRO := ''
    Local CDENTE := ''
    Local CFACE := ''
    Local COFFLINE := ''

	oResult:activate()
	
	PLSATUSS(NAOUSADO,LSALDO,LSTALIB,NSALDO,CSTALIB,LINTER,CCHKLIB,NIDX,LCHKBE2,NRECNO,NIDXBE2,NINCRE,CCODPAD,CCODPRO,CDENTE,CFACE,COFFLINE)

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

    Local CNUMPEG := ''

	oResult:activate()
	
	PLSCARBD6(CNUMPEG)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSCHKCRI
METHOD PLSCHKCRI() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local ADADPAR := {}

	oResult:activate()
	
	PLSCHKCRI(ADADPAR)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSCODSUP
METHOD PLSCODSUP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODIGO := ''
    Local CGRUGEN := ''

	oResult:activate()
	
	PLSCODSUP(CCODIGO,CGRUGEN)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSDIGI
METHOD PLSDIGI() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODIGO := ''
    Local NMODULO := 0

	oResult:activate()
	
	PLSDIGI(CCODIGO,NMODULO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSENDMAIL
METHOD PLSENDMAIL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local OPRINTA := Nil
    Local LDIRETO := .F.

	oResult:activate()
	
	PLSENDMAIL(OPRINTA,LDIRETO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSGRAVERR
METHOD PLSGRAVERR() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CTIPO := ''
    Local UVALOR := Nil
    Local AMSGERRO := {}

	oResult:activate()
	
	PLSGRAVERR(CTIPO,UVALOR,AMSGERRO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISCON
METHOD PLSHISCON() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CIDEROT := ''
    Local CCODCHA := ''
    Local CTITULO := ''

	oResult:activate()
	
	PLSHISCON(CIDEROT,CCODCHA,CTITULO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISDEL
METHOD PLSHISDEL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CIDEROT := ''
    Local CCODCHA := ''

	oResult:activate()
	
	PLSHISDEL(CIDEROT,CCODCHA)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSHISGRV
METHOD PLSHISGRV() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CIDEROT := ''
    Local CCODCHA := ''
    Local CSEQ := ''
    Local CHISTOR := ''
    Local LHIST := .F.

	oResult:activate()
	
	PLSHISGRV(CIDEROT,CCODCHA,CSEQ,CHISTOR,LHIST)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSIGUALA
METHOD PLSIGUALA() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CVAR := ''
    Local UVAL := Nil

	oResult:activate()
	
	PLSIGUALA(CVAR,UVAL)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSINTAUT
METHOD PLSINTAUT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODOPE := ''

	oResult:activate()
	
	PLSINTAUT(CCODOPE)

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

    Local CCODINT := ''
    Local CCODOPE := ''

	oResult:activate()
	
	PLSINTVLD(CCODINT,CCODOPE)

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

    Local CFUNCAO := ''

	oResult:activate()
	
	PLSNAODISP(CFUNCAO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSNEGCOM
METHOD PLSNEGCOM() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CSEQUEN := ''
    Local CCODPAD := ''
    Local CCODPRO := ''
    Local CSTATUS := ''
    Local DDATPRO := stod('')
    Local NOPC := 0
    Local CCHAVE := ''
    Local LVISITENS := .F.
    Local CCODRDA := ''
    Local CCODESP := ''
    Local CCODLOCAL := ''
    Local CMATRUS := ''
    Local CALIAS := ''
    Local LTELA := .F.
    Local LBD7 := .F.

	oResult:activate()
	
	PLSNEGCOM(CSEQUEN,CCODPAD,CCODPRO,CSTATUS,DDATPRO,NOPC,CCHAVE,LVISITENS,CCODRDA,CCODESP,CCODLOCAL,CMATRUS,CALIAS,LTELA,LBD7)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSOBRIGAT
METHOD PLSOBRIGAT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local AGETS := {}
    Local ATELA := {}
    Local TOBG := Nil
    Local LPLSSERVER := .F.
    Local AMSGERRO := {}

	oResult:activate()
	
	PLSOBRIGAT(AGETS,ATELA,TOBG,LPLSSERVER,AMSGERRO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSPOSGLO
METHOD PLSPOSGLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODOPE := ''
    Local CCODGLO := ''
    Local CDESCRI := ''
    Local CLOCALEXEC := ''
    Local CATIVO := ''
    Local CTPLOCEXEC := ''
    Local CAUDITO := ''
    Local LANAAMBOS := .F.

	oResult:activate()
	
	PLSPOSGLO(CCODOPE,CCODGLO,CDESCRI,CLOCALEXEC,CATIVO,CTPLOCEXEC,CAUDITO,LANAAMBOS)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSPROAM
METHOD PLSPROAM() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CANO := ''
    Local CMES := ''

	oResult:activate()
	
	PLSPROAM(CANO,CMES)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRETGLO
METHOD PLSRETGLO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODOPE := ''
    Local CCODGLO := ''

	oResult:activate()
	
	PLSRETGLO(CCODOPE,CCODGLO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRETTIT
METHOD PLSRETTIT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CALIAS := ''

	oResult:activate()
	
	PLSRETTIT(CALIAS)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSRTMASPR
METHOD PLSRTMASPR() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODPAD := ''
    Local CCODPSA := ''

	oResult:activate()
	
	PLSRTMASPR(CCODPAD,CCODPSA)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSELOPT
METHOD PLSSELOPT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CTEXTIT := ''
    Local CTEXCHK := ''
    Local AMATLIN := {}
    Local AMATCOL := {}
    Local NOPC := 0
    Local LCHKQT := .F.
    Local LMOSMT := .F.
    Local LVISITENS := .F.
    Local ODLGTB := Nil
    Local NLINI := 0
    Local NCOLI := 0
    Local NLINF := 0
    Local NCOLF := 0

	oResult:activate()
	
	PLSSELOPT(CTEXTIT,CTEXCHK,AMATLIN,AMATCOL,NOPC,LCHKQT,LMOSMT,LVISITENS,ODLGTB,NLINI,NCOLI,NLINF,NCOLF)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSINC
METHOD PLSSINC() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CPROG := ''
    Local CALIAS1 := ''
    Local CALIAS2 := ''
    Local LEMPTY := .F.
    Local LLETAB := .F.
    Local NRECALIA1 := 0
    Local NINDALIA1 := 0
    Local CCHVALIA1 := ''
    Local NRECALIA2 := 0
    Local NINDALIA2 := 0
    Local CCHVALIA2 := ''

	oResult:activate()
	
	PLSSINC(CPROG,CALIAS1,CALIAS2,LEMPTY,LLETAB,NRECALIA1,NINDALIA1,CCHVALIA1,NRECALIA2,NINDALIA2,CCHVALIA2)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSSOLV
METHOD PLSSOLV() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODINT := ''
    Local DDATSLD := stod('')

	oResult:activate()
	
	PLSSOLV(CCODINT,DDATSLD)

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

    Local CTIPO := ''
    Local CCODINT := ''

	oResult:activate()
	
	PLSTRBDIOP(CTIPO,CCODINT)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSUSRBKP
METHOD PLSUSRBKP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CMATRICULA := ''
    Local DDATA := stod('')
    Local ATABELAS := {}

	oResult:activate()
	
	PLSUSRBKP(CMATRICULA,DDATA,ATABELAS)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSVLDINT
METHOD PLSVLDINT() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODINT := ''
    Local LPLSSERVER := .F.

	oResult:activate()
	
	PLSVLDINT(CCODINT,LPLSSERVER)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSVLDSUP
METHOD PLSVLDSUP() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CCODIGO := ''
    Local CGRUGEN := ''

	oResult:activate()
	
	PLSVLDSUP(CCODIGO,CGRUGEN)

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

    Local CANO := ''
    Local CMES := ''
    Local DDATBLO := stod('')
    Local CMOTBLO := ''

	oResult:activate()
	
	PLSXUSRBLO(CANO,CMES,DDATBLO,CMOTBLO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSZERO
METHOD PLSZERO() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CVAR := ''
    Local NTAM := 0

	oResult:activate()
	
	PLSZERO(CVAR,NTAM)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDPFS
METHOD PLVLDPFS() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CALIAS := ''
    Local CCHAVE := ''
    Local NORDEM := 0
    Local DDATPRO := stod('')

	oResult:activate()
	
	PLVLDPFS(CALIAS,CCHAVE,NORDEM,DDATPRO)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDPRE
METHOD PLVLDPRE() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local AMAT := {}
    Local CTPACA := ''
    Local CORDDESC := ''

	oResult:activate()
	
	PLVLDPRE(AMAT,CTPACA,CORDDESC)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDREQ
METHOD PLVLDREQ() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CNUMREQ := ''

	oResult:activate()
	
	PLVLDREQ(CNUMREQ)

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

    Local CCODUSR := ''
    Local CVIACAR := ''
    Local CNOMECAR := ''
    Local CLOCALEXEC := ''
    Local CAREAABR := ''
    Local CTPLOCEXEC := ''
    Local CTIPO := ''
    Local CTIPATD := ''
    Local DATGUIA := stod('')
    Local BLOQGUI := Nil
    Local CTRICAR := ''

	oResult:activate()
	
	PLVLDUSRP(CCODUSR,CVIACAR,CNOMECAR,CLOCALEXEC,CAREAABR,CTPLOCEXEC,CTIPO,CTIPATD,DATGUIA,BLOQGUI,CTRICAR)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLVLDUSRW
METHOD PLVLDUSRW() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CLOGUSR := ''
    Local CSENHAPLS := ''

	oResult:activate()
	
	PLVLDUSRW(CLOGUSR,CSENHAPLS)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PROFALL
METHOD PROFALL() CLASS FunctionsTestCase

	Local oResult := FWTestHelper():New()

    Local CBUSCA := ''

	oResult:activate()
	
	PROFALL(CBUSCA)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult
