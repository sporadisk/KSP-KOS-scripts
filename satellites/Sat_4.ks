// made for KOS 1.2.0.0
// Run command examples: 
// RUNPATH("0:/satellites/Sat_4.ks", 90, 2, 2, 85000, 85000).
// RUNPATH("0:/satellites/Sat_4.ks", 0, 2, 3, 85000, 100000).
// RUNPATH("0:/satellites/Sat_4.ks", 0, 2, 3, 85000, 100000).
// RUNPATH("0:/satellites/Sat_4.ks", 90, 2, 3, 100000, 600000).

// This script sends satellites into a specific orbit.
// It assumes your satellite is equipped with the standard extendable omni-antenna

// ---- Config ----

// TargetDirection (0-359): The compass direction to turn towards after launch.
PARAMETER TargetDirection.

// Sets the amount of booster stages (counting only the boosters, not the separators between them.)
PARAMETER BoosterStageCount IS 2.

// GravityTurnFactor: A higher factor means you start the turn earlier.
PARAMETER GravityTurnFactor IS 2.

// StageOrbit: The altitude of the intermediate orbit to use as stepping stone to the higher orbit
PARAMETER StageOrbit IS 70000.

// TargetOrbit: The altitude of the final orbit
PARAMETER TargetOrbit IS 80000.

// CircBurnBuffer: How many seconds before apoapsis to start circularization burn.
PARAMETER CircBurnBuffer IS 10.

// AntennaName - The name of the deployable antenna type you're using (if any)
PARAMETER AntennaName IS "longAntenna".

// AntennaModule - The module name of the antenna
PARAMETER AntennaModule IS "ModuleRTAntenna".

// AntennaDeployEvent - The event to run on the antenna in order to deploy it
PARAMETER AntennaDeployEvent IS "activate".

// ---- End Config ----

// Get dependencies
COPYPATH("0:/modules/suborbital_1.ks", "1:").
COPYPATH("0:/modules/increaseOrbit.ks", "1:").
RUNPATH("0:/modules/GetPartModules.ks"). // loads the GetPartModules-function

// Get into suborbital flight
RUN "suborbital_1"(TargetDirection, BoosterStageCount, GravityTurnFactor, StageOrbit).

// Deploy omni-antenna now that we're safely out of atmosphere
PRINT "Deploying antenna".
SET antennas TO GetPartModules(AntennaName, AntennaModule).
FOR antenna IN antennas {
	antenna:DOEVENT(AntennaDeployEvent).
}

// Increase to target orbit
RUN "increaseOrbit"(StageOrbit, TargetOrbit, CircBurnBuffer).
