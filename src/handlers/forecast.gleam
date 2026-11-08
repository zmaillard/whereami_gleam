import context.{type Context}
import coordinate
import error
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import location/queries
import location/web
import utilities/weather.{Day, Night}
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
  weather_forecast: coordinate.WeatherForecast,
  summit: coordinate.Summit,
  office: String,
) -> String {
  let current_elevation = weather_forecast.elevation
  let icon_res = fn(icon: Option(weather.Icon)) -> Option(
    List(#(String, json.Json)),
  ) {
    case icon {
      Some(Day(icon_desc)) ->
        Some([#("time", json.string("day")), #("type", json.string(icon_desc))])
      Some(Night(icon_desc)) ->
        Some([
          #("time", json.string("night")),
          #("type", json.string(icon_desc)),
        ])
      _ -> None
    }
  }

  let weather_res = [
    #(
      "time",
      json.object([
        #("sunset", json.string(weather_forecast.sunset)),
        #("sunrise", json.string(weather_forecast.sunrise)),
        #("timezone", json.string(weather_forecast.time_zone)),
      ]),
    ),
    #(
      "weather",
      json.object([
        #("office_abbreviation", json.string(weather_forecast.office)),
        #("office", json.string(office)),
        #(
          "forecast_wind_direction_1",
          json.nullable(
            weather_forecast.forecast1_wind_direction,
            of: json.string,
          ),
        ),
        #(
          "forecast_wind_direction_2",
          json.nullable(
            weather_forecast.forecast2_wind_direction,
            of: json.string,
          ),
        ),
        #(
          "forecast_wind_speed_1",
          json.nullable(weather_forecast.forecast1_wind_speed, of: json.string),
        ),
        #(
          "forecast_wind_speed_2",
          json.nullable(weather_forecast.forecast2_wind_speed, of: json.string),
        ),
        #(
          "forecast_short_forecast_1",
          json.nullable(
            weather_forecast.forecast1_short_forecast,
            of: json.string,
          ),
        ),
        #(
          "forecast_short_forecast_2",
          json.nullable(
            weather_forecast.forecast2_short_forecast,
            of: json.string,
          ),
        ),
        #(
          "forecast_temperature_1",
          json.nullable(weather_forecast.forecast1_temperature, of: json.int),
        ),
        #(
          "forecast_temperature_2",
          json.nullable(weather_forecast.forecast2_temperature, of: json.int),
        ),
        #(
          "forecast_details_1",
          json.nullable(weather_forecast.forecast1_details, of: json.string),
        ),
        #(
          "forecast_details_2",
          json.nullable(weather_forecast.forecast2_details, of: json.string),
        ),
        #(
          "forecast_1",
          json.nullable(weather_forecast.forecast1, of: json.string),
        ),
        #(
          "forecast_2",
          json.nullable(weather_forecast.forecast2, of: json.string),
        ),
        #(
          "forecast_icon_1",
          json.nullable(
            icon_res(weather_forecast.forecast1_icon),
            of: json.object,
          ),
        ),
        #(
          "forecast_icon_2",
          json.nullable(
            icon_res(weather_forecast.forecast2_icon),
            of: json.object,
          ),
        ),
      ]),
    ),
  ]

  let summit_res = [
    #(
      "topography",
      json.object([
        #("nearestSummit", json.string(summit.name)),
        #("nearestSummitBearing", json.string(summit.bearing)),
        #("nearestSummitElevation", json.float(summit.elevation)),
        #("nearestSummitDistance", json.float(summit.distance)),
        #("nearestSummitLatitude", json.float(summit.latitude)),
        #("nearestSummitLongitude", json.float(summit.longitude)),
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
      queries.summit(ctx.db, coord, weather.elevation)
      |> result.map_error(SummitNotFound),
    )

    Ok(result_json(weather, summit, office))
  }
  case result {
    Ok(json_res) -> wisp.json_response(json_res, 200)
    Error(e) -> forecast_error_response(e)
  }
}
