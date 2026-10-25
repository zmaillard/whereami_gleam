//// This module contains the code to run the sql queries defined in
//// `./src/sql`.
//// > 🐿️ This module was generated automatically using v4.7.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `get_alaska_ecoregion` query
/// defined in `./src/sql/get_alaska_ecoregion.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAlaskaEcoregionRow {
  GetAlaskaEcoregionRow(
    na_l1code: Option(String),
    na_l1name: Option(String),
    na_l2code: Option(String),
    na_l2name: Option(String),
    na_l3code: Option(String),
    na_l3name: Option(String),
  )
}

/// Runs the `get_alaska_ecoregion` query
/// defined in `./src/sql/get_alaska_ecoregion.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_alaska_ecoregion(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetAlaskaEcoregionRow), pog.QueryError) {
  let decoder = {
    use na_l1code <- decode.field(0, decode.optional(decode.string))
    use na_l1name <- decode.field(1, decode.optional(decode.string))
    use na_l2code <- decode.field(2, decode.optional(decode.string))
    use na_l2name <- decode.field(3, decode.optional(decode.string))
    use na_l3code <- decode.field(4, decode.optional(decode.string))
    use na_l3name <- decode.field(5, decode.optional(decode.string))
    decode.success(GetAlaskaEcoregionRow(
      na_l1code:,
      na_l1name:,
      na_l2code:,
      na_l2name:,
      na_l3code:,
      na_l3name:,
    ))
  }

  "SELECT e.\"NA_L1CODE\" as na_l1code, e.\"NA_L1NAME\" as na_l1name,e.\"NA_L2CODE\" as na_l2code, e.\"NA_L2NAME\" as na_l2name,e.\"NA_L3CODE\" as na_l3code, e.\"NA_L3NAME\" as na_l3name  FROM ecoregions_alaska e WHERE ST_CONTAINS(e.geom, ST_POINT($1,$2,4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_congressional_district` query
/// defined in `./src/sql/get_congressional_district.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetCongressionalDistrictRow {
  GetCongressionalDistrictRow(name: Option(String))
}

/// Runs the `get_congressional_district` query
/// defined in `./src/sql/get_congressional_district.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_congressional_district(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetCongressionalDistrictRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    decode.success(GetCongressionalDistrictRow(name:))
  }

  "SELECT cp.name FROM congressional_district cp
	WHERE ST_CONTAINS(cp.geometry, ST_Point($1,$2,4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_county` query
/// defined in `./src/sql/get_county.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetCountyRow {
  GetCountyRow(name: Option(String), state: Option(String))
}

/// Runs the `get_county` query
/// defined in `./src/sql/get_county.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_county(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetCountyRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    use state <- decode.field(1, decode.optional(decode.string))
    decode.success(GetCountyRow(name:, state:))
  }

  "SELECT c.\"NAMELSAD\" as name,c.\"STATEFP\" as state FROM county c WHERE ST_CONTAINS(c.geom, ST_POINT($1,$2,4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_ecoregion` query
/// defined in `./src/sql/get_ecoregion.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetEcoregionRow {
  GetEcoregionRow(
    na_l1code: Option(String),
    na_l1name: Option(String),
    na_l2code: Option(String),
    na_l2name: Option(String),
    na_l3code: Option(String),
    na_l3name: Option(String),
  )
}

/// Runs the `get_ecoregion` query
/// defined in `./src/sql/get_ecoregion.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_ecoregion(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetEcoregionRow), pog.QueryError) {
  let decoder = {
    use na_l1code <- decode.field(0, decode.optional(decode.string))
    use na_l1name <- decode.field(1, decode.optional(decode.string))
    use na_l2code <- decode.field(2, decode.optional(decode.string))
    use na_l2name <- decode.field(3, decode.optional(decode.string))
    use na_l3code <- decode.field(4, decode.optional(decode.string))
    use na_l3name <- decode.field(5, decode.optional(decode.string))
    decode.success(GetEcoregionRow(
      na_l1code:,
      na_l1name:,
      na_l2code:,
      na_l2name:,
      na_l3code:,
      na_l3name:,
    ))
  }

  "SELECT e.na_l1code, e.na_l1name,e.na_l2code, e.na_l2name,e.na_l3code, e.na_l3name
