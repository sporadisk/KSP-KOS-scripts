// Run examples:
// RUNPATH("0:/debug/RunPartModuleEvent.ks", "SCANsat.Scanner", "SCANsat", "start scan: radar").
// RUNPATH("0:/debug/RunPartModuleEvent.ks", "longAntenna", "ModuleRTAntenna", "activate").
PARAMETER partName.
PARAMETER moduleName.
PARAMETER eventName.

RUNPATH("0:/modules/GetPartModules.ks"). // loads the GetPartModules-function
SET partModules TO GetPartModules(partName, moduleName).
FOR module IN partModules {
	module:DOEVENT(eventName).
}
