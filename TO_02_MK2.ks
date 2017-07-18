// This script is made for tourism contracts where the contract objective
// is to achieve sub-orbital flights.

// ---- Config ----
// A list of solid fuel boosters to auto-stage
// You can give each booster a tag via the editor, which allows this script to easily identify them.
SET boosters TO LIST("Stage4_Booster", "Stage2_Booster").

// Sets the number of seconds to wait for boosters to drop away between stages
SET BoosterWaitPeriod TO 2.

// ---- End Config ----

// Copy scripts
COPYPATH("0:/RandLaunch.ks", "1:").
COPYPATH("0:/HeatShieldReentry.ks", "1:").

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Pick a random launch vector
RUN RandLaunch.

// Todo: Convert to use STAGE:RESOURCES and / or part:STAGE
// https://ksp-kos.github.io/KOS/structures/vessels/aggregateresource.html
// https://ksp-kos.github.io/KOS/structures/vessels/part.html
FOR boosterTag IN boosters {
	SET booster TO SHIP:PARTSTAGGED(boosterTag)[0].
	WAIT UNTIL booster:FLAMEOUT.
	STAGE. // Separate
	WAIT BoosterWaitPeriod.
	STAGE. // Activate the next booster stage (or arms parachutes, if this was the last stage)
}

WAIT 5.
LOCK STEERING TO SHIP:PROGRADE.

WAIT UNTIL (SHIP:ALTITUDE < 70000 AND SHIP:VERTICALSPEED < 0). // wait for reentry.
RUN HeatShieldReentry.
