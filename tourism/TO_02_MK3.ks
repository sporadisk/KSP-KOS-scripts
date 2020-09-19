// made for KOS 1.2.0.0
// Run command:
// RUNPATH("0:/tourism/TO_02_MK3.ks", 2, 3, 85000, 300, 1).
// RUNPATH("0:/tourism/TO_02_MK3.ks", 2, 1, 85000, 300, 0).
// This script is made for tourism contracts where the contract objective
// is to achieve sub-orbital flights.
// The script is built around the assumption that you will only ever need solid boosters to get a sub-orbital trajectory.

// ---- Config ----

// Sets the amount of booster stages (counting only the boosters, not the separators between them.)
PARAMETER BoosterStageCount IS 2.

// GravityTurnFactor: A higher factor means you start the turn earlier.
PARAMETER GravityTurnFactor IS 2.

// TargetOrbit: How high of an orbit to achieve before returning
PARAMETER TargetOrbit IS 85000.

// ChuteDeploySpeed: The maximum speed at which chutes can be deployed
PARAMETER ChuteDeploySpeed IS 300.

// DoScience: If set to 1, the script will trigger Action Group 1 upon landing.
PARAMETER DoScience IS 0.

// ---- End Config ----

IF DoScience = 1 {
	PRINT("Will perform experiments via action group 1 after landing.").
}

COPYPATH("0:/modules/suborbital_1.ks", "1:").

SET TargetDirection TO ROUND(RANDOM() * 360).

RUN "suborbital_1"(TargetDirection, BoosterStageCount, GravityTurnFactor, TargetOrbit).

WAIT UNTIL (SHIP:ALTITUDE < 85000 AND SHIP:VERTICALSPEED < 0). // have reached the outer atmosphere again: Reentry is imminent.
PRINT("Reentry initiated").

LOCK STEERING TO SHIP:SRFRETROGRADE.

// Deploy chutes once we've reached chute speed
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < ChuteDeploySpeed.
PRINT("Deploying chutes").
STAGE.

// wait until chutes have slowed us down, then deploy gear
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 20.
GEAR ON.

LOCK STEERING TO SHIP:UP.
WAIT UNTIL SHIP:VERTICALSPEED > -1.

IF DoScience = 1 { // Run onboard experiments!
	AG1 ON.
}

// Keep running for a bit before shutting down.
PRINT "Shutting down in 60s".
WAIT 60.
