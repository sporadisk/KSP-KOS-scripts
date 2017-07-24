// Run examples:
// RUNPATH("0:/satellites/Sat_3.ks", 90, 2, 90000, 490000, 25, 2).

// TargetDirection (0-359): The compass direction to turn towards after launch.
PARAMETER TargetDirection.
// BoosterWaitPeriod: The number of seconds to wait for boosters to drop away between stages (default 2)
// This parameter also defines the number of seconds to wait after shedding the fairings.
PARAMETER BoosterWaitPeriod IS 2.
// StageOrbit: The altitude of the intermediate orbit to use as stepping stone to the higher orbit
PARAMETER StageOrbit IS 70000.
// TargetOrbit: The altitude of the final orbit
PARAMETER TargetOrbit IS 80000.
// CircBurnBuffer: How soon before apoapsis to start circularization burn.
PARAMETER CircBurnBuffer IS 10.
// GravityTurnRatio: How slowly should the craft turn towards the horizon? (less=faster)
PARAMETER GravityTurnRatio IS 2.

RUNPATH("0:/modules/GravityTurn_mk2.ks").
RUNPATH("0:/modules/GetSolidFuel.ks"). // loads the GetSolidFuel-function
RUNPATH("0:/modules/GetPartModules.ks"). // loads the GetPartModules-function
RUNPATH("0:/modules/GetAllFuel.ks"). // loads the GetAllFuel-function

// Launch
STAGE.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

PRINT "Starting gravity turn".
LOCK STEERING TO GravityTurn(TargetDirection, StageOrbit, GravityTurnRatio).

SET solidFuel TO GetSolidFuel().

LOCK THROTTLE TO 1.
// Expend solid fuel stages in sequence
UNTIL solidFuel:CAPACITY = 0 { // run until we reach a stage whith no solid fuel boosters.
	PRINT "Next booster stage initiated".
	WAIT UNTIL solidFuel:AMOUNT < 0.0053. // wait until the current boosters are dry(ish)
	PRINT "Solid fuel empty".

	STAGE. // Separate
	WAIT BoosterWaitPeriod.
	STAGE. // Activate the next stage
}
LOCK THROTTLE TO 0.

PRINT "Solid fuel stages expended".

// Deploy the antenna!
PRINT "Deploying omni-antennas".
SET antennas TO GetPartModules("longAntenna", "ModuleRTAntenna").
FOR antenna IN antennas {
	antenna:DOEVENT("activate").
}

WAIT BoosterWaitPeriod * 2.

PRINT "Burning to achieve apoapsis".
// Continue burning until the target apoapsis is achieved
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:APOAPSIS >= StageOrbit.
LOCK THROTTLE TO 0.

PRINT "Waiting for apoapsis".
// Wait for apoapsis
LOCK STEERING TO HEADING(TargetDirection,0).
WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.

PRINT "Starting circularization burn".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS >= StageOrbit OR GetAllFuel() = 0.
PRINT "Stage orbit achieved!".
LOCK THROTTLE TO 0.

LOCK STEERING TO SHIP:PROGRADE.

// We're in orbit - next step: Reach higher orbit
IF(SHIP:APOAPSIS < TargetOrbit) {
	LOCK THROTTLE TO 1.
	WAIT UNTIL SHIP:APOAPSIS >= TargetOrbit.
	LOCK THROTTLE TO 0.
}
PRINT "Target apoapsis achieved!".

IF(SHIP:PERIAPSIS < TargetOrbit) {
	WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.
	LOCK THROTTLE TO 1.
	WAIT UNTIL SHIP:PERIAPSIS >= TargetOrbit.
	LOCK THROTTLE TO 0.
}
PRINT "Target periapsis achieved!".
