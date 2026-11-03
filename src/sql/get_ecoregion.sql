SELECT e.na_l1code, initcap(e.na_l1name) as na_l1name,e.na_l2code, initcap(e.na_l2name) as na_l2name,e.na_l3code, initcap(e.na_l3name) as na_l3name
FROM ecoregions e
WHERE ST_CONTAINS(e.geometry, ST_POINT($1,$2,4269))
