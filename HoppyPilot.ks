// Autopilot that tries to maintain heading while keeping your aircraft at a certain altitude.
// This script probably wont't work if you don't attach the KOS module behind the cockpit, in the same orientation as the cockpit.

// config:
// Adjust these according to your aircraft's limits and capabilities.
//SET targetAlt TO 2000. // Set this to 0 if you want the aircraft to maintain altitude from the moment you start the script.
SET targetAlt TO 10000. // Set this to 0 if you want the aircraft to maintain altitude from the moment you start the script.
SET maxPitchAngleLevel TO 4.
SET maxPitchAngleClimbing TO 10.
SET rollForce TO 0.005. // how hard the autopilot should roll
SET yawForce TO 0.002.
SET maxRollRate TO 3. // degrees per second
SET targetHeading TO 0.

// end config.

SET targetAscent TO 0.
SET targetRoll TO 0.
SET currentHeading TO 0.

IF(targetHeading = 0)
{
	IF(SHIP:BEARING > 0)
		SET targetHeading TO ABS(SHIP:BEARING - 360).
	ELSE
		SET targetHeading TO ABS(SHIP:BEARING).
}

IF(NOT targetAlt)
	SET targetAlt TO SHIP:ALTITUDE.

LOCK targetDir TO HEADING(targetHeading, 0).

CLEARSCREEN.
PRINT "HoppyPilot has control. Enable SAS to stop.".
PRINT "Target heading:   " + targetHeading.
PRINT "Relative heading".
PRINT "Target altitude:  " + ROUND(targetAlt) + "m above sealevel.".
PRINT "Current altitude:".
PRINT "Mach:".
PRINT "-----Debug:-----".

SET AltMargin TO 20.
SET headingMargin TO 1.
SET neutralPitch TO 0.
SET ascentMiss TO 0.
SET pitchVal TO 0.
SET Interval TO 0.1.
SET lastTime TO TIME:SECONDS - 0.1.
SET ascAngle TO ARCTAN(SHIP:VERTICALSPEED / SHIP:SURFACESPEED).
SET rollBy TO 0.
SET bankAngle TO 99999.
set pitchAngle TO 99999.
SET templateRollVal TO rollForce.
SET rollVal TO 0.
SET targetRollRate TO 0.
SET yawVal TO 0.
SET reversingRoll TO 0.
SET counterRoll TO 0.

IF(SAS)
{
	SET pitchVal TO SHIP:CONTROL:PITCH. // adopt the pitch value from the SAS
	SAS OFF. // Allows for a direct and smooth transition from SAS to autopilot.
}

