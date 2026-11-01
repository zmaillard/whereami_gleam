WITH constants (pt) as (
    values (ST_POINT($1, $2, 4269)::geography)
)
select name as name,
       shape::geography <-> pt as dist,
       degrees(st_azimuth(pt, st_centroid(shape))) as bearing,
       ST_X(ST_Centroid(shape)) as longitude,
       ST_Y(ST_Centroid(shape)) as latitude
from national_park_service, constants
ORDER BY dist
LIMIT 1;
