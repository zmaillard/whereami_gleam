import { describe, it, expect } from "vitest";
import { getPlace, getAbbreviatedPlace, lengthOfDay, formatTime } from "../../priv/static/js/locate/format.js";

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
  it("formats time in the given timezone, not the local one", () => {
    const ms = Date.parse("2026-10-25T18:06:44-07:00");
    expect(formatTime(ms, "America/Boise")).toBe(
      new Date(ms).toLocaleTimeString("en-US", { timeZone: "America/Boise" }),
    );
  });
});
