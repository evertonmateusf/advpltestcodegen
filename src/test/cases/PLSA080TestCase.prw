#Include 'Protheus.ch'

CLASS PLSA080TestCase FROM FWDefaultTestCase
	
	METHOD PLSA080TestCase()
	METHOD SetUpClass()
	METHOD TearDownClass()

    METHOD PLSA080()
    METHOD MENUDEF()
ENDCLASS

METHOD PLSA080TestCase() CLASS PLSA080TestCase
	_Super:FWDefaultTestCase()

    self:AddTestMethod( 'PLSA080',,'Teste da funcao PLSA080.' ) 
    self:AddTestMethod( 'MENUDEF',,'Teste da funcao MENUDEF.' ) 	
Return

METHOD SetUpClass() CLASS PLSA080TestCase
Return _Super:SetUpClass()

METHOD TearDownClass() CLASS PLSA080TestCase
	Local oResult := FWTestHelper():New()

    oResult:UTRestParam(oResult:aParam)
	DelClassIntf()
	
Return oResult
//Test MENUDEF
METHOD MENUDEF() CLASS PLSA080TestCase

	Local oResult := FWTestHelper():New()

    Local CALIAS := ''
    Local PARAMETRO2 := Nil
    Local PARAMETRO3 := Nil

	oResult:activate()
	
	MENUDEF(CALIAS,PARAMETRO2,PARAMETRO3)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult

//Test PLSA080
METHOD PLSA080() CLASS PLSA080TestCase

	Local oResult := FWTestHelper():New()

    Local CALIAS := ''
    Local PARAMETRO2 := Nil

	oResult:activate()
	
	PLSA080(CALIAS,PARAMETRO2)

	oResult:AssertTrue( oResult:lOk, "" )
	oResult:deactivate()

Return oResult
