import { describe, it, expect, vi, beforeEach } from "vitest";
import { locateComponent } from "../../priv/static/js/locate/component.js";
import spacetime from "spacetime";

function makeGeolocation(result) {
  return {
    getCurrentPosition: vi.fn((ok, err) => {
      if (result.error) err(result.error);
      else ok(result.position);
    }),
  };
}

function makeApi(overrides = {}) {
  return {
    geocode: vi.fn(async () => ({ place: "Boise", state: "ID" })),
    political: vi.fn(async () => ({})),
    physical: vi.fn(async () => ({})),
    forecast: vi.fn(async () => ({})),
    ...overrides,
  };
}

function makeL() {
  const mapInstance = { setView: vi.fn(), invalidateSize: vi.fn() };
  mapInstance.setView.mockReturnValue(mapInstance);
  const group = { addTo: vi.fn().mockReturnThis(), addLayer: vi.fn(), clearLayers: vi.fn() };
  return {
    L: {
      map: vi.fn(() => mapInstance),
      tileLayer: vi.fn(() => ({ addTo: vi.fn() })),
      layerGroup: vi.fn(() => group),
      marker: vi.fn((latlng) => ({ latlng })),
      geoJSON: vi.fn((data) => ({ data })),
    },
    mapInstance,
    group,
  };
}

describe("locateComponent", () => {
  it("sets coordinates and place on successful geolocation", async () => {
    const api = makeApi();
    const geolocation = makeGeolocation({ position: { coords: { latitude: 43.6, longitude: -116.2 } } });
    const c = locateComponent({ api, geolocation });

    c.init();
    await vi.waitFor(() => expect(c.place).toBe("Boise"));

    expect(c.latitude).toBe(43.6);
    expect(c.longitude).toBe(-116.2);
    expect(c.isCurrentLocation).toBe(true);
    expect(api.geocode).toHaveBeenCalledWith({ lat: 43.6, lng: -116.2 });
  });

  it("falls back to search when geolocation fails", () => {
    const geolocation = makeGeolocation({ error: { code: 1, message: "denied" } });
    const c = locateComponent({ api: makeApi(), geolocation });

    c.init();

    expect(c.showSearch).toBe(true);
    expect(c.isCurrentLocation).toBe(false);
  });

  it("toggle flips showSearch", () => {
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }) });
    expect(c.showSearch).toBe(false);
    c.toggle();
    expect(c.showSearch).toBe(true);
  });

  it("merges political, physical, and forecast results", async () => {
    const api = makeApi({
      political: vi.fn(async () => ({ county: "Ada", state: "ID" })),
      physical: vi.fn(async () => ({ drainage: ["Boise River"] })),
      forecast: vi.fn(async () => ({
        time: { sunrise: "2024-06-01T12:00:00Z", sunset: "2024-06-02T02:00:00Z", timezone: "America/Boise" },
      })),
    });
    const { L } = makeL();
    const c = locateComponent({ api, geolocation: makeGeolocation({ position: { coords: {} } }), L, spacetime, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;

    c.locate({});
    await vi.waitFor(() => expect(c.isLoaded).toBe(true));

    expect(c.results.county).toBe("Ada");
    expect(c.results.drainage).toEqual(["Boise River"]);
    expect(c.results.time.timezone).toBe("America/Boise");
    expect(c.countyStateFormatted()).toBe("Ada, ID");
  });

  it("search updates coordinates and place from the first feature", async () => {
    const searchApi = {
      reverse: vi.fn(async () => ({
        features: [{ geometry: { coordinates: [-116.2, 43.6] }, properties: { context: { region: {name: "Idaho", region_code: "ID"} }, full_address: "Boise, ID", name: "Boise" } }],
      }))
    };
    const c = locateComponent({ api: makeApi(), searchApi, geolocation: makeGeolocation({ position: { coords: {} } }) });
    c.searchFilter = "Boise";
    c.mapboxToken = "tok";

    c.search({ preventDefault: () => {} });
    await vi.waitFor(() => expect(c.place).toBe("Boise"));

    expect(c.longitude).toBe(-116.2);
    expect(c.latitude).toBe(43.6);
    expect(c.isCurrentLocation).toBe(false);
    expect(searchApi.reverse).toHaveBeenCalledWith("Boise", "tok");
  });

  it("setCountyMap creates the map only once", () => {
    const { L } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;

    c.setCountyMap();
    c.setCountyMap();

    expect(L.map).toHaveBeenCalledTimes(1);
  });

  it("setCountyMap adds a place marker at the current coordinates", () => {
    const { L } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;

    c.setCountyMap();

    expect(L.marker).toHaveBeenCalledWith([43.6, -116.2]);
  });

  it("setCountyMap only adds layers for results that are present", () => {
    const { L } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;
    c.results = { countyShape: JSON.stringify({ type: "Polygon", coordinates: [] }) };

    c.setCountyMap();

    expect(L.geoJSON).toHaveBeenCalledTimes(1);
    // only "place" marker should be added, not national park or summit
    expect(L.marker).toHaveBeenCalledTimes(1);
  });

  it("setCountyMap does not duplicate layers across repeated calls", () => {
    const { L } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;
    c.results = {
      nearestNationalPark: { latitude: 44.1, longitude: -115.9 },
    };

    c.setCountyMap();
    c.setCountyMap();

    // one for "place" and one for "nationalPark", not duplicated
    expect(L.marker).toHaveBeenCalledTimes(2);
  });

  it("clearMarkers resets the map view and re-adds only the place marker", () => {
    const { L, mapInstance, group } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;
    c.results = {
      nearestNationalPark: { latitude: 44.1, longitude: -115.9 },
    };
    c.setCountyMap();

    c.latitude = 43.7;
    c.longitude = -116.3;
    c.clearMarkers();

    expect(group.clearLayers).toHaveBeenCalledTimes(1);
    expect(mapInstance.setView).toHaveBeenCalledWith([43.7, -116.3], 8);
    expect(L.marker).toHaveBeenLastCalledWith([43.7, -116.3]);
  });

  it("clearMarkers is a no-op before the map has been created", () => {
    const { L } = makeL();
    const c = locateComponent({ api: makeApi(), geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });

    expect(() => c.clearMarkers()).not.toThrow();
    expect(L.map).not.toHaveBeenCalled();
  });

  it("locate wires political/forecast results through to the map", async () => {
    const { L } = makeL();
    const api = makeApi({
      political: vi.fn(async () => ({
        county: "Ada",
        state: "ID",
        countyShape: JSON.stringify({ type: "Polygon", coordinates: [] }),
        nearestNationalPark: { name: "Craters of the Moon", distance: 60, bearing: "SE", latitude: 43.4, longitude: -113.5 },
      })),
      forecast: vi.fn(async () => ({
        topography: { nearestSummitLatitude: 44.0, nearestSummitLongitude: -115.0 },
      })),
    });
    const c = locateComponent({ api, geolocation: makeGeolocation({ position: { coords: {} } }), L, nextTick: (fn) => fn() });
    c.latitude = 43.6;
    c.longitude = -116.2;

    c.locate({});
    await vi.waitFor(() => expect(c.isLoaded).toBe(true));
    await vi.waitFor(() => expect(L.geoJSON).toHaveBeenCalledTimes(1));

    expect(L.map).toHaveBeenCalledTimes(1);
    await vi.waitFor(() => expect(L.marker).toHaveBeenCalledWith([44.0, -115.0]));
  });
});
