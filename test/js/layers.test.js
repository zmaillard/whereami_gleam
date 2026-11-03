import { describe, it, expect, vi } from "vitest";
import { createLayerRegistry } from "../../priv/static/js/locate/layers.js";

function makeL() {
  const group = { addTo: vi.fn().mockReturnThis(), addLayer: vi.fn(), clearLayers: vi.fn() };
  return { L: { layerGroup: vi.fn(() => group) }, group };
}

describe("createLayerRegistry", () => {
  it("creates a layer group and attaches it to the map", () => {
    const { L, group } = makeL();
    const map = {};
    createLayerRegistry({ L, map });

    expect(L.layerGroup).toHaveBeenCalledTimes(1);
    expect(group.addTo).toHaveBeenCalledWith(map);
  });

  it("add() calls the factory and adds the layer to the group", () => {
    const { L, group } = makeL();
    const registry = createLayerRegistry({ L, map: {} });
    const layer = {};
    const factory = vi.fn(() => layer);

    const result = registry.add("summit", factory);

    expect(factory).toHaveBeenCalledTimes(1);
    expect(group.addLayer).toHaveBeenCalledWith(layer);
    expect(result).toBe(layer);
  });

  it("has() reflects whether a key has been added", () => {
    const { L } = makeL();
    const registry = createLayerRegistry({ L, map: {} });

    expect(registry.has("summit")).toBe(false);
    registry.add("summit", () => ({}));
    expect(registry.has("summit")).toBe(true);
  });

  it("add() is idempotent for an existing key", () => {
    const { L, group } = makeL();
    const registry = createLayerRegistry({ L, map: {} });
    const factory = vi.fn(() => ({}));

    registry.add("summit", factory);
    registry.add("summit", factory);

    expect(factory).toHaveBeenCalledTimes(1);
    expect(group.addLayer).toHaveBeenCalledTimes(1);
  });

  it("add() returns the existing layer on a repeat call without re-invoking factory", () => {
    const { L } = makeL();
    const registry = createLayerRegistry({ L, map: {} });
    const layer = { id: "first" };
    registry.add("summit", () => layer);

    const result = registry.add("summit", () => ({ id: "second" }));

    expect(result).toBe(layer);
  });

  it("clear() empties the group and forgets all keys", () => {
    const { L, group } = makeL();
    const registry = createLayerRegistry({ L, map: {} });
    registry.add("place", () => ({}));
    registry.add("summit", () => ({}));

    registry.clear();

    expect(group.clearLayers).toHaveBeenCalledTimes(1);
    expect(registry.has("place")).toBe(false);
    expect(registry.has("summit")).toBe(false);
  });

  it("clear() allows re-adding a key previously cleared", () => {
    const { L } = makeL();
    const registry = createLayerRegistry({ L, map: {} });
    registry.add("place", () => ({ id: "old" }));
    registry.clear();

    const result = registry.add("place", () => ({ id: "new" }));

    expect(result).toEqual({ id: "new" });
  });
});
