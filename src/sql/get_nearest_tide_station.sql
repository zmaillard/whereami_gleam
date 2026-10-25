select name,
       id,
       timezone,
       observedst,
       timezone_offset,
       geometry::geography <-> ST_POINT($1, $2, 4326)::geography as dist
from tide_station
where greatlakes = false
ORDER BY dist
LIMIT 1
