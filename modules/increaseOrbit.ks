// made for KOS 1.2.0.0
// Usage example:
// RUNPATH("0:/modules/increaseOrbit.ks", 100000, 350000, 10).
// StageOrbit: The altitude of the intermediate orbit to use as stepping stone to the higher orbit
PARAMETER StageOrbit IS 70000.

// TargetOrbit: The altitude of the final orbit
PARAMETER TargetOrbit IS 80000.

// CircBurnBuffer: How soon before apoapsis to start circularization burn.
PARAMETER CircBurnBuffer IS 10.

LOCK STEERING TO SHIP:PROGRADE. // Keep on trucking on

WAIT 5.

PRINT "Burning to achieve apoapsis".

LOCK THROTTLE TO 1.
WAIT UNTIL SHIP:APOAPSIS >= (StageOrbit + 5000). // allow for some altitude loss to friction
LOCK THROTTLE TO 0.

IF(ETA:APOAPSIS > 60) { // Timewarp until we're approaching apoapsis
	PRINT "Timewarping to apoapsis".
	WAIT UNTIL SHIP:ALTITUDE > 70000.
	WAIT 4.
	SET exitPoint TO ETA:APOAPSIS - (CircBurnBuffer + 15).
	kuniverse:timewarp:warpto(time:seconds + exitPoint).
}

WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.

PRINT "Starting stage orbit burn".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:PERIAPSIS >= StageOrbit OR SHIP:APOAPSIS > (TargetOrbit - 5000).
PRINT "Stage orbit achieved!".
LOCK THROTTLE TO 0.

LOCK STEERING TO SHIP:PROGRADE.

// We're in orbit - next step: Reach higher orbit
IF(SHIP:APOAPSIS < TargetOrbit) {
	LOCK THROTTLE TO 1.
	WAIT UNTIL SHIP:APOAPSIS >= TargetOrbit.
	LOCK THROTTLE TO 0.
}
PRINT "Target apoapsis achieved!".

// Repeat the process for periapsis
IF(SHIP:PERIAPSIS < TargetOrbit) {
	PRINT "Timewarping to apoapsis".
	IF(ETA:APOAPSIS > 60) { // timewarp to apoapsis
		WAIT 2.
		SET exitPoint TO ETA:APOAPSIS - (CircBurnBuffer + 15).
		kuniverse:timewarp:warpto(time:seconds + exitPoint).
	}
	WAIT UNTIL ETA:APOAPSIS <= CircBurnBuffer.

	// Burn until we're there
	LOCK THROTTLE TO 1.
	WAIT UNTIL SHIP:PERIAPSIS >= TargetOrbit.
	LOCK THROTTLE TO 0.
}
PRINT "Target periapsis achieved!".
