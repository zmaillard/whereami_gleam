WITH max_huc AS (select max(depth) from huc_downstream_paths where start_huc12 = $1),
   terminal_huc as (select huc12 from huc_downstream_paths where start_huc12 = $1 and depth = (select * from max_huc)),
    pre_terminal_huc as (select huc12 from huc_downstream_paths where start_huc12 = $1 and depth = (select * from max_huc) - 1),
    intersects as (select ST_POINTN(ST_Intersection(t.shape, p.shape),1) as geom from wbdhu12 t inner join wbdhu12 p on t.huc12 = (select * from terminal_huc) and p.huc12 = (select * from pre_terminal_huc)
    UNION ALL
    select ST_CENTROID(shape) as geom from wbdhu12 where huc12 = (select * from terminal_huc))
select ST_X(geom) as longitude, ST_Y(geom) as latitude from intersects where geom is not null limit 1
