// made for KOS 1.2.0.0
function GetPartModules {
	PARAMETER partName.
	PARAMETER moduleName.

	SET partList to LIST(). // construct an empty list
	LIST Parts IN allShipParts. // get a list of all ship parts
	FOR P IN allShipParts {
		// add partModules matching the partName and moduleName to the empty list
		IF(P:NAME = partName) {
			partList:ADD(P:GETMODULE(moduleName)).
		}
	}
	RETURN partList.
}
