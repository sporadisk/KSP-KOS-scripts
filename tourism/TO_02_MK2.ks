// Run command:
// RUNPATH("0:/tourism/TO_02_MK2.ks").
// This script is made for tourism contracts where the contract objective
// is to achieve sub-orbital flights.
// The script is built around the assumption that you will only ever need solid boosters to get a sub-orbital trajectory.

// ---- Config ----
// Sets the amount of booster stages (counting only the boosters, not the separators between them.)
SET BoosterStageCount TO 2.
// Sets the number of seconds to wait for boosters to drop away between stages
SET BoosterWaitPeriod TO 2.
// ---- End Config ----

// Copy scripts
COPYPATH("0:/modules/RandLaunch.ks", "1:").
COPYPATH("0:/modules/HeatShieldReentry.ks", "1:").
RUNPATH("0:/modules/GetSolidFuel.ks"). // loads the getSolidFuel-function

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Pick a random launch vector
RUN RandLaunch.

// The following loop stages each solid booster stage as it runs dry
SET solidFuel TO GetSolidFuel().
SET boosterStage TO 1.

UNTIL solidFuel:CAPACITY = 0 { // run until we reach a stage whith no solid fuel boosters.

	WAIT UNTIL solidFuel:AMOUNT = 0. // wait until the current boosters are dry

	STAGE. // Separate
	PRINT("Booster stage #" + boosterStage + " separated").

	WAIT BoosterWaitPeriod.

	IF(boosterStage < BoosterStageCount) { // this was not the final booster stage
		STAGE. // Activate the next booster stage
	}
	
	SET solidFuel TO GetSolidFuel().

	SET boosterStage TO boosterStage + 1.
}

PRINT("No boosters remaining!").

// Done with boosters: Coast toward apoapsis and prepare for reentry.
WAIT 5.
LOCK STEERING TO SHIP:PROGRADE.

WAIT UNTIL (SHIP:ALTITUDE < 70000 AND SHIP:VERTICALSPEED < 0). // have reached the outer atmosphere again: Reentry is imminent.
PRINT("Reentry initiated").
RUN HeatShieldReentry.
