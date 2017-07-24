// Run examples:
// RUNPATH("0:/debug/RunModuleEvent.ks", "science.module", "ModuleScienceExperiment", "observe materials bay").
// RUNPATH("0:/debug/RunModuleEvent.ks", "GooExperiment", "ModuleScienceExperiment", "observe mystery goo").
// RUNPATH("0:/debug/RunModuleEvent.ks", "sensorBarometer", "ModuleScienceExperiment", "log pressure data").
// RUNPATH("0:/debug/RunModuleEvent.ks", "sensorThermometer", "ModuleScienceExperiment", "log temperature").
PARAMETER partName.
PARAMETER moduleName.
PARAMETER eventName.

RUNPATH("0:/modules/GetPartModules.ks").
RUNPATH("0:/modules/RunPartModuleEvent.ks").
RunPartModuleEvent(partName, moduleName, eventName).
