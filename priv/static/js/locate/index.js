import { locateApi, searchApi } from "./api.js";
import { locateComponent } from "./component.js";

console.log("did i load")

document.addEventListener("alpine:init", () => {
  Alpine.data("locate", (options = {}) => locateComponent({ api: locateApi(), searchApi: searchApi(), ...options }));
});
