import coordinate
import error
import gleam/dynamic/decode
import gleam/float
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import tempo/datetime
import tempo/duration
import tide

type ElevationResponse {
  ElevationResponse(value: Float)
}

fn elevation_from_json(
  json_string: String,
) -> Result(ElevationResponse, json.DecodeError) {
  let elevation_decoder = {
    use value <- decode.field("value", decode.float)
    decode.success(ElevationResponse(value:))
  }
  json.parse(from: json_string, using: elevation_decoder)
}

type MetadataResponse {
  MetadataResponse(
    office: String,
    forecast: String,
    sunrise: String,
    sunset: String,
    time_zone: String,
  )
}

fn metadata_from_json(
  json_string: String,
) -> Result(MetadataResponse, json.DecodeError) {
  let metadata_decoder = {
    use office <- decode.subfield(["properties", "cwa"], decode.string)
    use forecast <- decode.subfield(["properties", "forecast"], decode.string)
    use sunrise <- decode.subfield(
      ["properties", "astronomicalData", "sunrise"],
      decode.string,
    )
    use sunset <- decode.subfield(
      ["properties", "astronomicalData", "sunset"],
      decode.string,
    )
    use time_zone <- decode.subfield(["properties", "timeZone"], decode.string)
    decode.success(MetadataResponse(
      office:,
      forecast:,
      sunrise:,
      sunset:,
      time_zone:,
    ))
  }
  json.parse(from: json_string, using: metadata_decoder)
}

type ForecastResponse {
  ForecastResponse(elevation: Float, periods: List(Period))
}

type Period {
  Period(name: String, detailed_forecast: String)
}

fn forecast_from_json(
  json_string: String,
) -> Result(ForecastResponse, json.DecodeError) {
  let period_decoder = {
    use name <- decode.field("name", decode.string)
    use detailed_forecast <- decode.field("detailedForecast", decode.string)
    decode.success(Period(name:, detailed_forecast:))
  }

  let forecast_decoder = {
    use items <- decode.subfield(
      ["properties", "periods"],
      decode.list(period_decoder),
    )
    use elevation <- decode.subfield(
      ["properties", "elevation", "value"],
      decode.float,
    )

    decode.success(ForecastResponse(elevation, items))
  }

  json.parse(from: json_string, using: forecast_decoder)
}

pub fn weather(
  coords: coordinate.Coordinate,
) -> Result(coordinate.WeatherForecast, error.HttpError) {
  let #(lat, lng) = coordinate.round_coordinates(coords)
  let url = "https://api.weather.gov/points/" <> lat <> "," <> lng
  let assert Ok(base_req) = request.to(url)
  let req = request.prepend_header(base_req, "accept", "application/json")

  // Send the HTTP request to the server
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(error.HttpcError),
  )

  use value <- result.try(
    metadata_from_json(resp.body) |> result.map_error(error.JsonDecodingError),
  )

  let assert Ok(base_req) = request.to(value.forecast)
  let req = request.prepend_header(base_req, "accept", "application/json")

  // Send the HTTP request to the server
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(error.HttpcError),
  )
  use forecast_value <- result.try(
    forecast_from_json(resp.body) |> result.map_error(error.JsonDecodingError),
  )

  let forecast1 = list.first(forecast_value.periods) |> option.from_result
  let forecast2 =
    forecast_value.periods
    |> list.rest
    |> result.try(list.first)
    |> option.from_result

  let weather_forecast =
    coordinate.WeatherForecast(
      office: value.office,
      sunrise: value.sunrise,
      sunset: value.sunset,
      time_zone: value.time_zone,
      forecast1: forecast1 |> option.map(fn(f) { f.name }),
      forecast1_details: forecast1 |> option.map(fn(f) { f.detailed_forecast }),
      forecast2: forecast2 |> option.map(fn(f) { f.name }),
      forecast2_details: forecast2 |> option.map(fn(f) { f.detailed_forecast }),
      elevation: forecast_value.elevation,
    )

  Ok(weather_forecast)
}

