function GetSolidFuel {
	FOR res IN STAGE:RESOURCES {
		if(res:NAME = "SolidFuel") { // we have solid booster fuel!
			RETURN res.
		}
	}
}
