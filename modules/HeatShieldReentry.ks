// This script assumes that the heat shield is mounted on the rear of the ship
// MainChuteDeployAlt: The altitude at which the main chutes are deployed
LOCK STEERING TO SHIP:SRFRETROGRADE.
CHUTESSAFE ON. // Deploys chutes gradually as soon as they're safe to deploy.
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < 20.
GEAR ON.
UNLOCK STEERING.
