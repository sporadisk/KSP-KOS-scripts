// This script assumes that the heat shield is mounted on the rear of the ship
// MainChuteDeployAlt: The altitude at which the main chutes are deployed
// TargetSpeed: The speed at which we're reasonably certain that all chutes have been deployed
PARAMETER TargetSpeed IS 20.
LOCK STEERING TO SHIP:SRFRETROGRADE.
CHUTESSAFE ON. // Deploys chutes gradually as soon as they're safe to deploy.
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < TargetSpeed.
GEAR ON.
UNLOCK STEERING.
