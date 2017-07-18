SET SurfaceGravity TO 9.81.

LOCK R TO (-1) * SHIP:VELOCITY:SURFACE. // surface retrograde
LOCK STEERING TO R.

SET T TO 0.
LOCK THROTTLE TO T.

IF(ALT:RADAR > 10) {
	WAIT UNTIL VERTICALSPEED < 0.
	LOCK RetroAngle TO (SHIP:FACING - R).
	WAIT UNTIL (ABS(RetroAngle:YAW) < 2 AND ABS(RetroAngle:PITCH) < 2).
}

LOCK UpAngle TO (SHIP:FACING - UP).
// event fires every time "PointingUp" changes state
WHEN (ABS(UpAngle:YAW) < 1 AND ABS(UpAngle:PITCH) < 1) THEN {
	LOCK STEERING TO UP.
}

LOCK THROTTLE TO ((SurfaceGravity * SHIP:MASS) / SHIP:MAXTHRUST) * 0.5.
WAIT 100.