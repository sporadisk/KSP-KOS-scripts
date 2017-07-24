// Run examples:
// RUNPATH("0:/debug/GetPartModules.ks", "radialDrogue").
// RUNPATH("0:/debug/GetPartModules.ks", "parachuteRadial").
// RUNPATH("0:/debug/GetPartModules.ks", "sasModule").
// RUNPATH("0:/debug/GetPartModules.ks", "SCANsat.Scanner").
// RUNPATH("0:/debug/GetPartModules.ks", "RTShortDish2").
// RUNPATH("0:/debug/GetPartModules.ks", "longAntenna").

PARAMETER partName.
FOR P IN SHIP:PARTS {
	IF(P:NAME = partName) {
		PRINT "---------------".
		PRINT "Part found!".
		PRINT "Modules:".
		PRINT P:MODULES.
	}
}
