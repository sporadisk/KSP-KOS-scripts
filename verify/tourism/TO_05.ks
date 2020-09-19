// Run example:
// RUNPATH("0:/tourism/TO_05.ks", 1, 10, 2).
// This parameter also defines the number of seconds to wait after shedding the fairings.
PARAMETER BoosterWaitPeriod IS 2.
// CircBurnBuffer: How soon before apoapsis to start circularization burn.
PARAMETER CircBurnBuffer IS 10.
// GravityTurnRatio: How slowly should the craft turn towards the horizon? (less=faster)
PARAMETER GravityTurnRatio IS 2.
// FlipWait: How many seconds to wait for the ship to reverse direction before the retrograde burn
PARAMETER FlipWait IS 15.
// TargetOrbit: How high of an orbit to achieve before returning
PARAMETER TargetOrbit IS 73000.
// ReEntryAlt: The target periapsis for reentry
PARAMETER ReEntryAlt IS 27000.
// ChuteAlt: The altitude at which to deploy the chutes
PARAMETER ChuteAlt IS 500.

RUNPATH("0:/modules/GravityTurn.ks"). // loads the GravityTurn-function
RUNPATH("0:/modules/GetPartModules.ks"). // loads the GetPartModules-function
RUNPATH("0:/modules/RunPartModuleEvent.ks"). // loads the RunPartModuleEvent-function
RUNPATH("0:/modules/GetSolidFuel.ks"). // loads the GetSolidFuel-function
RUNPATH("0:/modules/GetAllFuel.ks"). // loads the GetAllFuel-function

// Pick a random direction to launch towards.
SET TargetDirection TO ROUND(RANDOM() * 360).

// Launch
STAGE.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

PRINT "Starting gravity turn".
LOCK STEERING TO GravityTurn(TargetDirection, TargetOrbit, GravityTurnRatio).

SET solidFuel TO GetSolidFuel().

LOCK THROTTLE TO 0.
UNTIL solidFuel:CAPACITY = 0 { // run until we reach a stage whith no solid fuel boosters.
	PRINT "Next booster stage initiated".
	WAIT UNTIL solidFuel:AMOUNT < 0.0053. // wait until the current boosters are dry(ish)
	PRINT "Solid fuel empty".

	STAGE. // Separate
	WAIT BoosterWaitPeriod.
	STAGE. // Activate the next stage
}

PRINT "Solid fuel stages expended".
WAIT BoosterWaitPeriod * 2.

// Continue burning until the target apoapsis is achieved
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:APOAPSIS >= TargetOrbit.
LOCK THROTTLE TO 0.

LOCK STEERING TO SHIP:PROGRADE.
WAIT BoosterWaitPeriod.

// Wait for apoapsis
PRINT "Waiting for apoapsis".
IF(ETA:APOAPSIS > 60) {
	// Or don't.
	WAIT UNTIL SHIP:ALTITUDE > 70000.
	SET exitPoint TO ETA:APOAPSIS - (CircBurnBuffer + 10).
	kuniverse:timewarp:warpto(time:seconds + exitPoint).
}

WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.
PRINT "Starting circularization burn".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS >= TargetOrbit OR GetAllFuel() = 0.
PRINT "Orbit achieved!".
LOCK THROTTLE TO 0.

PRINT "Flipping!".
LOCK STEERING TO SHIP:RETROGRADE.
WAIT FlipWait.

PRINT "Starting re-entry burn".
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:PERIAPSIS <= ReEntryAlt OR GetAllFuel() = 0.
LOCK THROTTLE TO 0.

PRINT "Setting up scenic view until reentry".
LOCK STEERING TO HEADING(TargetDirection,-45).
WAIT UNTIL (SHIP:ALTITUDE < 60000 AND SHIP:VERTICALSPEED < 0).

PRINT "Re-entry initiating".
LOCK STEERING TO SHIP:SRFRETROGRADE.
WAIT FlipWait.

LOCK THROTTLE TO 1.
WAIT UNTIL GetAllFuel() = 0.
LOCK STEERING TO SHIP:UP.
WAIT FlipWait / 2.
STAGE. // Separate engine.
WAIT BoosterWaitPeriod.
LOCK STEERING TO SHIP:SRFRETROGRADE.

// 530m/s: safe for drag chutes?
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 530.
STAGE. // Deploy drag chutes

WAIT UNTIL ALT:RADAR < ChuteAlt.
STAGE. // Deploy normal chutes
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 10.
LOCK STEERING TO SHIP:UP.
GEAR ON.
WAIT UNTIL SHIP:VERTICALSPEED > -1.

// Run onboard experiments!
RunPartModuleEvent("science.module", "ModuleScienceExperiment", "observe materials bay").
RunPartModuleEvent("GooExperiment", "ModuleScienceExperiment", "observe mystery goo").
RunPartModuleEvent("sensorBarometer", "ModuleScienceExperiment", "log pressure data").
RunPartModuleEvent("sensorThermometer", "ModuleScienceExperiment", "log temperature").

// Keep running for a bit before shutting down.
PRINT "Shutting down in 60s".
WAIT 60.
