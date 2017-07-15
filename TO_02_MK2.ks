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

// Set up listeners for the solid fuel boosters.
SET solidFuel1 TO SHIP:PARTSTAGGED("Stage4_Booster")[0].
SET solidFuel2 TO SHIP:PARTSTAGGED("Stage2_Booster")[0].

WAIT UNTIL solidFuel1:FLAMEOUT.
STAGE. // Ditch the radial boosters
WAIT 2. // Wait a bit, to avoid burning the boosters
STAGE. // Fire central booster

WAIT UNTIL solidFuel2:FLAMEOUT.
WAIT 2.
STAGE. // Ditch booster.

WAIT 5.
LOCK STEERING TO SHIP:PROGRADE.

WAIT UNTIL (SHIP:ALTITUDE < 70000 AND SHIP:VERTICALSPEED < 0). // wait for reentry.
RUN HeatShieldReentry.
