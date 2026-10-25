import context.{type Context}
import coordinate
import error
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result
import location/queries
import utilities/state
import wisp.{type Request, type Response}

type PoliticalError {
  CountyUnavailable(error.DatabaseError)
  CongressionalDistrictUnavailable(error.DatabaseError)
}

fn political_error_response(err: PoliticalError) -> Response {
  case err {
    CountyUnavailable(_) -> wisp.internal_server_error()
    CongressionalDistrictUnavailable(_) -> wisp.internal_server_error()
  }
}

fn result_json(
  congress: coordinate.CongressionalDistrict,
  county: coordinate.County,
  place: Option(coordinate.PopulatedPlace),
  national_park: Option(coordinate.NationalPark),
) -> String {
  let nearest_park = case national_park {
    Some(coordinate.NationalPark(name, distance, bearing)) -> [
      #(
        "nearestNationalPark",
        json.object([
          #("name", json.string(name)),
          #("distance", json.float(distance)),
          #("bearing", json.string(bearing)),
        ]),
      ),
    ]
    _ -> []
  }

  let coordinate.CongressionalDistrict(name) = congress
  let congress_district = [#("congressionalDistrict", json.string(name))]

  let county_json = [
    #("county", json.string(county.name)),
    #(
      "state",
      json.nullable(state.state_name_from_fips(county.state), of: json.string),
    ),
  ]

  let place = case place {
    Some(coordinate.Incorporated(name, _)) -> [
      #("place", json.string(name)),
      #("placeType", json.string("Incorporated")),
    ]
    Some(coordinate.Unincorporated(name, _)) -> [
      #("place", json.string(name)),
      #("placeType", json.string("Unincorporated")),
    ]
    _ -> []
  }
  congress_district
  |> list.append(county_json)
  |> list.append(place)
  |> list.append(nearest_park)
  |> json.object
  |> json.to_string
}

pub fn political_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use coord <- coordinate.require_coord(coordinate.from_form(formdata))

  let result = {
    use county <- result.try(
      queries.county(ctx.db, coord) |> result.map_error(CountyUnavailable),
    )

    use congressional_district <- result.try(
      queries.congressional_district(ctx.db, coord)
      |> result.map_error(CongressionalDistrictUnavailable),
    )

    let place =
      queries.place(ctx.db, coord)
      |> option.from_result

    let national_park =
      queries.national_park(ctx.db, coord)
      |> option.from_result

    Ok(result_json(congressional_district, county, place, national_park))
  }
  case result {
    Ok(json_res) -> wisp.json_response(json_res, 200)
    Error(e) -> political_error_response(e)
  }
}
