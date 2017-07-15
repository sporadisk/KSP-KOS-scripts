// --Config--

// Surface gravity of the target you wish to land on. If you overestimate this, you will never land.
// Calculation: Surface gravity = Gravitational constant * (object mass (kg) / object radius (km) ^ 2)
// (Gravitational constant: 6.67E-11 )
// Kerbin: 9.81
// Mun: 1.62748
SET SurfaceGravity TO 1.62748.

SET HasAtmosphere TO 0.
SET AtmosphereEntryAltitude TO 35000.
SET AtmosphereEntryVelocity TO 2000.

SET TouchDownVelocity TO 0.5.
SET LandingAltitude TO 500.
SET LandingTime TO 3. // initiate landing mode with 10 seconds to spare

// for non-atmosphere landings:
SET DiveSurfaceVel TO 3. // Slow down to this velocity (relative to the surface plane) before making the final dive.
SET LandSurfaceVel TO 0.1. // Slow down to this velocity (relative to the surface plane) before landing.

// Need to know the vessel's height to accurately calculate touchdown.
// To get the vessel's height, run PRINT ALT:RADAR while the lander module sits on the launchpad, with landing struts deployed.
SET ShipHeight TO 2.62.

// The time to wait between each calculation run in the main loop
SET loopInterval TO 0.05.

// Landing margin (meters): Prevents the craft from avoiding the ground. Needs to be at least half the width of the (deployed) landing gear.
SET landingMargin TO 1.4.

// --End Config--

// --Init--
LOCK LandingGearAltitude TO (ALT:RADAR - ShipHeight).
LOCK MaxDeceleration TO (SHIP:MAXTHRUST / SHIP:MASS).
LOCK V TO VELOCITY:SURFACE:MAG.

// Calculate required percentage of thrust in order to land smoothly
LOCK landingThrust TO ((SurfaceGravity * SHIP:MASS) / SHIP:MAXTHRUST) * 0.5.

SET SoftLandingDecel TO (MaxDeceleration - SurfaceGravity) / 2. // pick a deceleration well within the capabilities of the craft
SET SoftLandingStartVelocity TO SoftLandingDecel * 5. // equal to the speed you get from 5 seconds at that deceleration
SET SoftLandingAlt TO SoftLandingDecel * 25. // The altitude at which the craft will start the touchdown phase

IF(HasAtmosphere AND ALT:RADAR > AtmosphereEntryAltitude)
{
	PRINT "Atmosphere Entry Mode initiated.".
	SET targetAltitude TO AtmosphereEntryAltitude.
	SET targetVelocity TO AtmosphereEntryVelocity.
	SET entryMode TO 1.
}
ELSE
{
	SET targetAltitude TO SoftLandingAlt.
	SET targetVelocity TO SoftLandingStartVelocity.
	SET entryMode TO 0.
}

SET targetThrottle TO 0.
SET LandingMode TO 0.
SET InitialBurnPerformed TO 0.
SET angleMod TO 1.
SET thrustCalcMod TO 0.8.
SET lastUp TO UP.
SET lastUpDiff TO 2.
// --End Init--

SET T TO 0.
LOCK THROTTLE TO T.

LOCK R TO SHIP:SRFRETROGRADE. // surface retrograde
LOCK STEERING TO R:VECTOR.

IF(HasAtmosphere)
	{ WAIT UNTIL VERTICALSPEED < 0. }

LOCK RetroAngle TO (SHIP:FACING - R).
WAIT UNTIL (ABS(RetroAngle:YAW) < 2 AND ABS(RetroAngle:PITCH) < 2).

SET targetSpeed TO 0.
SET LastTargetSpeed TO 0.
SET lastSetting TO 0.

Lock AbsVert TO ABS(VERTICALSPEED).

