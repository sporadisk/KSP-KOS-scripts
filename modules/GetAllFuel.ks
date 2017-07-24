// returns the sum of the liquid fuel for any craft
// including those that have reached stage 0
function GetAllFuel {
	SET fuel TO 0.
	FOR P IN SHIP:PARTS {
		FOR res IN P:RESOURCES {
			if(res:NAME = "LiquidFuel") { // we have liquid fuel!
				SET fuel TO fuel + res:AMOUNT.
			}
		}
	}

	RETURN fuel.
}
