// Autopilot that leaps out of the atmosphere and coasts in vacuum
// No idea if it saves fuel. I do it because it looks cool.
// Reads the current heading and altitude, and attempts to maintain them.
// This script probably wont't work if you don't attach the KOS module behind the cockpit, in the same orientation as the cockpit.

// config:
// Adjust these according to your aircraft's limits and capabilities.
SET startBoostAlt TO 10000. // boost upwards again as soon as you're below this altitude.
SET stopBoostAlt TO 20000. // Shutdown engines at this point.
SET enableEnginesAlt TO 13000. // Start engines again on this altitude.
SET jumpPitch TO 45. // target pitch above horizon
SET descentPitch TO -10. // target pitch while descending.
SET maxBoostVel TO 2500. // set this to a speed well below the speed where your aircraft gets torn apart by air resistance.
SET targetAlt TO 4000. // Set this to 0 if you want the aircraft to maintain altitude from the moment you start the script.
SET maxPitchControl TO 0.3. // defines the maximum pitch allowed for the autopilot.
SET maxPitchAngle TO 3.

// end config.

SET targetHeading TO 0.
SET targetAscent TO 0.
SET targetRoll TO 0.
SET currentHeading TO 0.

IF(SHIP:BEARING > 0)
	SET targetHeading TO ABS(SHIP:BEARING - 360).
ELSE
	SET targetHeading TO ABS(SHIP:BEARING).

IF(NOT targetAlt)
	SET targetAlt TO SHIP:ALTITUDE.

LOCK targetDir TO HEADING(targetHeading, 0).

CLEARSCREEN.
PRINT "Autopilot engaged. Press Ctrl+C to stop.".
PRINT "Target heading:   " + targetHeading.
PRINT "Relative heading: ".
PRINT "Target altitude:  " + ROUND(targetAlt) + "m above sealevel.".
PRINT "Current altitude: ".
PRINT "Mach: ".
PRINT "-----Debug:-----".
PRINT "ascentMiss: ".
PRINT "tgtAscent:  ".
PRINT "Ascent:     ".
PRINT "FlapPitch:  ".
PRINT "Angularvel: ".
PRINT "altDiff:    ".
PRINT "ttt:        ".
PRINT "Interval:   ".

SET AltMargin TO 20.
SET headingMargin TO 1.
SET neutralPitch TO 0.
SET ascentMiss TO 0.
SET pitchVal TO 0.
SET Interval TO 0.1.
SET lastTime TO TIME:SECONDS - 0.1.

