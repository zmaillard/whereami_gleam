import { describe, it, expect } from "vitest";
import { getPlace, getAbbreviatedPlace, lengthOfDay, formatTime } from "../../priv/static/js/locate/format.js";

describe("getPlace", () => {
  it("joins place and state", () => {
    expect(getPlace({ place: "Boise", state: "ID" })).toBe("Boise, ID");
  });

  it("returns empty string for falsy input", () => {
    expect(getPlace(null)).toBe("");
    expect(getPlace(undefined)).toBe("");
  });
});

describe("getAbbreviatedPlace", () => {
  it("returns the place field", () => {
    expect(getAbbreviatedPlace({ place: "Boise" })).toBe("Boise");
  });

  it("returns empty string when missing", () => {
    expect(getAbbreviatedPlace(null)).toBe("");
  });
});

describe("lengthOfDay", () => {
  it("formats hours and minutes", () => {
    const sunrise = Date.parse("2024-06-01T06:00:00Z");
    const sunset = Date.parse("2024-06-01T18:30:00Z");
    expect(lengthOfDay({ sunrise, sunset })).toBe("12 hours and 30 minutes");
  });

  it("handles sunset before sunrise (abs value)", () => {
    expect(lengthOfDay({ sunrise: 60 * 60_000, sunset: 0 })).toBe("1 hours and 0 minutes");
  });
});

describe("formatTime", () => {
  it("formats a timestamp as a locale time string", () => {
    const ms = Date.parse("2024-06-01T18:30:00Z");
    expect(formatTime(ms)).toBe(new Date(ms).toLocaleTimeString("en-US"));
  });
});
