import coordinate
import wisp

pub fn from_form_valid_test() {
  let formdata =
    wisp.FormData(values: [#("lat", "37.5"), #("lng", "-122.25")], files: [])

  assert coordinate.from_form(formdata)
    == Ok(coordinate.Coordinate(latitude: 37.5, longitude: -122.25))
}

pub fn from_form_missing_lat_test() {
  let formdata = wisp.FormData(values: [#("lng", "-122.25")], files: [])

  assert coordinate.from_form(formdata) == Error(Nil)
}

pub fn from_form_missing_lng_test() {
  let formdata = wisp.FormData(values: [#("lat", "37.5")], files: [])

  assert coordinate.from_form(formdata) == Error(Nil)
}

pub fn from_form_empty_test() {
  let formdata = wisp.FormData(values: [], files: [])

  assert coordinate.from_form(formdata) == Error(Nil)
}

pub fn from_form_non_numeric_test() {
  let formdata =
    wisp.FormData(values: [#("lat", "abc"), #("lng", "-122.25")], files: [])

  assert coordinate.from_form(formdata) == Error(Nil)
}

pub fn from_form_ignores_extra_fields_test() {
  let formdata =
    wisp.FormData(
      values: [#("lat", "1.0"), #("lng", "2.0"), #("other", "x")],
      files: [],
    )

  assert coordinate.from_form(formdata)
    == Ok(coordinate.Coordinate(latitude: 1.0, longitude: 2.0))
}

pub fn require_coord_ok_calls_next_test() {
  let coord = coordinate.Coordinate(latitude: 1.0, longitude: 2.0)

  let response =
    coordinate.require_coord(Ok(coord), fn(c) {
      assert c == coord
      wisp.response(204)
    })

  assert response.status == 204
}

pub fn require_coord_error_returns_bad_request_test() {
  let response =
    coordinate.require_coord(Error(Nil), fn(_) { wisp.response(204) })

  assert response.status == 400
}

pub fn round_coordinates_rounds_to_two_decimals_test() {
  let coord = coordinate.Coordinate(latitude: 37.12345, longitude: -122.98765)

  assert coordinate.round_coordinates(coord) == #("37.12", "-122.99")
}

pub fn round_coordinates_zero_test() {
  let coord = coordinate.Coordinate(latitude: 0.0, longitude: 0.0)

  assert coordinate.round_coordinates(coord) == #("0.0", "0.0")
}

pub fn predictions_from_json_parses_high_and_low_test() {
  let json =
    "{\"predictions\":[{\"t\":\"2026-10-23 15:19\",\"v\":1.2,\"type\":\"H\"},{\"t\":\"2026-10-23 21:40\",\"v\":-0.3,\"type\":\"L\"}]}"

  let assert Ok([coordinate.High(_, high_value), coordinate.Low(_, low_value)]) =
    coordinate.predictions_from_json(json)

  assert high_value == 1.2
  assert low_value == -0.3
}

pub fn predictions_from_json_empty_list_test() {
  assert coordinate.predictions_from_json("{\"predictions\":[]}") == Ok([])
}

pub fn predictions_from_json_invalid_type_test() {
  let json =
    "{\"predictions\":[{\"t\":\"2026-10-23 15:19\",\"v\":1.2,\"type\":\"X\"}]}"

  assert coordinate.predictions_from_json(json) |> is_error
}

pub fn predictions_from_json_malformed_test() {
  assert coordinate.predictions_from_json("not json") |> is_error
}

pub fn reverse_geocode_place_json_test() {
  let json =
    coordinate.reverse_geocode_to_json(coordinate.Place("Boise", "ID"))

  assert json == "{\"place\":\"Boise\",\"state\":\"ID\"}"
}

pub fn reverse_geocode_nearest_place_json_test() {
  let json =
    coordinate.reverse_geocode_to_json(coordinate.NearestPlace(
      "Boise",
      "ID",
      12.5,
      "NE",
    ))

  assert json
    == "{\"place\":\"Boise\",\"state\":\"ID\",\"distance\":12.5,\"bearing_direction\":\"NE\"}"
}

pub fn reverse_geocode_escapes_quotes_test() {
  let json =
    coordinate.reverse_geocode_to_json(coordinate.Place("Say \"Hi\"", "ID"))

  assert json == "{\"place\":\"Say \\\"Hi\\\"\",\"state\":\"ID\"}"
}

fn is_error(result: Result(a, b)) -> Bool {
  case result {
    Error(_) -> True
    Ok(_) -> False
  }
}