UNTIL(0) // Loops forever. Stop the autopilot by using Ctrl+C
{
	SET Interval TO (Interval + (TIME:SECONDS - lastTime)) / 2.
	SET lastTime TO TIME:SECONDS.
	// Calculate the angle of ascent.
	SET lastAscAngle TO ascAngle.
	SET ascAngle TO ARCTAN(SHIP:VERTICALSPEED / SHIP:SURFACESPEED).
	SET ascDelta TO (ascAngle - lastAscAngle) / Interval.

	SET machVel TO ROUND(SHIP:AIRSPEED / 343).
	PRINT machVel + "             " AT (18,5).

	SET verticalAdjustment TO 1.

	SET altDiff TO (targetAlt - SHIP:ALTITUDE).

	IF(ABS(SHIP:VERTICALSPEED) > 0)
		SET timeToTarget TO altDiff / SHIP:VERTICALSPEED.
	ELSE
		SET timeToTarget TO 9000. // that's basically infinity, right? close enough, anyway.

	IF(altDiff < (-AltMargin)) // too high
	{
		IF(SHIP:VERTICALSPEED < 0 AND timeToTarget < 10 AND targetAscent < 0)
			SET targetAscent TO (targetAscent + 0.1). // Will be at the target altitude soon. reduce pitch.
		ELSE IF (SHIP:VERTICALSPEED > 0 OR timeToTarget > 30)
			SET targetAscent TO (targetAscent - 0.1).
	}
	ELSE IF(altDiff > AltMargin) // too low
	{
		IF(SHIP:VERTICALSPEED > 0 AND timeToTarget < 10 AND targetAscent > 0)
			SET targetAscent TO (targetAscent - 0.1). // Will be at the target altitude soon. reduce pitch.
		ELSE IF (SHIP:VERTICALSPEED < 0 OR timeToTarget > 30)
			SET targetAscent TO (targetAscent + 0.1).
	}
	ELSE // At the right altitude. Adjust until vertical speed is sufficiently low.
	{
		IF(SHIP:VERTICALSPEED > 0.5)
			SET targetAscent TO targetAscent -0.1.
		ELSE IF(SHIP:VERTICALSPEED < -0.5)
			SET targetAscent TO targetAscent +0.1.
	}

	IF(targetAscent < (-maxPitchAngle))
		SET targetAscent TO (-maxPitchAngle).
	ELSE IF(targetAscent > maxPitchAngle)
		SET targetAscent TO maxPitchAngle.

	IF(SHIP:BEARING > 0)
		SET currentHeading TO ABS(SHIP:BEARING - 360).
	ELSE
		SET currentHeading TO ABS(SHIP:BEARING).

	SET relativeCompassHeading TO targetHeading - currentHeading.
	IF(ABS(relativeCompassHeading) > 180)
	{
		IF(relativeCompassHeading > 0)
		{
			SET relativeCompassHeading TO 360 - relativeCompassHeading.
		}
		ELSE
		{
			SET relativeCompassHeading TO 360 + relativeCompassHeading.
		}
	}


	PRINT relativeCompassHeading AT (18,2).

	SET targetRoll TO 0.

	SET relativeHeading TO (targetDir - SHIP:FACING).

	//PRINT relativeHeading AT (4,8).

	IF(ABS(relativeCompassHeading)>1)
	{
		IF(ABS(relativeCompassHeading > 10))
			SET bankDegrees TO 10.
		ELSE
			SET bankDegrees TO 1.

		IF(relativeCompassHeading > 0)
			SET targetRoll TO bankDegrees.
		ELSE
			SET targetRoll TO (-bankDegrees).
	}

	SET rollVal TO 0.

	SET rollMiss TO (targetRoll - relativeHeading:ROLL).
	PRINT ascentMiss + "              " AT (12, 7).
	PRINT targetAscent + "              " AT (12, 8).
	IF(ABS(rollMiss) > 0.2)
	{
		IF(ABS(rollMiss) < 10)
			SET rollBy TO 0.01.
		ELSE
			SET rollBy TO 0.1.

		IF(rollMiss < 1)
			SET rollVal TO (-rollBy).
		ELSE
			SET rollVal TO rollBy.
	}

	SET ascentMiss TO (targetAscent - ascAngle).

	IF(ABS(ascentMiss) > 0.2)
	{
		IF(ABS(ascDelta) > 0)
			SET timeToAsc TO ascentMiss / ascDelta.
		ELSE
			SET timeToAsc TO 9000. // that's basically infinity, right? close enough, anyway.

		IF(ascentMiss > 0) // need to go up
		{
			IF(ascDelta > 0 AND timeToAsc < 10 AND ascentMiss < 1) // will reach target ascent rate soon. stabilize.
				SET pitchVal TO (pitchVal - 0.02).
			ELSE IF(ascDelta < 0 OR timeToAsc > 30)
				SET pitchVal TO (pitchVal + 0.01). // go up faster!
		}
		ELSE // need to go down
		{
			IF(ascDelta < 0 AND timeToAsc < 10 AND ascentMiss > -1) // will reach target descent rate soon.
				SET pitchVal TO (pitchVal + 0.02).
			ELSE IF(ascDelta > 0 OR timeToAsc > 30)
				SET pitchVal TO (pitchVal - 0.01). // go down faster
		}
	}
	ELSE IF(ABS(SHIP:VERTICALSPEED) > 5 AND ABS(pitchVal > 0))
	{
		IF(ABS(pitchVal) < 0.05)
			SET pitchVal TO 0.
		ELSE IF(pitchVal > 0)
			SET pitchVal TO (pitchVal - 0.02).
		ELSE
			SET pitchVal TO (pitchVal + 0.02).
	}

	PRINT ascAngle + "              " AT (12,9).
	PRINT SHIP:CONTROL:PITCH + "              " AT (12,10).
	PRINT SHIP:ANGULARVEL:PITCH + "              " AT (12,11).
	PRINT altDiff + "              " AT (12,12).
	PRINT timeToTarget + "              " AT (12,13).
	PRINT Interval + "                    " AT (12,14).

	SET SHIP:CONTROL:ROLL TO rollVal.
	SET SHIP:CONTROL:PITCH TO pitchVal.


	PRINT ROUND(SHIP:ALTITUDE) + "m           " AT (18, 4).

	WAIT 0.1.
}