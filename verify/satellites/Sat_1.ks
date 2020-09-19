// Run example: RUNPATH("0:/satellites/Sat_1.ks", 0, 2, 80000, 10, 1).

// TargetDirection (0-359): The compass direction to turn towards after launch.
PARAMETER TargetDirection.
// BoosterWaitPeriod: The number of seconds to wait for boosters to drop away between stages (default 2)
// This parameter also defines the number of seconds to wait after shedding the fairings.
PARAMETER BoosterWaitPeriod IS 2.
// TargetOrbit: The sea-level altitude of the intended orbit
PARAMETER TargetOrbit IS 80000.
// CircBurnBuffer: How soon before apoapsis to start circularization burn.
PARAMETER CircBurnBuffer IS 10.
// GravityTurnRatio: How slowly should the craft turn towards the horizon? (less=faster)
PARAMETER GravityTurnRatio IS 2.

RUNPATH("0:/modules/GravityTurn.ks").
RUNPATH("0:/modules/GetSolidFuel.ks"). // loads the GetSolidFuel-function
RUNPATH("0:/modules/GetPartModules.ks"). // loads the GetPartModules-function
RUNPATH("0:/modules/GetAllFuel.ks"). // loads the GetAllFuel-function

// Launch
STAGE.

// Disable reaction wheel - use fins for ascent.
SET reactionWheels TO GetPartModules("sasModule", "ModuleReactionWheel").
reactionWheels[0]:DOEVENT("toggle torque").

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

PRINT "Starting gravity turn".
LOCK STEERING TO GravityTurn(TargetDirection, TargetOrbit, GravityTurnRatio).

SET solidFuel TO GetSolidFuel().

// Expend solid fuel stages in sequence
UNTIL solidFuel:CAPACITY = 0 { // run until we reach a stage whith no solid fuel boosters.
	PRINT "Next booster stage initiated".
	WAIT UNTIL solidFuel:AMOUNT < 0.0034. // wait until the current boosters are dry(ish)
	PRINT "Solid fuel empty".

	STAGE. // Separate
	WAIT BoosterWaitPeriod.
	STAGE. // Activate the next stage
}

PRINT "Solid fuel stages expended".

// Time for the reaction wheel to do its part.
reactionWheels[0]:DOEVENT("toggle torque").

WAIT BoosterWaitPeriod * 2.

PRINT "Burning to achieve apoapsis".
// Continue burning until the target apoapsis is achieved
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:APOAPSIS >= TargetOrbit.
LOCK THROTTLE TO 0.

LOCK STEERING TO HEADING(TargetDirection,0).

PRINT "Waiting for apoapsis".
// Wait for apoapsis
WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.

PRINT "Starting circularization burn".
// Start circularization burn
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS >= TargetOrbit OR GetAllFuel() = 0.
PRINT "Burn complete!".
LOCK THROTTLE TO 0.

// We've probably reached orbit at this point: Success!
// Deploy the antenna!
PRINT "Deploying scanSat radars".
SET scanSat TO GetPartModules("SCANsat.Scanner", "SCANsat").
FOR scanner IN scanSat {
	scanner:DOEVENT("start scan: radar").
}
