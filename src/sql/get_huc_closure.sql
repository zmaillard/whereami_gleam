select wbdhu12.name from huc_downstream_paths
         inner join wbdhu12 on huc_downstream_paths.huc12 = wbdhu12.huc12
         where start_huc12 = $1 order by depth;
