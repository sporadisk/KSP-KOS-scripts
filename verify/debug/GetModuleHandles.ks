// Run examples:
// RUNPATH("0:/debug/GetModuleHandles.ks", "radialDrogue", "ModuleParachute").
// RUNPATH("0:/debug/GetModuleHandles.ks", "parachuteRadial", "ModuleParachute").
// RUNPATH("0:/debug/GetModuleHandles.ks", "sasModule", "ModuleReactionWheel").
// RUNPATH("0:/debug/GetModuleHandles.ks", "SCANsat.Scanner", "SCANsat").
// RUNPATH("0:/debug/GetModuleHandles.ks", "RTShortDish2", "ModuleRTAntenna").
// RUNPATH("0:/debug/GetModuleHandles.ks", "longAntenna", "ModuleRTAntenna").
// RUNPATH("0:/debug/GetModuleHandles.ks", "scansat-multi-abi-1", "SCANsat").
PARAMETER partName.
PARAMETER moduleName.

LIST Parts IN allShipParts. // get a list of all ship parts
FOR P IN allShipParts {
	IF(P:NAME = partName) {
		PRINT "---------------".
		PRINT "Part found!".
		LOCAL md IS P:GETMODULE(moduleName).
		PRINT "Fields:".
		PRINT md:ALLFIELDS.
		PRINT "Events:".
		PRINT md:ALLEVENTS.
		PRINT "Actions:".
		PRINT md:ALLACTIONS.
	}
}
