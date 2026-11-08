import gleam/result
import gleam/string
import gleam/uri

pub type IconError {
  UnableToParse
  IconNotFound
}

pub type Icon {
  Day(String)
  Night(String)
}

pub fn weather_icon_parser(icon_url: String) -> Result(Icon, IconError) {
  //"https://api.weather.gov/icons/land/night/sct?size=medium",
  use items <- result.try(
    uri.parse(icon_url) |> result.map_error(fn(_) { UnableToParse }),
  )

  case uri.path_segments(items.path) {
    ["icons", _, time, icon] -> handle_weather_forecast(time, icon)
    ["icons", _, time, icon, ..] -> handle_weather_forecast(time, icon)
    _ -> Error(IconNotFound)
  }
}

fn handle_weather_forecast(
  time: String,
  forecast: String,
) -> Result(Icon, IconError) {
  use icon <- result.try(case string.split(forecast, ",") {
    [i] -> weather_icon_lookup(i)
    [i, _] -> weather_icon_lookup(i)
    _ -> Error(IconNotFound)
  })

  case time {
    "day" -> Ok(Day(icon))
    "night" -> Ok(Night(icon))
    _ -> Error(IconNotFound)
  }
}

fn weather_icon_lookup(icon: String) -> Result(String, IconError) {
  let res = case icon {
    "skc" -> "Fair/clear"
    "few" -> "A few clouds"
    "sct" -> "Partly cloudy"
    "bkn" -> "Mostly cloudy"
    "ovc" -> "Overcast"
    "wind_skc" -> "Fair/clear and windy"
    "wind_few" -> "A few clouds and windy"
    "wind_sct" -> "Partly cloudy and windy"
    "wind_bkn" -> "Mostly cloudy and windy"
    "wind_ovc" -> "Overcast and windy"
    "snow" -> "Snow"
    "rain_snow" -> "Rain/snow"
    "rain_sleet" -> "Rain/sleet"
    "snow_sleet" -> "Snow/sleet"
    "fzra" -> "Freezing rain"
    "rain_fzra" -> "Rain/freezing rain"
    "snow_fzra" -> "Freezing rain/snow"
    "sleet" -> "Sleet"
    "rain" -> "Rain"
    "rain_showers" -> "Rain showers (high cloud cover)"
    "rain_showers_hi" -> "Rain showers (low cloud cover)"
    "tsra" -> "Thunderstorm (high cloud cover)"
    "tsra_sct" -> "Thunderstorm (medium cloud cover)"
    "tsra_hi" -> "Thunderstorm (low cloud cover)"
    "tornado" -> "Tornado"
    "hurricane" -> "Hurricane conditions"
    "tropical_storm" -> "Tropical storm conditions"
    "dust" -> "Dust"
    "smoke" -> "Smoke"
    "haze" -> "Haze"
    "hot" -> "Hot"
    "cold" -> "Cold"
    "blizzard" -> "Blizzard"
    "fog" -> "Fog/mist"
    _ -> ""
  }

  case res {
    "" -> Error(IconNotFound)
    _ -> Ok(res)
  }
}
// {
//     "@context": [
//         "https://geojson.org/geojson-ld/geojson-context.jsonld",
//         {
//             "@version": "1.1",
//             "wx": "https://api.weather.gov/ontology#",
//             "geo": "http://www.opengis.net/ont/geosparql#",
//             "unit": "http://codes.wmo.int/common/unit/",
//             "@vocab": "https://api.weather.gov/ontology#"
//         }
//     ],
//     "type": "Feature",
//     "geometry": {
//         "type": "Polygon",
//         "coordinates": [
//             [
//                 [
//                     -75.594,
//                     42.9314
//                 ],
//                 [
//                     -75.5897,
//                     42.9528
//                 ],
//                 [
//                     -75.619,
//                     42.9559
//                 ],
//                 [
//                     -75.6233,
//                     42.9345
//                 ],
//                 [
//                     -75.594,
//                     42.9314
//                 ]
//             ]
//         ]
//     },
//     "properties": {
//         "units": "us",
//         "forecastGenerator": "BaselineForecastGenerator",
//         "generatedAt": "2026-11-07T15:55:40+00:00",
//         "updateTime": "2026-11-07T11:13:53+00:00",
//         "validTimes": "2026-11-07T05:00:00+00:00/P7DT20H",
//         "elevation": {
//             "unitCode": "wmoUnit:m",
//             "value": 285.9024
//         },
//         "periods": [
//             {
//                 "number": 1,
//                 "name": "Today",
//                 "startTime": "2026-11-07T10:00:00-05:00",
//                 "endTime": "2026-11-07T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 48,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 92
//                 },
//                 "windSpeed": "10 mph",
//                 "windDirection": "NW",
//                 "icon": "https://api.weather.gov/icons/land/day/rain_showers,90?size=medium",
//                 "shortForecast": "Widespread Rain Showers",
//                 "detailedForecast": "Widespread rain showers. Cloudy, with a high near 48. Northwest wind around 10 mph. Chance of precipitation is 90%. New rainfall amounts between a tenth and quarter of an inch possible."
//             },
//             {
//                 "number": 2,
//                 "name": "Tonight",
//                 "startTime": "2026-11-07T18:00:00-05:00",
//                 "endTime": "2026-11-08T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 39,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 72
//                 },
//                 "windSpeed": "13 mph",
//                 "windDirection": "NW",
//                 "icon": "https://api.weather.gov/icons/land/night/rain_showers,70/rain_showers,60?size=medium",
//                 "shortForecast": "Chance Rain Showers",
//                 "detailedForecast": "A chance of rain showers. Cloudy, with a low around 39. Northwest wind around 13 mph, with gusts as high as 24 mph. Chance of precipitation is 70%. New rainfall amounts between a tenth and quarter of an inch possible."
//             },
//             {
//                 "number": 3,
//                 "name": "Sunday",
//                 "startTime": "2026-11-08T06:00:00-05:00",
//                 "endTime": "2026-11-08T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 55,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 29
//                 },
//                 "windSpeed": "7 to 14 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/day/rain_showers,30/sct?size=medium",
//                 "shortForecast": "Scattered Rain Showers then Mostly Sunny",
//                 "detailedForecast": "Scattered rain showers before 9am. Mostly sunny, with a high near 55. West wind 7 to 14 mph, with gusts as high as 26 mph. Chance of precipitation is 30%. New rainfall amounts less than a tenth of an inch possible."
//             },
//             {
//                 "number": 4,
//                 "name": "Sunday Night",
//                 "startTime": "2026-11-08T18:00:00-05:00",
//                 "endTime": "2026-11-09T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 38,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 89
//                 },
//                 "windSpeed": "7 to 17 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/night/rain_showers,20/rain_showers,90?size=medium",
//                 "shortForecast": "Rain Showers",
//                 "detailedForecast": "Rain showers after 7pm. Mostly cloudy, with a low around 38. West wind 7 to 17 mph, with gusts as high as 33 mph. Chance of precipitation is 90%. New rainfall amounts less than a tenth of an inch possible."
//             },
//             {
//                 "number": 5,
//                 "name": "Monday",
//                 "startTime": "2026-11-09T06:00:00-05:00",
//                 "endTime": "2026-11-09T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 49,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 89
//                 },
//                 "windSpeed": "13 to 17 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/day/rain_showers,90/rain_showers,80?size=medium",
//                 "shortForecast": "Rain Showers",
//                 "detailedForecast": "Rain showers. Mostly cloudy, with a high near 49. West wind 13 to 17 mph, with gusts as high as 33 mph. Chance of precipitation is 90%."
//             },
//             {
//                 "number": 6,
//                 "name": "Monday Night",
//                 "startTime": "2026-11-09T18:00:00-05:00",
//                 "endTime": "2026-11-10T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 36,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 43
//                 },
//                 "windSpeed": "7 to 12 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/night/rain_showers,40/rain_showers,20?size=medium",
//                 "shortForecast": "Chance Rain Showers",
//                 "detailedForecast": "A chance of rain showers before 1am. Mostly cloudy, with a low around 36. Chance of precipitation is 40%."
//             },
//             {
//                 "number": 7,
//                 "name": "Tuesday",
//                 "startTime": "2026-11-10T06:00:00-05:00",
//                 "endTime": "2026-11-10T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 57,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 14
//                 },
//                 "windSpeed": "8 to 14 mph",
//                 "windDirection": "SW",
//                 "icon": "https://api.weather.gov/icons/land/day/bkn?size=medium",
//                 "shortForecast": "Partly Sunny",
//                 "detailedForecast": "Partly sunny, with a high near 57."
//             },
//             {
//                 "number": 8,
//                 "name": "Tuesday Night",
//                 "startTime": "2026-11-10T18:00:00-05:00",
//                 "endTime": "2026-11-11T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 39,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 21
//                 },
//                 "windSpeed": "8 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/night/rain_showers,20?size=medium",
//                 "shortForecast": "Slight Chance Rain Showers",
//                 "detailedForecast": "A slight chance of rain showers after 7pm. Mostly cloudy, with a low around 39."
//             },
//             {
//                 "number": 9,
//                 "name": "Veterans Day",
//                 "startTime": "2026-11-11T06:00:00-05:00",
//                 "endTime": "2026-11-11T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 52,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 25
//                 },
//                 "windSpeed": "6 to 10 mph",
//                 "windDirection": "W",
//                 "icon": "https://api.weather.gov/icons/land/day/rain_showers,30?size=medium",
//                 "shortForecast": "Chance Rain Showers",
//                 "detailedForecast": "A chance of rain showers. Partly sunny, with a high near 52. Chance of precipitation is 30%."
//             },
//             {
//                 "number": 10,
//                 "name": "Wednesday Night",
//                 "startTime": "2026-11-11T18:00:00-05:00",
//                 "endTime": "2026-11-12T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 32,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 35
//                 },
//                 "windSpeed": "3 mph",
//                 "windDirection": "NW",
//                 "icon": "https://api.weather.gov/icons/land/night/rain_showers,30/snow,40?size=medium",
//                 "shortForecast": "Chance Rain Showers then Chance Rain And Snow Showers",
//                 "detailedForecast": "A chance of rain showers before 4am, then a chance of rain and snow showers between 4am and 5am, then a chance of rain and snow. Mostly cloudy, with a low around 32. Chance of precipitation is 40%."
//             },
//             {
//                 "number": 11,
//                 "name": "Thursday",
//                 "startTime": "2026-11-12T06:00:00-05:00",
//                 "endTime": "2026-11-12T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 47,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 35
//                 },
//                 "windSpeed": "2 to 6 mph",
//                 "windDirection": "NW",
//                 "icon": "https://api.weather.gov/icons/land/day/snow,40/snow,30?size=medium",
//                 "shortForecast": "Chance Light Snow",
//                 "detailedForecast": "A chance of snow before 7am, then a chance of rain and snow. Mostly cloudy, with a high near 47. Chance of precipitation is 40%."
//             },
//             {
//                 "number": 12,
//                 "name": "Thursday Night",
//                 "startTime": "2026-11-12T18:00:00-05:00",
//                 "endTime": "2026-11-13T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 28,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 36
//                 },
//                 "windSpeed": "5 mph",
//                 "windDirection": "N",
//                 "icon": "https://api.weather.gov/icons/land/night/snow,30/snow,40?size=medium",
//                 "shortForecast": "Chance Rain And Snow",
//                 "detailedForecast": "A chance of rain before 9pm, then a chance of rain and snow. Mostly cloudy, with a low around 28. Chance of precipitation is 40%."
//             },
//             {
//                 "number": 13,
//                 "name": "Friday",
//                 "startTime": "2026-11-13T06:00:00-05:00",
//                 "endTime": "2026-11-13T18:00:00-05:00",
//                 "isDaytime": true,
//                 "temperature": 43,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 37
//                 },
//                 "windSpeed": "3 to 8 mph",
//                 "windDirection": "N",
//                 "icon": "https://api.weather.gov/icons/land/day/snow,40/rain,40?size=medium",
//                 "shortForecast": "Chance Light Snow then Chance Light Rain",
//                 "detailedForecast": "A chance of snow before 9am, then a chance of rain. Partly sunny, with a high near 43. Chance of precipitation is 40%."
//             },
//             {
//                 "number": 14,
//                 "name": "Friday Night",
//                 "startTime": "2026-11-13T18:00:00-05:00",
//                 "endTime": "2026-11-14T06:00:00-05:00",
//                 "isDaytime": false,
//                 "temperature": 26,
//                 "temperatureUnit": "F",
//                 "temperatureTrend": null,
//                 "probabilityOfPrecipitation": {
//                     "unitCode": "wmoUnit:percent",
//                     "value": 30
//                 },
//                 "windSpeed": "6 mph",
//                 "windDirection": "N",
//                 "icon": "https://api.weather.gov/icons/land/night/snow,30?size=medium",
//                 "shortForecast": "Chance Light Snow",
//                 "detailedForecast": "A chance of rain before 7pm, then a chance of snow. Mostly cloudy, with a low around 26."
//             }
//         ]
//     }
// }
// /*
//
//
//
// */
