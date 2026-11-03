export function createLayerRegistry({ L, map }) {
  const layers = {};
  const group = L.layerGroup().addTo(map);

  return {
    has: (key) => key in layers,
    add: (key, factory) => {
      if (key in layers) return layers[key];
      const layer = factory();
      layers[key] = layer;
      group.addLayer(layer);
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
