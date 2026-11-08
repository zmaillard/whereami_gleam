export function createLayerRegistry({ L, map, raw = (i) => { } }) {
  const layers = {};
  const group = L.layerGroup().addTo(raw(map));

  return {
    has: (key) => key in layers,
    showTooltip: (key) => {
      if (!(key in layers)) return;
      for (const k of Object.keys(layers)) {
        if (key === k) {
          layers[key].getTooltip().openTooltip();
        } else {
          layers[key].getTooltip().closeTooltip();
        }
      }
    },
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
