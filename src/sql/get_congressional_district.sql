SELECT cp.name FROM congressional_district cp
	WHERE ST_CONTAINS(cp.geometry, ST_Point($1,$2,4269));