FROM ecoregions e
WHERE ST_CONTAINS(e.geometry, ST_POINT($1,$2,4269))
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_huc` query
/// defined in `./src/sql/get_huc.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetHucRow {
  GetHucRow(huc12: Option(String))
}

/// Runs the `get_huc` query
/// defined in `./src/sql/get_huc.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_huc(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetHucRow), pog.QueryError) {
  let decoder = {
    use huc12 <- decode.field(0, decode.optional(decode.string))
    decode.success(GetHucRow(huc12:))
  }

  "SELECT h.huc12 FROM wbdhu12 h WHERE ST_CONTAINS(h.shape,ST_POINT($1,$2, 4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_huc_closure` query
/// defined in `./src/sql/get_huc_closure.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetHucClosureRow {
  GetHucClosureRow(name: Option(String))
}

/// Runs the `get_huc_closure` query
/// defined in `./src/sql/get_huc_closure.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_huc_closure(
  db: pog.Connection,
  parenthuc: String,
) -> Result(pog.Returned(GetHucClosureRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    decode.success(GetHucClosureRow(name:))
  }

  "select WBDHU12.name
from hucclosure
         inner join WBDHU12 on childhuc = WBDHU12.huc12
where parenthuc = $1 order by depth;
"
  |> pog.query
  |> pog.parameter(pog.text(parenthuc))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_incorporated_place` query
/// defined in `./src/sql/get_incorporated_place.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetIncorporatedPlaceRow {
  GetIncorporatedPlaceRow(name: Option(String), state: Option(String))
}

/// Runs the `get_incorporated_place` query
/// defined in `./src/sql/get_incorporated_place.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_incorporated_place(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetIncorporatedPlaceRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    use state <- decode.field(1, decode.optional(decode.string))
    decode.success(GetIncorporatedPlaceRow(name:, state:))
  }

  "SELECT p.\"PLACE_NAME\" as name,p.\"STATE_NAME\" as state FROM incorporated_place p
WHERE ST_CONTAINS(p.\"SHAPE\", ST_POINT($1,$2,4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_nearest_national_park` query
/// defined in `./src/sql/get_nearest_national_park.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetNearestNationalParkRow {
  GetNearestNationalParkRow(name: Option(String), dist: Float, bearing: Float)
}

/// Runs the `get_nearest_national_park` query
/// defined in `./src/sql/get_nearest_national_park.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_nearest_national_park(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetNearestNationalParkRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    use dist <- decode.field(1, decode.float)
    use bearing <- decode.field(2, decode.float)
    decode.success(GetNearestNationalParkRow(name:, dist:, bearing:))
  }

  "WITH constants (pt) as (
    values (ST_POINT($1, $2, 4269)::geography)
)
select name as name,
       shape::geography <-> pt as dist,
       degrees(st_azimuth(pt, st_centroid(shape))) as bearing
from national_park_service, constants
ORDER BY dist
LIMIT 1;
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_nearest_place` query
/// defined in `./src/sql/get_nearest_place.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetNearestPlaceRow {
  GetNearestPlaceRow(name: String, state: String, dist: Float, bearing: Float)
}

/// Runs the `get_nearest_place` query
/// defined in `./src/sql/get_nearest_place.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_nearest_place(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetNearestPlaceRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.string)
    use state <- decode.field(1, decode.string)
    use dist <- decode.field(2, decode.float)
    use bearing <- decode.field(3, decode.float)
    decode.success(GetNearestPlaceRow(name:, state:, dist:, bearing:))
  }

  "WITH constants (pt) as (
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
    u.\"PLACE_NAME\" as name,
    u.\"STATE_NAME\" as state,
    u.\"SHAPE\" as shape
