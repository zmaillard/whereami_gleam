WITH constants (pt) as (
    values (ST_POINT($1, $2, 4326)::geography)
)
select feature_name,
       geom::geography <-> pt as dist,
       elevation,
       degrees(st_azimuth(pt, geom)) as bearing
from gnis, constants
where feature_class = 'Summit' and elevation > $3
ORDER BY dist
LIMIT 1;
