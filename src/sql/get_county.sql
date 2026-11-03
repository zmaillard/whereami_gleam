SELECT c."NAMELSAD" as name,c."STATEFP" as state, ST_AsGeoJson(c.geom) as shape FROM county c WHERE ST_CONTAINS(c.geom, ST_POINT($1,$2,4269));
