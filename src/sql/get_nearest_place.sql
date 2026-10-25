WITH constants (pt) as (
    values (ST_POINT($1, $2, 4269)::geography)
)
SELECT
    name,
    state,
    shape::geography <-> pt as dist,
    degrees(st_azimuth(pt, shape)) as bearing
FROM
    (
SELECT
    u."PLACE_NAME" as name,
    u."STATE_NAME" as state,
    u."SHAPE" as shape
FROM unincorporated_place u
UNION ALL
SELECT
    i."PLACE_NAME" as name,
    i."STATE_NAME" as state,
    i."SHAPE" as shape
FROM incorporated_place i
), constants
ORDER BY dist
LIMIT 1;
