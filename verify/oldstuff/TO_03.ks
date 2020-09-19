// Copy scripts
COPY GravityTurn FROM 0.
COPY HeatShieldReentry FROM 0.

// Launch
STAGE.
GEAR OFF.

// Wait until we've got some speed
WAIT UNTIL SHIP:VERTICALSPEED > 50.

// Start gravity turn
SET TargetDirection TO ROUND(RANDOM() * 360).
RUN GravityTurn.

SET s9booster TO SHIP:PARTSTAGGED("Stage9_Booster")[0].
SET s7booster TO SHIP:PARTSTAGGED("Stage7_Booster")[0].
SET s5booster TO SHIP:PARTSTAGGED("Stage5_Booster")[0].

WAIT UNTIL s9booster:FLAMEOUT.
STAGE.
WAIT 4.
STAGE.

WAIT UNTIL s7booster:FLAMEOUT.
STAGE.
WAIT 2.
STAGE.

WAIT UNTIL s5booster:FLAMEOUT.
STAGE.
WAIT 2.
STAGE.

LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS >= 70000.

LOCK THROTTLE TO 0.

// Go down again immediately - not enough battery power for long trips
LOCK STEERING TO SHIP:RETROGRADE.
WAIT 10.
LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:PERIAPSIS <= 25000.

LOCK THROTTLE TO 0.

WAIT 2.
STAGE.

RUN HeatShieldReentry.
