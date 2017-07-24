function GetPartModules {
	PARAMETER partName.
	PARAMETER moduleName.
	SET partList to LIST().
	FOR P IN SHIP:PARTS {
		IF(P:NAME = partName) {
			partList:ADD(P:GETMODULE(moduleName)).
		}
	}
	RETURN partList.
}
