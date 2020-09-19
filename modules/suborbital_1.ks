// made for KOS 1.2.0.0
// Run command:
// RUNPATH("0:/modules/orbit_1.ks", 90, 2, 2, 100000).
// This script is made for tourism contracts where the contract objective
// is to achieve sub-orbital flights.
// The script is built around the assumption that you will only ever
// need solid fuel boosters to get a sub-orbital trajectory.

// ---- Config ----

// TargetDirection: defines the compass direction in which you'd like to travel.
PARAMETER TargetDirection IS 90.

// Sets the amount of booster stages (counting only the boosters, not the separators between them.)
PARAMETER BoosterStageCount IS 2.

// GravityTurnFactor: A higher factor means you start the turn earlier.
PARAMETER GravityTurnFactor IS 2.

// TargetOrbit: How high of an orbit to achieve before returning
PARAMETER TargetOrbit IS 85000.

// ---- End Config ----

PRINT("BoosterStageCount: " + BoosterStageCount).
PRINT("TargetOrbit:       " + TargetOrbit).
PRINT("GravityTurnFactor: " + GravityTurnFactor).

// Copy scripts
RUNPATH("0:/modules/GetSolidFuel.ks"). // loads the getSolidFuel-function
RUNPATH("0:/modules/GravityTurn.ks"). // loads the GravityTurn-function

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Start gravity turn
PRINT "Starting gravity turn".
LOCK STEERING TO GravityTurn(TargetDirection, TargetOrbit, GravityTurnFactor).

// Manage booster stages:
// The following loop stages each solid booster stage as it runs dry
// It assumes your boosters and separators are in separate stages
SET solidFuel TO GetSolidFuel().
SET boosterStage TO 1.

UNTIL solidFuel:CAPACITY = 0 { // run until we reach a stage whith no solid fuel boosters.

	WAIT UNTIL solidFuel:AMOUNT = 0. // wait until the current boosters are dry

	IF(boosterStage < BoosterStageCount) { // this was not the final booster stage
		STAGE. // Separate
		PRINT("Booster stage #" + boosterStage + " separated").

		WAIT 1.

		STAGE. // Activate the next booster stage
	} ELSE {
		// Out of boosters: Coast toward apoapsis and prepare for reentry.
		PRINT("Coasting.").
		LOCK STEERING TO SHIP:PROGRADE. // Align with the booster's trajectory
		WAIT 5.
		STAGE. // Shed the last booster
	}
	
	SET solidFuel TO GetSolidFuel().

	SET boosterStage TO boosterStage + 1.
}

PRINT("Suborbital flight achieved.").
