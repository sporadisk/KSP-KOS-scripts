function GetLiquidFuel {
	FOR res IN STAGE:RESOURCES {
		if(res:NAME = "LiquidFuel") { // we have liquid fuel!
			RETURN res.
		}
	}
}