export function searchApi(fetchFn = fetch) {
  const get = (query, token) => fetchFn(
    `https://api.mapbox.com/search/geocode/v6/forward?q=${encodeURIComponent(query)}&access_token=${encodeURIComponent(token)}&autocomplete=false&country=us`,
  )
  .then((r) => r.json())

  return {
    reverse: (query, token) => get(query, token)
  }
}

export function locateApi(fetchFn = fetch) {
  const post = (path, params) =>
    fetchFn(path, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams(params),
    }).then((r) => r.json());

  return {
    political: (coords) => post("/political", coords),
    forecast: (coords) => post("/forecast", coords),
    physical: (coords) => post("/physical", coords),
    geocode: (coords) => post("/geocode", coords),
  };
}
