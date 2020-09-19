// works on KOS 1.2.0.0
// This script assumes that the heat shield is mounted on the rear of the ship,
// and that your ship has one stage left at this point, dedicated to deploying chutes
// TargetSpeed: The speed at which we're reasonably certain that all chutes have been deployed
PARAMETER TargetSpeed IS 20.
// ChuteSpeed: The speed at which the main chutes are deployed
// (via staging, because the chute commands don't seem to work properly)
PARAMETER ChuteSpeed IS 200.

LOCK STEERING TO SHIP:SRFRETROGRADE.

// Deploy chutes once we've reached chute speed
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < ChuteSpeed.
CHUTES ON.

// wait until chutes have slowed us down, then deploy gear
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < TargetSpeed.
GEAR ON.
UNLOCK STEERING.
