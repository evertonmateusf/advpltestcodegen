#include "PROTHEUS.CH"

CLASS FunctionsTestSuite FROM FWDefaultTestSuite

	DATA aParam
	
	METHOD FunctionsTestSuite() CONSTRUCTOR
	METHOD SetUpSuite()
	METHOD TearDownSuite()
	
ENDCLASS

METHOD FunctionsTestSuite() CLASS FunctionsTestSuite
	_Super:FWDefaultTestSuite()
	Self:AddTestSuite(FunctionsTestGroup():FunctionsTestGroup() )
Return

METHOD SetUpSuite() CLASS FunctionsTestSuite
Local oHelper := FWTestHelper():New()

// oHelper:UTOpenFilial("T1","M SP 01")
oHelper:UTOpenFilial("T1","M SP 01",,,"lima.everton","a")
oHelper:Activate()

Return oHelper

METHOD TearDownSuite() CLASS FunctionsTestSuite
	Local oHelper := FWTestHelper():New()
	oHelper:UTRestParam()
Return oHelper