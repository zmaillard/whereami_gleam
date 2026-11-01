select ST_AsGeoJson(ST_MakeLine(i.pt)) from  (
    select ST_PointN(st_boundary(wbdhu12.shape),1) as pt
    from huc_downstream_paths
    inner join wbdhu12 on huc_downstream_paths.huc12 = wbdhu12.huc12
where start_huc12 = $1
order by depth) i
