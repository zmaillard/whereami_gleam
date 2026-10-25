import context.{type Context}
import coordinate
import error
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/result
import location/queries
import location/web
import wisp.{type Request, type Response}

pub type ForecastError {
  WeatherUnavailable(error.HttpError)
  OfficeNotFound(error.DatabaseError)
  SummitNotFound(error.DatabaseError)
}

fn forecast_error_response(err: ForecastError) -> Response {
  case err {
    WeatherUnavailable(_) -> wisp.internal_server_error()
    OfficeNotFound(_) -> wisp.not_found()
    SummitNotFound(_) -> wisp.not_found()
  }
}

fn result_json(
  weather: coordinate.WeatherForecast,
  summit: coordinate.Summit,
  office: String,
) -> String {
  let current_elevation = weather.elevation
  let weather_res = [
    #(
      "time",
      json.object([
        #("sunset", json.string(weather.sunset)),
        #("sunrise", json.string(weather.sunrise)),
        #("timezone", json.string(weather.time_zone)),
      ]),
    ),
    #(
      "weather",
      json.object([
        #("office_abbreviation", json.string(weather.office)),
        #("office", json.string(office)),
        #(
          "forecast_details_1",
          json.nullable(weather.forecast1_details, of: json.string),
        ),
        #(
          "forecast_details_2",
          json.nullable(weather.forecast2_details, of: json.string),
        ),
        #("forecast_1", json.nullable(weather.forecast1, of: json.string)),
        #("forecast_2", json.nullable(weather.forecast2, of: json.string)),
      ]),
    ),
  ]

  let summit_res = [
    #(
      "topography",
      json.object([
        #("nearest_summit", json.string(summit.name)),
        #("nearest_summit_bearing", json.string(summit.bearing)),
        #("nearest_summit_elevation", json.float(summit.elevation)),
        #("nearest_summit_distance", json.float(summit.distance)),
        #("elevation", json.float(current_elevation)),
      ]),
    ),
  ]

  weather_res
  |> list.append(summit_res)
  |> json.object
  |> json.to_string
}

pub fn forecast_handler(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use formdata <- wisp.require_form(req)
  use coord <- coordinate.require_coord(coordinate.from_form(formdata))

  let result = {
    use weather <- result.try(
      web.weather(coord) |> result.map_error(WeatherUnavailable),
    )
    use office <- result.try(
      queries.nws_office(ctx.db, weather.office)
      |> result.map_error(OfficeNotFound),
    )
    use summit <- result.try(
      queries.summit(ctx.db, coord, weather.elevation *. 3.281)
      |> result.map_error(SummitNotFound),
    )

    Ok(result_json(weather, summit, office))
  }
  case result {
    Ok(json_res) -> wisp.json_response(json_res, 200)
    Error(e) -> forecast_error_response(e)
  }
}
