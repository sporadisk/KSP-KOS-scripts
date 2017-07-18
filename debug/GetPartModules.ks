// Run examples:
// RUNPATH("0:/debug/GetPartModules.ks", "radialDrogue").
// RUNPATH("0:/debug/GetPartModules.ks", "parachuteRadial").
PARAMETER partName.
FOR P IN SHIP:PARTS {
	IF(P:NAME = partName) {
		PRINT "---------------".
		PRINT "Part found!".
		PRINT "Modules:".
		PRINT P:MODULES.
	}
}
