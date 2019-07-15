#include "PROTHEUS.CH"

CLASS PLSA080TestSuite FROM FWDefaultTestSuite

	DATA aParam
	
	METHOD PLSA080TestSuite() CONSTRUCTOR
	METHOD SetUpSuite()
	METHOD TearDownSuite()
	
ENDCLASS

METHOD PLSA080TestSuite() CLASS PLSA080TestSuite
	_Super:FWDefaultTestSuite()
	Self:AddTestSuite(PLSA080TestGroup():PLSA080TestGroup() )
Return

METHOD SetUpSuite() CLASS PLSA080TestSuite
Local oHelper := FWTestHelper():New()

oHelper:UTOpenFilial("T1","M SP 01",,,"lima.everton","a")
oHelper:Activate()

Return oHelper

METHOD TearDownSuite() CLASS PLSA080TestSuite
	Local oHelper := FWTestHelper():New()
	oHelper:UTRestParam()
Return oHelper