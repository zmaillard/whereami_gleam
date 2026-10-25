SELECT c."NAMELSAD" as name,c."STATEFP" as state FROM county c WHERE ST_CONTAINS(c.geom, ST_POINT($1,$2,4269));
