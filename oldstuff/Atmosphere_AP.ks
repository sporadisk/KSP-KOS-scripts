// Very simple autopilot.
// Reads the current heading and altitude, and attempts to maintain them.
// This script probably wont't work if you don't attach the KOS module behind the cockpit, in the same orientation as the cockpit.
SET targetHeading TO 0.
SET targetPitch TO 0.
SET targetRoll TO 0.
SET currentHeading TO 0.

IF(SHIP:BEARING > 0)
	SET targetHeading TO ABS(SHIP:BEARING - 360).
ELSE
	SET targetHeading TO ABS(SHIP:BEARING).

SET targetAlt TO SHIP:ALTITUDE.

LOCK targetDir TO HEADING(targetHeading, targetPitch).

CLEARSCREEN.
PRINT "Autopilot engaged. Press Ctrl+C to stop.".
PRINT "Target heading: " + targetHeading.
PRINT "Target altitude:  " + ROUND(targetAlt) + "m above sealevel.".
PRINT "Current altitude: ".
PRINT "Tr: ".
PRINT "Cr: ".

SET AltMargin TO 20.
SET headingMargin TO 1.

UNTIL(0) // Loops forever. Stop the autopilot by using Ctrl+C
{
	SET verticalAdjustment TO 1.

	IF(SHIP:ALTITUDE > (targetAlt + AltMargin) AND SHIP:VERTICALSPEED > 0)
	{
		SET targetPitch TO targetPitch - 0.1.
	}
	ELSE IF(SHIP:ALTITUDE < (targetAlt - AltMargin) AND SHIP:VERTICALSPEED < 0)
	{
		SET targetPitch TO targetPitch + 0.1.
	}
	ELSE
	{
		SET targetPitch TO 0.
		SET verticalAdjustment TO 0.
	}

	PRINT targetDir AT (4,4).
	PRINT SHIP:FACING AT (4,5).

	SET relativeHeading TO (targetDir - SHIP:FACING).

	IF(ABS(relativeHeading:PITCH) > 1 OR ABS(relativeHeading:YAW) > 1 OR ABS(relativeHeading:ROLL) > 1)
	{
		LOCK STEERING TO targetDir.
		WAIT 0.1.
	}
	ELSE
	{
		UNLOCK STEERING.

		IF(verticalAdjustment)
			WAIT 0.1.
		ELSE
			WAIT 0.5.
	}


	PRINT ROUND(SHIP:ALTITUDE) + "m       " AT (18, 3).
}