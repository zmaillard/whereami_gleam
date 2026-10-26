import { describe, it, expect, vi } from "vitest";
import { locateApi, searchApi } from "../../priv/static/js/locate/api.js";

function fakeFetch(body) {
  return vi.fn(async () => ({ json: async () => body }));
}

describe("locateApi", () => {
  it("POSTs form-encoded coordinates to /political", async () => {
    const fetchFn = fakeFetch({ county: "Ada", state: "ID" });
    const api = locateApi(fetchFn);

    const result = await api.political({ lat: 43.6, lng: -116.2 });

    expect(fetchFn).toHaveBeenCalledTimes(1);
    const [url, opts] = fetchFn.mock.calls[0];
    expect(url).toBe("/political");
    expect(opts.method).toBe("POST");
    expect(opts.headers["Content-Type"]).toBe("application/x-www-form-urlencoded");
    expect(opts.body.toString()).toBe("lat=43.6&lng=-116.2");
    expect(result).toEqual({ county: "Ada", state: "ID" });
  });

  it.each(["forecast", "physical", "geocode"])("posts to /%s", async (name) => {
    const fetchFn = fakeFetch({});
    const api = locateApi(fetchFn);
    await api[name]({ lat: 1, lng: 2 });
    expect(fetchFn.mock.calls[0][0]).toBe(`/${name}`);
  });
});

describe("searchApi", () => {
  it("builds a Mapbox forward-geocode URL and encodes the query", async () => {
    const fetchFn = fakeFetch({ features: [] });
    const api = searchApi(fetchFn);

    await api.reverse("Main St #2", "tok en");

    const url = fetchFn.mock.calls[0][0];
    expect(url).toContain("q=Main%20St%20%232");
    expect(url).toContain("access_token=tok%20en");
    expect(url).toContain("autocomplete=false");
    expect(url).toContain("country=us");
  });
});
