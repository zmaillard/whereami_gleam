import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import tempo
import tempo/datetime
import tempo/instant
import wisp

pub type TidePrediction {
  High(time: tempo.DateTime, value: Float)
  Low(time: tempo.DateTime, value: Float)
}

pub fn predictions_from_json(
  json_string: String,
) -> Result(List(TidePrediction), json.DecodeError) {
  let time_decoder = {
    use string_type <- decode.then(decode.string)

    case datetime.from_string(string_type <> ":00.0Z") {
      Ok(date) -> decode.success(date)
      _ ->
        decode.failure(
          instant.now() |> instant.as_local_datetime,
          expected: "DateTime",
        )
    }
  }

  let record_decoder = {
    use time <- decode.field("t", time_decoder)
    use value <- decode.field("v", decode.float)
    use prediction_type <- decode.field("t", decode.string)

    case prediction_type {
      "H" -> decode.success(High(time:, value:))
      "L" -> decode.success(Low(time:, value:))
      _ ->
        decode.failure(
          High(time: instant.now() |> instant.as_local_datetime, value: 0.0),
          expected: "TidePrediction",
        )
    }
  }

  let records_decoder = {
    use records_decoder <- decode.field(
      "predictions",
      decode.list(record_decoder),
    )

    decode.success(records_decoder)
  }

  json.parse(from: json_string, using: records_decoder)
}

pub type TideStation {
  TideStation(
    name: String,
    station_id: String,
    timezone: String,
    observe_dst: Bool,
    timezone_offset: Int,
    distance: Float,
  )
}

pub type Ecoregion {
  Ecoregion(
    level1_code: String,
    level1_description: String,
    level2_code: String,
    level2_description: String,
    level3_code: String,
    level3_description: String,
  )
}

pub type ReverseGeocode {
  Place(place: String, state: String)
  NearestPlace(name: String, state: String, distance: Float, bearing: String)
}

pub fn reverse_geocode_to_json(reverse_geocode: ReverseGeocode) -> String {
  case reverse_geocode {
    Place(place, state) -> {
      json.object([
        #("place", json.string(place)),
        #("state", json.string(state)),
      ])
    }
    NearestPlace(name, state, distance, bearing) -> {
      json.object([
        #("place", json.string(name)),
        #("state", json.string(state)),
        #("distance", json.float(distance)),
        #("bearing_direction", json.string(bearing)),
      ])
    }
  }
  |> json.to_string
}

pub type AQI {
  AQI(
    date_issue: String,
    date_valid: String,
    reporting_area: String,
    reporting_area_code: String,
    state_code: String,
    parameter_name: String,
    value: Int,
    forecast_agency: String,
    category_number: Int,
    category_name: String,
    action_day: Bool,
    discussion: String,
  )
}

pub type Coordinate {
  Coordinate(latitude: Float, longitude: Float)
}

pub fn require_coord(
  coord: Result(Coordinate, Nil),
  next: fn(Coordinate) -> wisp.Response,
) -> wisp.Response {
  case coord {
    Ok(c) -> next(c)
    Error(_) -> wisp.bad_request("missing latitude and longitude")
  }
}

pub fn from_form(formdata: wisp.FormData) -> Result(Coordinate, Nil) {
  use lat <- result.try(list.key_find(formdata.values, "lat"))
  use lng <- result.try(list.key_find(formdata.values, "lng"))
  use lat_float <- result.try(float.parse(lat))
  use lng_float <- result.try(float.parse(lng))

  Ok(Coordinate(lat_float, lng_float))
}

pub fn round_coordinates(coord: Coordinate) -> #(String, String) {
  let lat_str =
    coord.latitude *. 100.0
    |> float.round
    |> int.to_float
    |> float.divide(100.0)
    |> result.unwrap(0.0)
    |> float.to_string

  let lng_str =
    coord.longitude *. 100.0
    |> float.round
    |> int.to_float
    |> float.divide(100.0)
    |> result.unwrap(0.0)
    |> float.to_string

  #(lat_str, lng_str)
}

pub type CongressionalDistrict {
  CongressionalDistrict(String)
}

pub type County {
  County(name: String, state: String)
}

pub type NationalPark {
  NationalPark(name: String, distance: Float, bearing: String)
}

pub type WeatherForecast {
  WeatherForecast(
    office: String,
    sunrise: String,
    sunset: String,
    time_zone: String,
    forecast1: Option(String),
    forecast1_details: Option(String),
    forecast2: Option(String),
    forecast2_details: Option(String),
    elevation: Float,
  )
}

pub type Summit {
  Summit(name: String, elevation: Float, distance: Float, bearing: String)
}

pub type PopulatedPlace {
  Incorporated(name: String, state: String)
  Unincorporated(name: String, state: String)
}
