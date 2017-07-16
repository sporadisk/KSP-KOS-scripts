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
COPY RandLaunch FROM 0.
COPY HeatShieldReentry FROM 0.

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Pick a random launch vector
RUN RandLaunch.

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
