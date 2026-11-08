export function lengthOfDay({ sunrise, sunset }) {
  const milliseconds = Math.abs(sunset - sunrise);
  const secs = Math.floor(Math.abs(milliseconds) / 1000);
  const mins = Math.floor(secs / 60);
  const hours = Math.floor(mins / 60);

  return `${hours % 24} hours and ${mins % 60} minutes`;
}

export function formatTime(ms, timeZone) {
  return new Date(ms).toLocaleTimeString("en-US", {
    timeZone,
  });
}

export function timeDetails(snow, place) {
  return `It is ${snow.format("time")} in ${place}.`;
}

export function energyIconFromNwsIconDescription(prefix, timeOfDay, desc) {
  let lookup = (d, t) => {
    switch (d) {
      case "Fair/clear":
        return t == "day" ? "sun-dim" : "moon";
      case "A few clouds":
      case "Partly cloudy":
        return t == "day" ? "cloud-sun" : "cloud-moon";
      case "Mostly cloudy":
      case "Overcast":
        return "cloud";
      case "Fair/clear and windy":
      case "A few clouds and windy":
        return "sandstorm";
      case "Partly cloudy and windy":
      case "Mostly cloudy and windy":
      case "Overcast and windy":
        return "cloud-wind";
      case "Snow":
      case "Blizzard":
        return "cloud-snow";
      case "Rain/snow":
      case "Rain/sleet":
      case "Snow/sleet":
      case "Freezing rain":
      case "Rain/freezing rain":
      case "Freezing rain/snow":
      case "Sleet":
        return "freezing-rain";
      case "Rain":
      case "Rain showers (high cloud cover)":
      case "Rain showers (low cloud cover)":
        return "cloud-rain";
      case "Thunderstorm (high cloud cover)":
      case "Thunderstorm (medium cloud cover)":
      case "Thunderstorm (low cloud cover)":
        return "storm";
      case "Tornado":
        return "tornado";
      case "Hurricane conditions":
      case "Tropical storm conditions":
        return "hurricane";
      case "Dust":
      case "Haze":
        return "haze";
      case "Smoke":
        return "wildfire";
      case "Hot":
        return "heatwave";
      case "Cold":
        return "thermometer-snowflake";
      case "Fog/mist":
        return "cloud-fog";
      default:
        "";
    }
  }

  let res = lookup(desc, timeOfDay)
  if (res)
    return `${prefix}${res}`
  else
    return "";
}