UNTIL(0) // Loops forever. Stop the autopilot by using Ctrl+C or re-enabling SAS.
{
	IF(SAS)
	{
		CLEARSCREEN.
		PRINT "SAS enabled: Shutting down autopilot.".
		BREAK.
	}
	// calculate bank angle
	SET lastBankAngle TO bankAngle.
	SET starboardRotation TO SHIP:FACING * R(0,90,0).
	SET starVec to starboardRotation:VECTOR.
	SET currentUpVec to SHIP:UP:VECTOR.
	SET bankAngle TO ((VANG(starVec,currentUpVec)) - 90).
	IF(lastBankAngle = 99999)
		SET lastBankAngle TO bankAngle.

	// calculate pitch angle
	SET lastPitchAngle TO pitchAngle.
	SET forwardVec to SHIP:FACING:VECTOR.
	SET pitchAngle TO ((VANG(forwardVec,currentUpVec)) - 90).
	IF(lastPitchAngle = 99999)
		SET lastPitchAngle TO pitchAngle.

	SET Interval TO (Interval + (TIME:SECONDS - lastTime)) / 2.
	SET lastTime TO TIME:SECONDS.
	// Calculate the angle of ascent.
	SET lastAscAngle TO ascAngle.
	SET ascAngle TO ARCTAN(SHIP:VERTICALSPEED / SHIP:SURFACESPEED).
	SET ascDelta TO (ascAngle - lastAscAngle) / Interval.

	SET machVel TO ROUND(SHIP:AIRSPEED / 343).

	SET verticalAdjustment TO 1.

	SET altDiff TO (targetAlt - SHIP:ALTITUDE).
	
	IF(altDiff > 8000)
		{ SET maxPitchAngle TO maxPitchAngleClimbing. }
	ELSE
		{ SET maxPitchAngle TO maxPitchAngleLevel. }

	IF(ABS(SHIP:VERTICALSPEED) > 0)
		SET timeToTarget TO altDiff / SHIP:VERTICALSPEED.
	ELSE
		SET timeToTarget TO 9000. // that's basically infinity, right? close enough, anyway.

	IF(altDiff < (-AltMargin)) // too high
	{
		IF(SHIP:VERTICALSPEED < 0 AND timeToTarget < 10 AND targetAscent < 0)
			SET targetAscent TO (targetAscent + 0.2). // Will be at the target altitude soon. reduce pitch.
		ELSE IF (SHIP:VERTICALSPEED > 0 OR timeToTarget > 30)
			SET targetAscent TO (targetAscent - 0.1).
	}
	ELSE IF(altDiff > AltMargin) // too low
	{
		IF(SHIP:VERTICALSPEED > 0 AND timeToTarget < 10 AND targetAscent > 0)
			SET targetAscent TO (targetAscent - 0.01). // Will be at the target altitude soon. reduce pitch.
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

	SET lastHeading TO currentHeading.

	IF(SHIP:BEARING > 0)
		SET currentHeading TO ABS(SHIP:BEARING - 360).
	ELSE
		SET currentHeading TO ABS(SHIP:BEARING).

	SET deltaHeading TO currentHeading - lastHeading.

	SET relativeCompassHeading TO currentHeading - targetHeading.
	SET rch_raw TO relativeCompassHeading.
	IF(ABS(relativeCompassHeading) > 180)
	{
		IF(relativeCompassHeading > 0)
		{
			SET relativeCompassHeading TO relativeCompassHeading - 360.
		}
		ELSE
		{
			SET relativeCompassHeading TO 360 + relativeCompassHeading.
		}
	}

	SET targetYaw TO 0.

	// positive bank angle = banking right
	// positive relative compass heading = target heading is to the left
	SET bankDegrees TO ABS(relativeCompassHeading * 3).
	IF(bankDegrees > 30)
		SET bankDegrees TO 30.

	IF(relativeCompassHeading < 0) // need to bank right
		SET targetRoll TO bankDegrees.
	ELSE
		SET targetRoll TO (-bankDegrees).

	IF(yawVal > 0.01)
		SET yawVal TO (yawVal / 2).
	ELSE SET yawVal TO 0.

	IF(ABS(relativeCompassHeading) < 8)
	{
		IF(relativeCompassHeading < 0) // need to bank right
			SET targetYaw TO 1.
		ELSE
			SET targetYaw TO -1.

		IF((targetYaw < 0 AND deltaHeading < 0) OR (targetYaw < 0 AND deltaHeading < 0) AND ABS(yawVal) > (yawForce * 2))
		{
			// going the right way
			SET lastYawVal TO yawVal.
			SET yawVal TO yawVal * (deltaHeading / targetYaw).
		}
		ELSE
		{
			IF(targetYaw > 0)
				SET yawVal TO yawVal + (yawForce).
			ELSE
				SET yawVal TO yawVal - (yawForce).
		}

		IF(yawVal > 1)
			SET yawVal TO 1.
		ELSEIF(yawVal < -1)
			SET yawVal TO -1.
	}

	IF(ABS(targetRoll) > 0 AND targetAscent < 0 AND altDiff > 1000)
		SET targetRoll TO 0. // no point banking when you're going down.

	// Using roll data and input data, find the best input for a slow roll
	SET currentRollRate TO (bankAngle - lastBankAngle) / Interval.
	IF((currentRollRate > 0 AND targetRollRate > 0) OR (currentRollRate < 0 AND targetRollRate < 0))
	{
		// going the right way
		IF(ABS(currentRollRate) > ABS(targetRollRate))
		{
			// going too fast
			IF(templateRollVal > 0.01 AND NOT counterRoll)
				SET templateRollVal TO templateRollVal * (ABS(targetRollRate) / ABS(currentRollRate)).
			ELSE
			{
				IF(NOT counterRoll)
					SET counterRollVal TO templateRollVal. // first iteration of counter roll

				SET counterRoll TO 1. // We have roll momentum with Need to counter it.
				SET counterRollVal TO counterRollVal + (rollForce).
			}
		}
		ELSEIF(ABS(currentRollRate) < ABS(targetRollRate * 0.8))
		{
			// going too slow
			SET templateRollVal TO templateRollVal + rollForce.
			SET counterRoll TO 0.
		}

		SET reversingRoll TO 0.
	}
	ELSE
	{
		// going the wrong way
		IF(NOT reversingRoll AND NOT counterRoll)
			SET counterRollVal TO templateRollVal. // first iteration of reverse roll

		SET counterRollVal TO counterRollVal + (rollForce).
		SET counterRoll TO 0.
		SET reversingRoll TO 1.
	}

	SET rollMiss TO (targetRoll - bankAngle).
	SET targetRollRate TO 0.

	IF(ABS(rollMiss) > 0.2)
	{
		SET rollBy TO ABS(rollMiss / 3).

		IF(rollBy > maxRollRate)
			SET rollBy TO maxRollRate.
		IF(rollBy < 1)
			SET rollBy TO 1.

		IF(rollMiss < 0)
			SET targetRollRate TO (-rollBy).
		ELSE
			SET targetRollRate TO rollBy.
	}
	ELSE
		SET targetRollRate TO 0.

	IF(counterRoll OR reversingRoll)
	{
		IF((reversingRoll AND rollMiss < 0) OR (counterRoll AND rollMiss > 0))
			SET rollVal TO -counterRollVal.
		ELSE
			SET rollVal TO counterRollVal.
	}
	ELSE
	{
		SET rollVal TO targetRollRate * templateRollVal.
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
				SET pitchVal TO (pitchVal - 0.01).
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
		IF(pitchVal > 0)
			SET pitchVal TO (pitchVal - 0.02).
		ELSE
			SET pitchVal TO (pitchVal + 0.02).
	}

	PRINT "Relative heading: " + relativeCompassHeading + "  " AT (0,2).
	PRINT "Current altitude: " + ROUND(SHIP:ALTITUDE) + "m           " AT (0, 4).
	PRINT "Mach:             " + machVel + "             " AT (0,5).
	// debuig data here:
	PRINT "Interval:   " + Interval + "                    " AT (0,14).
	PRINT "pitchAngle: " + pitchAngle  + "                    " AT (0,19).
	PRINT "rch_raw:    " + rch_raw  + "                    " AT (0,20).
	PRINT "targetRoll: " + targetRoll  + "                    " AT (0,21).
	PRINT "bankAngle:  " + bankAngle  + "                    " AT (0,22).
	PRINT "bearing:    " + SHIP:BEARING  + "                    " AT (0,23).
	PRINT "Interval:   " + Interval  + "                    " AT (0,24).
	PRINT "rollRate:   " + currentRollRate  + "                    " AT (0,24).

	SET SHIP:CONTROL:ROLL TO rollVal.
	SET SHIP:CONTROL:PITCH TO pitchVal.
	SET SHIP:CONTROL:YAW TO yawVal.

	WAIT 0.1.
}