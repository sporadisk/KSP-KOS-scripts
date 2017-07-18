// ------- Config Parameters -------

// Initial burn altitude (meters): Prevent the lander from starting its burn too early, but start above atmosphere, if one exists.
SET InitialBurnAltitude TO 35000.

// Initial max entry speed (m/s) - Stage 1 will slow down until this orbital velocity is reached.
SET InitialBurnVelocity TO 1800.

// Need to know the vessel's height to accurately calculate touchdown.
// To get the vessel's height, run PRINT ALT:RADAR while the lander module sits on the launchpad, with landing struts deployed.
SET ShipHeight TO 2.64.

// Surface gravity of the target you wish to land on. If you overestimate this, you will never land.
// Calculation: Surface gravity = Gravitational constant * (object mass (kg) / object radius (km) ^ 2)
// (Gravitational constant: 6.67E-11 )
// Kerbin: 9.81
// Mun: 1.62748
SET SurfaceGravity TO 9.81.

// Thrust Curves: Lower curve value = more thrust usage when doing "emergency" burns.
SET ThrustCurveDescent TO 20.
SET ThrustCurveLanding TO 10.

// Thrust Increment: More means more violent thrust usage. 0.02 = Up to 20% thrust change per second.
SET ThrustIncrement TO 0.02.

// Hover to neutral: The amount of hover thrust necessary to do a controlled descent. Lower value = harder landing.
SET HoverToNeutral TO 0.9.

// Altitude to velocity ratio for descent stages. Alter for flavor.
// Lower ratio = faster descent. Stronger engines can descend faster without risking a crash.
SET AltVelRatioDescent TO 16.
SET AltVelRatioLanding TO 8.

// Altitude at which to initiate Landing Mode (meters)
SET LandingStageAltitude TO 10.

// Initial velocity for landing stage (m/s)
SET LandingStageVelocity TO 6.

// Velocity to try to touch down at (m/s)
SET TouchDownVelocity TO 0.5.

// ------- End Config -------

// ------- Start Init -------

// Set up a shorthand var to get velocity relative to surface.
LOCK V TO VELOCITY:SURFACE:MAG.

// Since the "retrograde" value only does orbit retrograde, set up a manual retrograde relative to surface.
LOCK R TO (-1) * SHIP:VELOCITY:SURFACE.

// Accurate altitude calculation on the fly
LOCK LandingGearAltitude TO ALT:RADAR - ShipHeight.

PRINT "Lander program initialized.".
IF SHIP:MAXTHRUST > 0
{
	SET gPull TO SurfaceGravity * SHIP:MASS.
	
	// Calculate required percentage of thrust in order to almost hover
	SET neutralThrust TO (gPull / SHIP:MAXTHRUST) * HoverToNeutral.
	PRINT "Thrust requirements calculated.".
}
ELSE
{
	PRINT "Error: No engines or engines disabled.".
}

// ------- End Init -------

// Stage 0: Throttle down, wait until desired altitude is reached
SET T TO 0.
LOCK THROTTLE TO T.

IF(LandingGearAltitude > InitialBurnAltitude)
{
	PRINT "Waiting for the right moment.".
	LOCK STEERING TO SHIP:PROGRADE.
	WAIT UNTIL LandingGearAltitude < InitialBurnAltitude.
}

// Stage 1: Rotate to surface retrograde, burn until falling more or less vertically.

LOCK STEERING TO R.

PRINT "Stage 1: Orientation.".
// Wait until retrograde angle is approximately achieved
LOCK RetroAngle TO (SHIP:FACING - R).
WAIT UNTIL (ABS(RetroAngle:YAW) < 2 AND ABS(RetroAngle:PITCH) < 2).

PRINT "Burn for vertical descent".
// Stage 2: Retrograde burn until orbital velocity is sufficiently low
UNTIL (VELOCITY:ORBIT:MAG < InitialBurnVelocity)
{
	IF(T < 1)
		SET T TO (T + 0.02).
	WAIT 0.1.
}

PRINT "Stage 2: Descent".

SET Tc TO ThrustCurveDescent.
SET StageTargetAltitude TO LandingStageAltitude.
SET StageTargetVelocity TO LandingStageVelocity.
SET StageAltVelRatio TO AltVelRatioDescent.

SET TargetDeceleration TO 0.
SET LastTargetSpeed TO 0.
SET LastTimestamp TO 0.

// This event trigger activates at landing stage altitude
// and sets new flight parameters according to config
WHEN LandingGearAltitude < LandingStageAltitude THEN
{
	PRINT "Stage 3: Landing".
	LOCK STEERING TO UP.
	PRINT "Extending landing struts.".
	LEGS ON.

	SET Tc TO ThrustCurveLanding.
	SET StageTargetAltitude TO 0.
	SET StageTargetVelocity TO TouchDownVelocity.
	SET StageAltVelRatio TO AltVelRatioLanding.
}

UNTIL (LandingGearAltitude < 1 AND VERTICALSPEED > -0.1)
{
	SET targetSpeed TO StageTargetVelocity + ((LandingGearAltitude - StageTargetAltitude) / StageAltVelRatio).

	IF(LastTargetSpeed <> 0)
	{
		SET TargetDeceleration TO (targetSpeed - LastTargetSpeed) / (TIME:SECONDS - LastTimestamp).
	}

	SET LastTargetSpeed TO targetSpeed.
	SET LastTimestamp TO TIME:SECONDS.

	IF VERTICALSPEED < (0 - (targetSpeed + (TargetDeceleration * 2))) // Lagging 2 or more seconds behind the deceleration plan (aka going too fast)
	{
		SET thrustTarget TO neutralThrust + (1 - ((targetSpeed + Tc) / (V + Tc))). // Use the thrust curve to apply extra thrust
	}
	ELSE // Not going too fast
	{
		IF VERTICALSPEED < (0 - (targetSpeed / 2))
		{
			// And not much too slowly
			IF VERTICALSPEED > (0 - (targetSpeed - (TargetDeceleration * 2))) // But still a bit too slow
			{
				SET TargetDeceleration TO TargetDeceleration * 0.6. // reduce deceleration target to compensate
			}

			SET thrustTarget TO (SurfaceGravity + TargetDeceleration) * (SHIP:MASS / SHIP:MAXTHRUST).
		}
		ELSE SET thrustTarget TO 0. // Falling much too slowly. Cut throttle.
	}

	IF ABS(thrustTarget - T) > ThrustIncrement
	{
		IF(T > thrustTarget)
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
		SET T TO thrustTarget.
	}

	WAIT 0.1. // avoid looping too quick.
}

PRINT "Landed.".
SET T TO 0.
PRINT "Program will shut down in 10 seconds.".
PRINT "-------------------------------".
PRINT "NB: Please make sure to unfocus".
PRINT "and set your throttle to 0,".
PRINT "to avoid sudden takeoff.".
PRINT "-------------------------------".


WAIT 10.

