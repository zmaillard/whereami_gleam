export function createLayerRegistry({ L, map, raw = (i) => i }) {
  const layers = {};
  const group = L.layerGroup().addTo(raw(map));

  return {
    has: (key) => key in layers,
    add: (key, factory) => {
      if (key in layers) return layers[key];
      const layer = factory();
      layers[key] = layer;
      group.addLayer(raw(layer));
      return layer;
    },
    clear: () => {
      group.clearLayers();
      for (const k of Object.keys(layers)) {
        delete layers[k];
      }
    }
  };
}
