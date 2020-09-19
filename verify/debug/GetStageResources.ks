// Run:
// RUNPATH("0:/debug/GetStageResources.ks").
FOR res IN STAGE:RESOURCES {
	PRINT "------------------".
	PRINT "Name:" + res:NAME.
	PRINT "Amount:" + res:AMOUNT.
	PRINT "Capacity:" + res:CAPACITY.
	PRINT "Density:" + res:DENSITY.
	//PRINT "Toggleable:" + res:TOGGLEABLE.
	//PRINT "Enabled:" + res:ENABLED.
}
