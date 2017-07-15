// Gravity turn mk2
// Assumes you've already set the variable "TargetDirection"
// where 90 degrees = up and 0 degrees = horizontal
// turn = 90 * (1 - ((apoapsis/80000) ^ 2))
LOCK remheight TO (SHIP:APOAPSIS/80000).
LOCK gangle TO (90 * (1 - (remheight * remheight))).
LOCK STEERING TO HEADING(TargetDirection, gangle).