UNTIL (LandingGearAltitude < landingMargin AND VERTICALSPEED > -0.1)
{
	// use max deceleration to figure out at what altitudes to start burning.
	// start at an altitude at which 75% of max thrust for the duration of the remaining descent
	// will stop the descent at about 100 meters.
	// burnAltitude = current_velocity^2 / (max_deceleration * 0.75).
	// calculate time it will take to decelerate to the target velocity from the current velocity, with safety margin.

	IF(LandingGearAltitude < SoftLandingAlt OR LandingMode)
	{
		// Soft Landing mode:
		// reach touchdown speed by distributing the deceleration along the remaining descent in a linear fashion

		IF(LandingGearAltitude > landingMargin)
		{
			SET targetVelocity TO (((LandingGearAltitude - landingMargin) / SoftLandingAlt) * SoftLandingStartVelocity) + TouchDownVelocity.
		}
		ELSE
			{ SET targetVelocity TO TouchDownVelocity. }
	
		IF(targetVelocity < (0 - SHIP:VERTICALSPEED)) // need to slow down
		{
			SET deltaV TO (0 - SHIP:VERTICALSPEED) - targetVelocity.
			SET targetAcceleration TO deltaV / loopInterval.
			SET targetThrottle TO (targetAcceleration / MaxDeceleration) + (SurfaceGravity / MaxDeceleration).

			IF(targetThrottle > 1)
				{ SET targetThrottle TO 1. }
		}
		ELSE
		{ SET targetThrottle TO targetThrottle - loopInterval. }
	}
	ELSE
	{
		SET progradeDeceleration TO (0.75 * MaxDeceleration).
		SET verticalDeceleration TO progradeDeceleration * angleMod.

		SET decelTime TO (V - targetVelocity) / (progradeDeceleration - (SurfaceGravity * angleMod)).

		// calculate the vertical distance travelled during that time, taking gravity into account.
		SET velocityIntegralDecel TO (SurfaceGravity - verticalDeceleration) * (0.5 * decelTime * decelTime).
		SET decelAltitude TO (AbsVert * decelTime) + velocityIntegralDecel.

		// now we know the altitude at which it would be wise to initiate a burn.
		SET burnAltitude TO targetAltitude + decelAltitude.

		SET angleMod TO (AbsVert / V).

		IF(VERTICALSPEED < 0 AND (LandingMode OR LandingGearAltitude <= burnAltitude))
		{
			IF((NOT InitialBurnPerformed) AND (NOT HasAtmosphere))
			{
				// In non-atmosphere landings, burn hard before final descent to make sure you're not drifting too much
				PRINT "Braking for dive.".
				SET TmpRetro TO SHIP:SRFRETROGRADE.
				LOCK STEERING TO TmpRetro:VECTOR.
				SET T TO 1.
				WAIT UNTIL SHIP:SURFACESPEED <= DiveSurfaceVel.
				SET T TO 0.
				PRINT "Non-atmosphere dive mode initiated.".
				SET InitialBurnPerformed TO 1.
			}

			// Then continually burn at an optimal deceleration plan.
			// Pick the throttle setting that barely gets you down safely.

			SET targetThrottle TO 2.

			IF(V <> 0 AND SHIP:MAXTHRUST <> 0 AND LandingGearAltitude > targetAltitude)
			{
				SET tSetting TO 1.

				UNTIL (tSetting <= 0 OR targetThrottle < 2)
				{
					SET progradeDeceleration TO (thrustCalcMod * tSetting * MaxDeceleration).
					SET verticalDeceleration TO progradeDeceleration * angleMod.
					SET decelTime TO (V - targetVelocity) / (verticalDeceleration - (SurfaceGravity * angleMod)).
					
					IF(decelTime > 0)
					{
						SET velocityIntegralDecel TO (SurfaceGravity - verticalDeceleration) * (0.5 * decelTime * decelTime).
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
			}

			IF(targetThrottle = 2)
			{
				SET targetThrottle TO 0.
			}
		}
		ELSE // going up
		{
			SET targetThrottle TO 0.
		}
	}

	IF(SHIP:VERTICALSPEED > 0 OR (LandingMode AND angleMod < 0.6) OR (SHIP:SURFACESPEED < LandSurfaceVel))
	{
		LOCK STEERING TO UP:VECTOR.
	}
	ELSE
	{
		LOCK STEERING TO SHIP:SRFRETROGRADE:VECTOR.
	}

	IF(LandingGearAltitude < LandingAltitude AND targetThrottle > 0 AND NOT entryMode AND NOT LandingMode)
	{
		PRINT "Landing Mode initiated.".
		SET LandingMode TO 1.
		SET thrustCalcMod TO 1.
		SET targetAltitude TO landingMargin.
		SET targetVelocity TO TouchDownVelocity.
		LEGS ON.
		BRAKES ON.
		LIGHTS ON.
	}

	SET T TO targetThrottle.

	IF(entryMode AND ALT:RADAR < AtmosphereEntryAltitude AND V < AtmosphereEntryVelocity)
	{
		PRINT "Dive Mode initiated.".
		SET targetAltitude TO SoftLandingAlt.
		SET targetVelocity TO SoftLandingStartVelocity.
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