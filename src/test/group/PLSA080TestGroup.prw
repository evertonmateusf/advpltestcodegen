#include "PROTHEUS.CH"

CLASS PLSA080TestGroup FROM FWDefaultTestSuite

	METHOD PLSA080TestGroup() CONSTRUCTOR
	
ENDCLASS

METHOD PLSA080TestGroup() CLASS PLSA080TestGroup
	_Super:FWDefaultTestSuite()
	Self:AddTestCase(PLSA080TestCase():PLSA080TestCase() )
Return