#include "PROTHEUS.CH"

CLASS FunctionsTestGroup FROM FWDefaultTestSuite

	METHOD FunctionsTestGroup() CONSTRUCTOR
	
ENDCLASS

METHOD FunctionsTestGroup() CLASS FunctionsTestGroup
	_Super:FWDefaultTestSuite()
	Self:AddTestCase(FunctionsTestCase():FunctionsTestCase() )
Return