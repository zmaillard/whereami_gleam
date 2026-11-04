import { locateApi, searchApi } from "./api.js";
import { locateComponent } from "./component.js";

const lenis = new Lenis({
  autoRaf: true,
});

document.addEventListener("alpine:init", () => {
  Alpine.data("locate", (options = {}) => locateComponent({ api: locateApi(), searchApi: searchApi(), lenis, ...options }));
});
