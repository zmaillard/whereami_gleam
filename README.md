# whereami_gleam

[![Package Version](https://img.shields.io/hexpm/v/whereami_gleam)](https://hex.pm/packages/whereami_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://whereami-gleam.hexdocs.pm/)

```sh
gleam add whereami_gleam@1
```
```gleam
import whereami_gleam

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://whereami-gleam.hexdocs.pm/>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

###  Creating Closure Table
```sql
CREATE TABLE huc_downstream_paths AS
WITH RECURSIVE hucs AS (
SELECT huc12 AS start_huc12, name, huc12, tohuc, 0 AS depth,
ARRAY[huc12] AS path
FROM wbdhu12
UNION ALL
SELECT hucs.start_huc12, wbdhu12.name, wbdhu12.huc12, wbdhu12.tohuc, hucs.depth + 1,
hucs.path || wbdhu12.huc12
FROM wbdhu12
INNER JOIN hucs ON wbdhu12.huc12 = hucs.tohuc
WHERE NOT wbdhu12.huc12 = ANY(hucs.path)   -- stop if we've seen this huc12 before
)
SELECT start_huc12, name, huc12, tohuc, depth FROM hucs;
```
