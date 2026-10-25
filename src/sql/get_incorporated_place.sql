SELECT p."PLACE_NAME" as name,p."STATE_NAME" as state FROM incorporated_place p
WHERE ST_CONTAINS(p."SHAPE", ST_POINT($1,$2,4269));
