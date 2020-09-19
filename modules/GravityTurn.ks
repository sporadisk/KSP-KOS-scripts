// Gravity turn mk2
// made for KOS 1.2.0.0
function GravityTurn {
	// TargetDirection: defines the compass direction in which you'd like to travel.
	PARAMETER TargetDirection IS 90.
	// TargetApoapsis: The apoapsis you intend to reach
	PARAMETER TargetApoapsis IS 80000.
	// Factor: A higher factor means you start the turn earlier.
	PARAMETER Factor IS 1.

	// Factor examples: These are angles that the different factors will yield
	// at certain percentages of the target apoapsis.
	//       0%   10%   20%   30%   40%   50%   60%   70%   80%   90%   100%
	// 1   - 90   89    86    82    76    68    58    46    32    17    0
	// 1.5 - 90   86    79    72    63    54    44    34    23    12    0
	// 2   - 90   81    72    63    54    45    36    27    18    9     0
	// 3   - 90   71    59    50    41    33    26    19    12    6     0
	// 4   - 90   62    50    41    33    26    20    15    10    5     0
	
	// Orbiters with liquid fuel stages can use lower factors,
	// while solid fuel low-orbit flights probably need a factor of 2-3.
	// Higher factors can be useful for flights that aim to achieve 
	// a high suborbital trajectory right from launch.
	// Note: Higher TWR (2.0 and more) can result in significant sideways drag on ascent,
	// as the angle between the rocket's trajectory and orientation grows.

	SET remFactor TO (2 / Factor).
	// -- Gravity turn calculation --
	// where 90 degrees = up and 0 degrees = horizontal
	// turn = 90 * (1 - ((apoapsis/TargetApoapsis) ^ 2))
	SET remheight TO (SHIP:APOAPSIS/TargetApoapsis).
	SET gangle TO (90 * (1 - (remheight ^ remFactor))).
	RETURN HEADING(TargetDirection, gangle).
}

