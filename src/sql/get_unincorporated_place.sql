SELECT
    p."PLACE_NAME" as name,
    p."STATE_NAME" as state,
    COALESCE(p."POPULATION",0) as population,
    ST_X(ST_CENTROID(p."SHAPE")) as longitude,
    ST_Y(ST_CENTROID(p."SHAPE")) as latitude
FROM unincorporated_place p
WHERE ST_CONTAINS(p."SHAPE", ST_POINT($1,$2,4269));
