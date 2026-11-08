import utilities/weather.{Day, IconNotFound, Night, UnableToParse}

pub fn valid_weather_single_forecast_night_test() {
  let url = "https://api.weather.gov/icons/land/night/sct?size=medium"

  assert weather.weather_icon_parser(url) == Ok(Night("Partly cloudy"))
}

pub fn valid_weather_single_forecast_day_test() {
  let url = "https://api.weather.gov/icons/land/day/sct?size=medium"

  assert weather.weather_icon_parser(url) == Ok(Day("Partly cloudy"))
}

pub fn invalid_weather_single_forecast_wrong_time_of_day_test() {
  let url = "https://api.weather.gov/icons/land/inbetween/sct?size=medium"

  assert weather.weather_icon_parser(url) == Error(IconNotFound)
}

pub fn valid_weather_single_forecast_pops_night_test() {
  let url =
    "https://api.weather.gov/icons/land/night/rain_showers,30?size=medium"

  assert weather.weather_icon_parser(url)
    == Ok(Night("Rain showers (high cloud cover)"))
}

pub fn valid_weather_single_forecast_pops_day_test() {
  let url = "https://api.weather.gov/icons/land/day/rain_showers,30?size=medium"

  assert weather.weather_icon_parser(url)
    == Ok(Day("Rain showers (high cloud cover)"))
}

pub fn invalid_weather_single_forecast_pops_wrong_time_of_day_test() {
  let url =
    "https://api.weather.gov/icons/land/inbetween/rain_showers,30?size=medium"

  assert weather.weather_icon_parser(url) == Error(IconNotFound)
}

pub fn valid_weather_multiple_forecast_pops_night_test() {
  let url =
    "https://api.weather.gov/icons/land/night/rain_showers,30/snow,40?size=medium"

  assert weather.weather_icon_parser(url)
    == Ok(Night("Rain showers (high cloud cover)"))
}

pub fn valid_weather_multiple_forecast_pops_day_test() {
  let url =
    "https://api.weather.gov/icons/land/day/rain_showers,30/snow,40?size=medium"

  assert weather.weather_icon_parser(url)
    == Ok(Day("Rain showers (high cloud cover)"))
}

pub fn invalid_weather_multiple_forecast_pops_wrong_time_of_day_test() {
  let url =
    "https://api.weather.gov/icons/land/inbetween/rain_showers,30/snow,40?size=medium"

  assert weather.weather_icon_parser(url) == Error(IconNotFound)
}

pub fn invalid_weather_url_tests() {
  assert weather.weather_icon_parser("https://api.weather.gov/icons")
    == Error(IconNotFound)
  assert weather.weather_icon_parser(
      "https://api.weather.gov/flapjack/land/night/sct?size=medium",
    )
    == Error(IconNotFound)
  assert weather.weather_icon_parser("https://api.weather.gov/icons/land")
    == Error(IconNotFound)
  assert weather.weather_icon_parser(
      "https://api.weather.gov/icons/land/night/veryinvalid?size=medium",
    )
    == Error(IconNotFound)
  assert weather.weather_icon_parser(
      "weather.gov/icons/land/night/veryinvalid?size=medium",
    )
    == Error(UnableToParse)
}
