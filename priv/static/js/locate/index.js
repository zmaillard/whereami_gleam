import { locateApi, searchApi } from "./api.js";
import { locateComponent } from "./component.js";

document.addEventListener("alpine:init", () => {
  Alpine.data("locate", (options = {}) => locateComponent({ api: locateApi(), searchApi: searchApi(), ...options }));
});

const lenis = new Lenis({
  autoRaf: true,
});
