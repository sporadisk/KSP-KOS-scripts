// --Config--

// Surface gravity of the target you wish to land on. If you overestimate this, you will never land.
// Calculation: Surface gravity = Gravitational constant * (object mass (kg) / object radius (km) ^ 2)
// (Gravitational constant: 6.67E-11 )
// Kerbin: 9.81
// Mun: 1.62748
SET SurfaceGravity TO 9.81.

SET HasAtmosphere TO 1.
SET AtmosphereEntryAltitude TO 35000.
SET AtmosphereEntryVelocity TO 2000.

SET TouchDownVelocity TO 0.5.

// Need to know the vessel's height to accurately calculate touchdown.
// To get the vessel's height, run PRINT ALT:RADAR while the lander module sits on the launchpad, with landing struts deployed.
SET ShipHeight TO 2.515265.

// Thrust Increment: More means more violent thrust usage. 0.02 = Up to 20% thrust change per second. (given a loop interval of 0.1)
SET ThrustIncrement TO 0.05.

// The time to wait between each calculation run in the main loop
SET loopInterval TO 0.05.

// Landing margin (meters): Prevents the craft from avoiding the ground.
SET landingMargin TO 0.5.

// --End Config--

// --Init--
LOCK LandingGearAltitude TO (ALT:RADAR - ShipHeight).
LOCK MaxDeceleration TO (SHIP:MAXTHRUST / SHIP:MASS).
LOCK V TO VELOCITY:SURFACE:MAG.

IF(HasAtmosphere AND ALT:RADAR > AtmosphereEntryAltitude)
{
	PRINT "Atmosphere Entry Mode initiated.".
	SET targetAltitude TO AtmosphereEntryAltitude.
	SET targetVelocity TO AtmosphereEntryVelocity.
	SET entryMode TO 1.
}
ELSE
{
	PRINT "Going straight to dive mode.".
	SET targetAltitude TO 0.5.
	SET targetVelocity TO TouchDownVelocity.
	SET entryMode TO 0.
}

SET targetThrottle TO 0.
SET LandingMode TO 0.
SET angleMod TO 1.

	
// Calculate required percentage of thrust in order to land smoothly
LOCK landingThrust TO ((SurfaceGravity * SHIP:MASS) / SHIP:MAXTHRUST) * 0.5.

// --End Init--

SET T TO 0.
LOCK THROTTLE TO T.


LOCK R TO (-1) * SHIP:VELOCITY:SURFACE. // surface retrograde
LOCK STEERING TO R.

WAIT UNTIL VERTICALSPEED < 0.
LOCK RetroAngle TO (SHIP:FACING - R).
WAIT UNTIL (ABS(RetroAngle:YAW) < 2 AND ABS(RetroAngle:PITCH) < 2).


SET targetSpeed TO 0.
SET LastTargetSpeed TO 0.
SET lastSetting TO 0.

// successfully rotated towards retrograde.
// now setup a listener for the point where most
// or all of the horizontal momentum has been depleted
LOCK UpAngle TO (SHIP:FACING - UP).
// event fires every time "PointingUp" changes state
WHEN (ABS(UpAngle:YAW) < 1 AND ABS(UpAngle:PITCH) < 1) THEN {
	LOCK STEERING TO UP.
}


Lock AbsVert TO ABS(VERTICALSPEED).

UNTIL (LandingGearAltitude < landingMargin AND VERTICALSPEED > -0.1)
{
		// use max deceleration to figure out at what altitudes to start burning.
	// start at an altitude at which 75% of max thrust for the duration of the remaining descent
	// will stop the descent at about 100 meters.
	// burnAltitude = current_velocity^2 / (max_deceleration * 0.75).
	// calculate time it will take to decelerate to the target velocity from the current velocity, with safety margin.
	IF(V <> 0) { SET angleMod TO ABS(VERTICALSPEED / V). }

	SET progradeDeceleration TO (0.75 * MaxDeceleration).
	SET verticalDeceleration TO progradeDeceleration * angleMod.

	SET decelTime TO (V - targetVelocity) / (progradeDeceleration - (SurfaceGravity * angleMod)).

	// calculate the vertical distance travelled during that time, taking gravity into account.
	SET velocityIntegralDecel TO (SurfaceGravity - verticalDeceleration) * (0.5 * decelTime * decelTime).
	SET decelAltitude TO (AbsVert * decelTime) + velocityIntegralDecel.

	// now we know the altitude at which it would be wise to initiate a burn.
	SET burnAltitude TO targetAltitude + decelAltitude.

	IF(LandingMode)
		{ SET landingThrust TO (SurfaceGravity / (SHIP:MAXTHRUST / SHIP:MASS)) * 0.5. }

	IF(VERTICALSPEED < 0 AND (LandingMode OR LandingGearAltitude < burnAltitude))
	{
		// Then continually burn at an optimal deceleration plan.
		// Pick the throttle setting that barely gets you down safely.

		IF(V <> 0 AND SHIP:MAXTHRUST <> 0)
		{
			SET targetThrottle TO 2.
			SET tSetting TO 1.

			UNTIL (tSetting <= 0 OR targetThrottle < 2)
			{
				SET progradeDeceleration TO (tSetting * MaxDeceleration).
				SET verticalDeceleration TO progradeDeceleration * angleMod.
				SET decelTime TO (V - targetVelocity) / (progradeDeceleration - (SurfaceGravity * angleMod)).

				SET velocityIntegralDecel TO (SurfaceGravity - verticalDeceleration) * (0.5 * decelTime * decelTime).
				
				IF(decelTime > 0)
				{
					SET decelAltitude TO (AbsVert * decelTime) + velocityIntegralDecel. // decreases gradually.

					IF((targetAltitude + decelAltitude) > LandingGearAltitude) // found the minimum setting.
					{
						SET targetThrottle TO lastSetting.
						BREAK.
					}
				}
				SET lastSetting TO tSetting.
				SET lastDecelTime TO decelTime.

				SET tSetting TO (tSetting - 0.01).
			}

			IF(targetThrottle = 2)
				{ SET targetThrottle TO (landingThrust / 2). }

			SET decelTime TO lastDecelTime.
		}

		IF(ALT:RADAR < 500 AND targetThrottle > 0 AND decelTime < 5 AND NOT entryMode AND NOT LandingMode)
		{
			PRINT "Landing Mode initiated.".
			SET LandingMode TO 1.
			LEGS ON.
		}
	}
	ELSE // going up
	{
		SET targetThrottle TO 0.
	}

	IF(LandingGearAltitude < landingMargin)
		{ SET targetThrottle TO landingThrust. }

	IF ABS(targetThrottle - T) > ThrustIncrement
	{
		IF(T > targetThrottle)
		{
			SET T TO T - ThrustIncrement.
		}
		ELSE
		{
			SET T TO T + ThrustIncrement.
		}
	}
	ELSE
	{
		SET T TO targetThrottle.
	}

	IF(entryMode AND ALT:RADAR < AtmosphereEntryAltitude AND V < AtmosphereEntryVelocity)
	{
		PRINT "Dive Mode initiated.".
		SET targetAltitude TO 0.5.
		SET targetVelocity TO TouchDownVelocity.
		SET entryMode TO 0.
	}

	WAIT loopInterval.
}

SET T TO 0.

PRINT "Landed.".

PRINT "-------------------------------".
PRINT "NB: Please make sure to unfocus".
PRINT "and set your throttle to 0,".
PRINT "to avoid sudden takeoff.".
PRINT "-------------------------------".
PRINT "Program will shut down in 10 seconds.".

WAIT 10.