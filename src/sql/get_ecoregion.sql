SELECT e.na_l1code, e.na_l1name,e.na_l2code, e.na_l2name,e.na_l3code, e.na_l3name
FROM ecoregions e
WHERE ST_CONTAINS(e.geometry, ST_POINT($1,$2,4269))
