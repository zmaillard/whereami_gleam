export function getPlace(reverseGeocode) {
  if (reverseGeocode) {
    return `${reverseGeocode.place}, ${reverseGeocode.state}`;
  }
  return "";
}


export function getAbbreviatedPlace(reverseGeocode) {
  if (reverseGeocode) {
    return reverseGeocode.place;
  }
  return "";
}

export function lengthOfDay({ sunrise, sunset }) {
  const milliseconds = Math.abs(sunset - sunrise);
  const secs = Math.floor(Math.abs(milliseconds) / 1000);
  const mins = Math.floor(secs / 60);
  const hours = Math.floor(mins / 60);

  return `${hours % 24} hours and ${mins % 60} minutes`
}

export function formatTime(ms) {
  return new Date(ms).toLocaleTimeString("en-US");
}
