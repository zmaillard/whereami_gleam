import context.{type Context}
import coordinate
import error
import gleam/bool
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/result
import location/queries
import location/web
import tempo/datetime
import wisp.{type Request, type Response}

pub type TideError {
  StationNotFound
  StationTooFar
  TidesUnavailable(error.HttpError)
  Database(error.DatabaseError)
}

fn tide_error_response(err: TideError) -> Response {
  case err {
    StationNotFound -> wisp.not_found()
    StationTooFar -> wisp.not_found()
    TidesUnavailable(_) -> wisp.response(503)
    Database(_) -> wisp.internal_server_error()
  }
}

fn result_json(
  predictions: List(coordinate.TidePrediction),
  station: coordinate.TideStation,
) -> String {
  let predictions_json =
    predictions
    |> list.map(fn(p) {
      [
        #("time", json.string(datetime.to_string(p.time))),
        #("value", json.float(p.value)),
        #(
          "type",
          json.string(case p {
            coordinate.High(..) -> "High"
            coordinate.Low(..) -> "Low"
          }),
        ),
      ]
      |> json.object
    })

  let res = [
    #("stationId", json.string(station.station_id)),
    #("stationName", json.string(station.name)),
    #("timezone", json.string(station.timezone)),
    #("timezoneOffset", json.int(station.timezone_offset)),
    #("observeDst", json.bool(station.observe_dst)),
    #("predictions", json.preprocessed_array(predictions_json)),
  ]

  res |> json.object |> json.to_string
}

pub fn tide_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use coord <- coordinate.require_coord(coordinate.from_form(formdata))

  let result = {
    use tide_station <- result.try(
      queries.tide_station(ctx.db, coord) |> result.map_error(Database),
    )
    // Check to see if tide_station less than 100km from current location
    use <- bool.guard(
      when: tide_station.distance >. 100_000.0,
      return: Error(StationTooFar),
    )
    use predictions <- result.try(
      web.tides(tide_station) |> result.map_error(TidesUnavailable),
    )

    Ok(result_json(predictions, tide_station))
  }
  case result {
    Ok(json_res) -> wisp.json_response(json_res, 200)
    Error(err) -> tide_error_response(err)
  }
}