FROM unincorporated_place u
UNION ALL
SELECT
    i.\"PLACE_NAME\" as name,
    i.\"STATE_NAME\" as state,
    i.\"SHAPE\" as shape
FROM incorporated_place i
), constants
ORDER BY dist
LIMIT 1;
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_nearest_summit` query
/// defined in `./src/sql/get_nearest_summit.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetNearestSummitRow {
  GetNearestSummitRow(
    feature_name: Option(String),
    dist: Float,
    elevation: Option(Float),
    bearing: Float,
  )
}

/// Runs the `get_nearest_summit` query
/// defined in `./src/sql/get_nearest_summit.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_nearest_summit(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
  arg_3: Float,
) -> Result(pog.Returned(GetNearestSummitRow), pog.QueryError) {
  let decoder = {
    use feature_name <- decode.field(0, decode.optional(decode.string))
    use dist <- decode.field(1, decode.float)
    use elevation <- decode.field(2, decode.optional(pog.numeric_decoder()))
    use bearing <- decode.field(3, decode.float)
    decode.success(GetNearestSummitRow(
      feature_name:,
      dist:,
      elevation:,
      bearing:,
    ))
  }

  "WITH constants (pt) as (
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
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.parameter(pog.float(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_nearest_tide_station` query
/// defined in `./src/sql/get_nearest_tide_station.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetNearestTideStationRow {
  GetNearestTideStationRow(
    name: String,
    id: String,
    timezone: String,
    observedst: Bool,
    timezone_offset: Int,
    dist: Float,
  )
}

/// Runs the `get_nearest_tide_station` query
/// defined in `./src/sql/get_nearest_tide_station.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_nearest_tide_station(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetNearestTideStationRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.string)
    use id <- decode.field(1, decode.string)
    use timezone <- decode.field(2, decode.string)
    use observedst <- decode.field(3, decode.bool)
    use timezone_offset <- decode.field(4, decode.int)
    use dist <- decode.field(5, decode.float)
    decode.success(GetNearestTideStationRow(
      name:,
      id:,
      timezone:,
      observedst:,
      timezone_offset:,
      dist:,
    ))
  }

  "select name,
       id,
       timezone,
       observedst,
       timezone_offset,
       geometry::geography <-> ST_POINT($1, $2, 4326)::geography as dist
from tide_station
where greatlakes = false
ORDER BY dist
LIMIT 1
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_nws_office` query
/// defined in `./src/sql/get_nws_office.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetNwsOfficeRow {
  GetNwsOfficeRow(code: String, name: Option(String), region: Option(String))
}

/// Runs the `get_nws_office` query
/// defined in `./src/sql/get_nws_office.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_nws_office(
  db: pog.Connection,
  code: String,
) -> Result(pog.Returned(GetNwsOfficeRow), pog.QueryError) {
  let decoder = {
    use code <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.optional(decode.string))
    use region <- decode.field(2, decode.optional(decode.string))
    decode.success(GetNwsOfficeRow(code:, name:, region:))
  }

  "SELECT code, name, region FROM nwsoffice where code = $1
"
  |> pog.query
  |> pog.parameter(pog.text(code))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_unincorporated_place` query
/// defined in `./src/sql/get_unincorporated_place.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.7.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUnincorporatedPlaceRow {
  GetUnincorporatedPlaceRow(name: Option(String), state: Option(String))
}

/// Runs the `get_unincorporated_place` query
/// defined in `./src/sql/get_unincorporated_place.sql`.
///
/// > 🐿️ This function was generated automatically using v4.7.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_unincorporated_place(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetUnincorporatedPlaceRow), pog.QueryError) {
  let decoder = {
    use name <- decode.field(0, decode.optional(decode.string))
    use state <- decode.field(1, decode.optional(decode.string))
    decode.success(GetUnincorporatedPlaceRow(name:, state:))
  }

  "SELECT p.\"PLACE_NAME\" as name,p.\"STATE_NAME\" as state FROM unincorporated_place p
WHERE ST_CONTAINS(p.\"SHAPE\", ST_POINT($1,$2,4269));
"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
