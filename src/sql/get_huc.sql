SELECT huc12 from (
SELECT h.huc12 FROM wbdhu12 h WHERE ST_CONTAINS(h.shape,ST_POINT($1,$2, 4269))
union all
SELECT h.huc12 FROM wbdhu12 h WHERE ST_INTERSECTS(h.shape,ST_BUFFER(ST_POINT($1,$2, 4269), 0.1))
) i where i.huc12 is not null limit 1
