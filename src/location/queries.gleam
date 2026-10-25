import utilities/bearing
import coordinate
import error.{type DatabaseError, NoRecordsFoundError, QueryError}
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import pog
import sql

pub fn nws_office(
  db_conn: pog.Connection,
  nws_office_code: String,
) -> Result(String, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_nws_office(nws_office_code)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.try(row)

  row.name |> option.to_result(NoRecordsFoundError)
}

pub fn place(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.PopulatedPlace, DatabaseError) {
  incorporated(db_conn, coords)
  |> result.lazy_or(fn() { unincorporated_place(db_conn, coords) })
}

fn incorporated(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.PopulatedPlace, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_incorporated_place(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.Incorporated(
    option.unwrap(row.name, ""),
    option.unwrap(row.state, ""),
  )
}

fn unincorporated_place(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.PopulatedPlace, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_unincorporated_place(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.Unincorporated(
    option.unwrap(row.name, ""),
    option.unwrap(row.state, ""),
  )
}

pub fn ecoregion(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.Ecoregion, DatabaseError) {
  us_ecoregion(db_conn, coords)
  |> result.lazy_or(fn() { alaska_ecoregion(db_conn, coords) })
}

fn us_ecoregion(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.Ecoregion, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_ecoregion(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.Ecoregion(
    option.unwrap(row.na_l1code, ""),
    option.unwrap(row.na_l1name, ""),
    option.unwrap(row.na_l2code, ""),
    option.unwrap(row.na_l2name, ""),
    option.unwrap(row.na_l3code, ""),
    option.unwrap(row.na_l3name, ""),
  )
}

fn alaska_ecoregion(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.Ecoregion, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_alaska_ecoregion(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.Ecoregion(
    option.unwrap(row.na_l1code, ""),
    option.unwrap(row.na_l1name, ""),
    option.unwrap(row.na_l2code, ""),
    option.unwrap(row.na_l2name, ""),
    option.unwrap(row.na_l3code, ""),
    option.unwrap(row.na_l3name, ""),
  )
}

pub fn tide_station(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.TideStation, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_nearest_tide_station(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.TideStation(
    row.name,
    row.id,
    row.timezone,
    row.observedst,
    row.timezone_offset,
    row.dist,
  )
}

pub fn watersheds(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(List(String), DatabaseError) {
  use pog.Returned(_, rows) <- result.try(
    db_conn
    |> sql.get_huc(coords.longitude, coords.latitude)
    |> result.map_error(QueryError),
  )

  use row <- result.try(
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError),
  )

  let huc_name = option.unwrap(row.huc12, "")

  use pog.Returned(_, huc_rows) <- result.try(
    db_conn
    |> sql.get_huc_closure(huc_name)
    |> result.map_error(QueryError),
  )

  let cleaned_hucs =
    huc_rows
    |> list.map(fn(r) { option.unwrap(r.name, "") })
    |> clean_watershed_items

  Ok(cleaned_hucs)
}

pub fn national_park(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.NationalPark, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_nearest_national_park(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.NationalPark(
    option.unwrap(row.name, ""),
    row.dist,
    bearing.bearing_from_angle(row.bearing),
  )
}

pub fn reverse(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.ReverseGeocode, DatabaseError) {
  let place_res = place(db_conn, coords)

  case place_res {
    Ok(item) -> Ok(coordinate.Place(item.name, item.state))
    _ -> {
      let nearest_query_result =
        db_conn
        |> sql.get_nearest_place(coords.longitude, coords.latitude)
        |> result.map_error(QueryError)

      use pog.Returned(_, nearest_rows) <- result.try(nearest_query_result)
      let nearest_row =
        nearest_rows
        |> list.first
        |> result.replace_error(NoRecordsFoundError)

      use nearest_row <- result.map(nearest_row)

      coordinate.NearestPlace(
        nearest_row.name,
        nearest_row.state,
        nearest_row.dist,
        bearing.bearing_from_angle(nearest_row.bearing),
      )
    }
  }
}

pub fn county(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.County, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_county(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.County(option.unwrap(row.name, ""), option.unwrap(row.state, ""))
}

pub fn congressional_district(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
) -> Result(coordinate.CongressionalDistrict, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_congressional_district(coords.longitude, coords.latitude)
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.CongressionalDistrict(option.unwrap(row.name, ""))
}

pub fn summit(
  db_conn: pog.Connection,
  coords: coordinate.Coordinate,
  current_elevation: Float,
) -> Result(coordinate.Summit, DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_nearest_summit(
      coords.longitude,
      coords.latitude,
      current_elevation,
    )
    |> result.map_error(QueryError)

  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(NoRecordsFoundError)

  use row <- result.map(row)

  coordinate.Summit(
    option.unwrap(row.feature_name, ""),
    option.unwrap(row.elevation, 0.0),
    row.dist,
    bearing.bearing_from_angle(row.bearing),
  )
}

pub fn clean_watershed_items(items: List(String)) -> List(String) {
  items
  |> list.map(fn(x) { string.crop(from: x, before: "-") })
  |> list.map(fn(x) { string.remove_prefix(x, "-") })
  |> list.fold([], fn(acc, i) {
    case acc {
      [first, ..] ->
        case first == i {
          True -> acc
          False -> [i, ..acc]
        }
      _ -> [i]
    }
  })
  |> list.reverse
}