pub fn elevation(
  coords: coordinate.Coordinate,
) -> Result(Float, error.HttpError) {
  let url =
    "https://epqs.nationalmap.gov/v1/json?x="
    <> float.to_string(coords.longitude)
    <> "&y="
    <> float.to_string(coords.latitude)
    <> "&wkid=4326&units=Feet&includeDate=false"
  let assert Ok(base_req) = request.to(url)
  let req = request.prepend_header(base_req, "accept", "application/json")

  // Send the HTTP request to the server
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(error.HttpcError),
  )

  use value <- result.try(
    elevation_from_json(resp.body) |> result.map_error(error.JsonDecodingError),
  )

  Ok(value.value)
}

fn aqi_from_json(
  json_string: String,
) -> Result(List(coordinate.AQI), json.DecodeError) {
  let record_decoder = {
    use date_issue <- decode.field("dateIssue", decode.string)
    use date_valid <- decode.field("dateValid", decode.string)
    use reporting_area <- decode.field("reportingArea", decode.string)
    use reporting_area_code <- decode.field("reportingAreaCode", decode.string)
    use state_code <- decode.field("stateCode", decode.string)
    use parameter_name <- decode.field("parameterName", decode.string)
    use value <- decode.field("aqi", decode.int)
    use forecast_agency <- decode.field("forecastAgency", decode.string)
    use category_number <- decode.field("categoryNumber", decode.int)
    use category_name <- decode.field("categoryName", decode.string)
    use action_day <- decode.field("actionDay", decode.bool)
    use discussion <- decode.field("discussion", decode.string)

    decode.success(coordinate.AQI(
      date_issue:,
      date_valid:,
      reporting_area:,
      reporting_area_code:,
      state_code:,
      parameter_name:,
      value:,
      forecast_agency:,
      category_number:,
      category_name:,
      action_day:,
      discussion:,
    ))
  }

  json.parse(from: json_string, using: decode.list(record_decoder))
}

pub fn aqi(
  coords: coordinate.Coordinate,
  aqi_token: String,
) -> Result(List(coordinate.AQI), error.HttpError) {
  let url =
    "https://www.airnowapi.org/aq/forecast/current/?format=application/json&latitude="
    <> float.to_string(coords.latitude)
    <> "&longitude="
    <> float.to_string(coords.longitude)
    <> "&API_KEY="
    <> aqi_token
  let assert Ok(base_req) = request.to(url)
  let req = request.prepend_header(base_req, "accept", "application/json")

  // Send the HTTP request to the server
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(error.HttpcError),
  )

  use value <- result.try(
    aqi_from_json(resp.body) |> result.map_error(error.JsonDecodingError),
  )

  Ok(value)
}

pub fn tides(
  tide_station: coordinate.TideStation,
) -> Result(List(coordinate.TidePrediction), error.HttpError) {
  let #(start, end) = tide.get_tide_date()
  let datum = "MLLW"
  // may use a variable in the future
  let units = "english"
  // may use a variable in the future - other value is metric
  let url =
    "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date="
    <> start
    <> "&end_date="
    <> end
    <> "&station="
    <> tide_station.station_id
    <> "&product=predictions&datum="
    <> datum
    <> "&time_zone=gmt&interval=hilo&units="
    <> units
    <> "&application=whereami&format=json"
  let assert Ok(base_req) = request.to(url)
  let req = request.prepend_header(base_req, "accept", "application/json")

  // Send the HTTP request to the server
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(error.HttpcError),
  )

  use value <- result.try(
    coordinate.predictions_from_json(resp.body)
    |> result.map_error(error.JsonDecodingError),
  )

  let fix_date =
    value
    |> list.map(fn(x) { apply_time_offset(x, tide_station.timezone_offset) })

  Ok(fix_date)
}

fn apply_time_offset(
  val: coordinate.TidePrediction,
  offset: Int,
) -> coordinate.TidePrediction {
  let pred_offset = val.time |> datetime.add(duration.hours(offset))
  case val {
    coordinate.High(_, v) -> coordinate.High(time: pred_offset, value: v)
    coordinate.Low(_, v) -> coordinate.Low(time: pred_offset, value: v)
  }
}
