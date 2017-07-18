// Chooses a random launch vector.
local function randscal {
	return (RANDOM() * 2) - 1.
}

SET rvec TO V(randscal(),randscal(),randscal()).
SET lookDir TO UP:VECTOR + (rvec * 0.2).
SET newDir TO LOOKDIRUP(lookDir, UP:VECTOR).
LOCK STEERING TO newDir.
PRINT "Steering locked to: " + newDir.
