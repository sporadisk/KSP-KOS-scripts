// Gravity turn mk2
function GravityTurn {
	// TargetDirection: defines the compass direction in which you'd like to travel.
	PARAMETER TargetDirection IS 90.
	// TargetApoapsis: The apoapsis you intend to reach
	PARAMETER TargetApoapsis IS 80000.
	PARAMETER Factor IS 2.
	
	// -- Gravity turn calculation --
	// where 90 degrees = up and 0 degrees = horizontal
	// turn = 90 * (1 - ((apoapsis/TargetApoapsis) ^ 2))
	SET remheight TO (SHIP:APOAPSIS/TargetApoapsis).
	SET gangle TO (90 * (1 - (remheight ^ Factor))).
	RETURN HEADING(TargetDirection, gangle).
}

