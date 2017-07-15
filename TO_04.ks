// This script is made for tourism contracts where the contract objective
// is to achieve orbit.
// It takes off in a random direction, stages solid fuel boosters in the defined sequence,
// performing a gravity turn along the way to achieve an apoapsis of 80km.
// It then uses liquid fuel engine(s) until it reaches orbit,
// then immediately performs a retrograde burn - 
// aiming to hit the atmosphere at a 25km periapsis for a safe'ish descent.
//
// Parts you'll need:
// - Reaction wheel or RCS thrusters
// - Solid fuel boosters with enough DV to reach 80km
// - Liquid fuel engine with enough fuel to reach orbit - and some left over for reentry
// - Batteries for the KOS unit and reaction wheel(s)
// - Heat shield for reentry
// 
// ---- Start Config ----
// This is a list of boosters that need to be staged after flameout
// You can give each booster a tag via the editor, which allows this script to easily identify them.
// Make sure to put them in the same order as they are staged.
SET boosters TO LIST("Stage9_Booster", "Stage7_Booster", "Stage5_Booster").
// NB: This script always assumes that your separators are in a separate stage - as such it will stage twice per booster
// (once to decouple, then once to activate the next booster)

// Defines the amount of seconds to wait for the ship to realign for a retrograde burn
SET RetroFlipWait TO 10.

// Set the amount of time to wait for boosters to drop away between stages
SET BoosterWaitPeriod TO 2.

// Drop the LF engine after boost(s) are complete? (probably always a good idea)
SET DropLFengine TO true.

// ---- End Config ----

// Copy scripts
COPY GravityTurn_mk2 FROM 0.
COPY HeatShieldReentry FROM 0.

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Start gravity turn
SET TargetDirection TO ROUND(RANDOM() * 360).
RUN GravityTurn_mk2.

FOR boosterTag IN boosters {
	SET booster TO SHIP:PARTSTAGGED(boosterTag)[0].
	WAIT UNTIL booster:FLAMEOUT.
	STAGE. // Separate
	WAIT BoosterWaitPeriod.
	STAGE. // Activate next stage (Either booster or liquid fuel)
}

// LF engine time!
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:PERIAPSIS >= 70000.
LOCK THROTTLE TO 0.

// Go down again immediately - probably not enough battery power for long trips
LOCK STEERING TO SHIP:RETROGRADE.
WAIT 10. // 
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:PERIAPSIS <= 25000.

LOCK THROTTLE TO 0.

IF DropLFengine {
	WAIT RetroFlipWait.
	STAGE.
}

RUN HeatShieldReentry.
