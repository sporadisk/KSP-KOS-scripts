// Run examples:
// RUNPATH("0:/debug/GetPartModules.ks", "radialDrogue").
// RUNPATH("0:/debug/GetPartModules.ks", "parachuteRadial").
// RUNPATH("0:/debug/GetPartModules.ks", "sasModule").
// RUNPATH("0:/debug/GetPartModules.ks", "SCANsat.Scanner").
// RUNPATH("0:/debug/GetPartModules.ks", "RTShortDish2").
// RUNPATH("0:/debug/GetPartModules.ks", "longAntenna").
// RUNPATH("0:/debug/GetPartModules.ks", "scansat-multi-abi-1").

PARAMETER partName.
LIST Parts IN allShipParts. // get a list of all ship parts
FOR P IN allShipParts {
	IF(P:NAME = partName) {
		PRINT "---------------".
		PRINT "Part found!".
		PRINT "Modules:".
		PRINT P:MODULES.
	}
}
