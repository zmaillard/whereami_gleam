import { describe, it, expect, vi, beforeEach } from "vitest";
import { locateComponent } from "../../priv/static/js/locate/component.js";

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

describe("locateComponent", () => {
  it("sets coordinates and place on successful geolocation", async () => {
    const api = makeApi();
    const geolocation = makeGeolocation({ position: { coords: { latitude: 43.6, longitude: -116.2 } } });
    const c = locateComponent({ api, geolocation });

    c.init();
    await vi.waitFor(() => expect(c.place).toBe("Boise, ID"));

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
    const c = locateComponent({ api, geolocation: makeGeolocation({ position: { coords: {} } }) });
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
        features: [{ geometry: { coordinates: [-116.2, 43.6] }, properties: { full_address: "Boise, ID", name: "Boise" } }],
      })),
    };
    const c = locateComponent({ api: makeApi(), searchApi, geolocation: makeGeolocation({ position: { coords: {} } }) });
    c.searchFilter = "Boise";
    c.mapboxToken = "tok";

    c.search({ preventDefault: () => {} });
    await vi.waitFor(() => expect(c.place).toBe("Boise, ID"));

    expect(c.longitude).toBe(-116.2);
    expect(c.latitude).toBe(43.6);
    expect(c.isCurrentLocation).toBe(false);
    expect(searchApi.reverse).toHaveBeenCalledWith("Boise", "tok");
  });
});
