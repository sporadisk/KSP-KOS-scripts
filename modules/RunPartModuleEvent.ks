// works on KOS 1.2.0.0
// Assumes that GetPartModules is loaded.
// Usage examples:
// RunPartModuleEvent("SCANsat.Scanner", "SCANsat", "start scan: radar").
// RunPartModuleEvent("longAntenna", "ModuleRTAntenna", "activate").
function RunPartModuleEvent {
	PARAMETER partName.
	PARAMETER moduleName.
	PARAMETER eventName.

	SET partModules TO GetPartModules(partName, moduleName).
	FOR module IN partModules {
		module:DOEVENT(eventName).
	}
}
