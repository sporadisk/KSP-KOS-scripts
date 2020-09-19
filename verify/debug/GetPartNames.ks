// Run command:
// RUNPATH("0:/debug/GetPartNames.ks").
LIST Parts IN allShipParts. // get a list of all ship parts
FOR P IN allShipParts {
	PRINT ("Name: " + P:NAME).
}
