select WBDHU12.name
from hucclosure
         inner join WBDHU12 on childhuc = WBDHU12.huc12
where parenthuc = $1 order by depth;
