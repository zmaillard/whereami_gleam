import { lengthOfDay, formatTime,energyIconFromNwsIconDescription } from "./format.js";
import { createLayerRegistry } from "./layers.js";

export function locateComponent({
  api,
  searchApi,
  lenis,
  geolocation = navigator.geolocation,
  mapboxToken = "",
  L = window.L,
  spacetime = window.spacetime,
  nextTick = (fn) => (window.Alpine ? window.Alpine.nextTick(fn) : queueMicrotask(fn)),
  raw = (v) => (window.Alpine ? window.Alpine.raw(v) : v),
} = {}) {
  return {
    latitude: "",
    longitude: "",
    searchFilter: "",
    mapboxToken,
    place: "",
    placeState: "",
    isLoaded: false,
    loadingResults: false,
    automaticCoordinates: false,
    showSearch: false,
    isCurrentLocation: true,
    countyMap: null,
    layers: null,
    results: {
    },
    options: {
      enableHighAccuracy: true,
      timeout: 5000,
      maximumAge: 0,
    },
    init() {
      geolocation.getCurrentPosition(
        (pos) => this.onPosition(pos),
        (err) => this.onGeolocationError(err),
        this.options,
      );
      console.log(this.mapboxToken)
    },
    onGeolocationError(err) {
      console.warn(`ERROR(${err.code}): ${err.message}`);
      this.showSearch = true;
      this.isCurrentLocation = false;
    },
    onPosition(pos) {
      const crd = pos.coords;

      this.latitude = crd.latitude;
      this.longitude = crd.longitude;
      this.automaticCoordinates = true;
      let self = this;

      let coords = {
        lat: this.latitude,
        lng: this.longitude,
      };

      api.geocode(coords)
        .then((r) => {
          self.isCurrentLocation = true;
          self.place = r.place;
          self.placeState = r.state;
        });
    },
    toggle() {
      this.showSearch = !this.showSearch;
    },
    hascoords() {
      return this.latitude && this.longitude;
    },
    hasplace() {
      return !!this.place;
    },
    formatplace() {
      return `<strong>${this.isCurrentLocation ? "Current Location" : "User Defined Location"}</strong>: ${this.place}`;
    },
    currentTime() {
      if (!("time" in this.results)) return "";

      return this.results.time.now.format("time");
    },
    displaycoords() {
      return `<strong>Current Location</strong>: ${this.latitude}, ${this.longitude}`;
    },
    dstStatement() {
      if (!("time" in this.results)) return "";

      if (!this.results.time.now.hasDST()) {
        return "does not observe Daylight Standard Time";
      } else {
        return "observes Daylight Standard Time"
      }

    },
    isDST() {
      if (!("time" in this.results)) return "";

      return this.time.now.isDST();
    },
    hasDST() {
      if (!("time" in this.results)) return "";

      return this.time.now.hasDST();
    },
    detailsButtonText() {
      if (this.placeState) {
        return `Show Details for ${this.place}, ${this.placeState}`;
      }
      return `Show Details for ${this.place}`;
    },
    titleText() {
      if (this.placeState) {
        return `${this.place}, ${this.placeState}`;
      }
      return this.place;
    },
    hasPlace() {
      return this.isLoaded;
    },
    nearestSummit() {
      if (this.results?.topography?.nearestSummit) {
        return this.results?.topography?.nearestSummit;
      }
      return "";
    },
    nearestSummitElevation() {
      if (this.results?.topography?.nearestSummitElevation) {
        return `${Math.round(this.results.topography.nearestSummitElevation)} feet`
      }
      return "";
    },
    nearestSummitDistance() {
      if (this.results?.topography?.nearestSummitDistance && this.results?.topography?.nearestSummitBearing) {
        return `${Math.round(this.results?.topography?.nearestSummitDistance)} miles ${this.results?.topography?.nearestSummitBearing}`;
      }
      return "";
    },
    nearestNationalPark() {
      if (this.results?.nearestNationalPark?.name) {
        return this.results?.nearestNationalPark?.name
      }
      return "";
    },
    nearestNationalParkDistance() {
      if (this.results?.nearestNationalPark?.distance && this.results?.nearestNationalPark?.bearing) {
        return `${Math.round(this.results.nearestNationalPark.distance)} miles ${this.results.nearestNationalPark.bearing}`;
      }
      return "";
    },
    nearestPlace() {
      if (this.results?.nearestPlace?.name && this.results?.nearestPlace?.state) {
        return `${this.results?.nearestPlace?.name}, ${this.results?.nearestPlace?.state}`
      }
      return "";
    },
    nearestPlaceDistance() {
      if (this.results?.nearestPlace?.distance && this.results?.nearestPlace?.bearing) {
        return `${Math.round(this.results.nearestPlace.distance)} miles ${this.results.nearestPlace.bearing}`;
      }
      return "";
    },
    countyStateFormatted() {
      if (this.results?.county && this.results?.state) {
        return `${this.results.county}, ${this.results.state}`
      }
      return ""
    },
    drainage() {
      if (!("drainage" in this.results)) return "";
      return this.results.drainage[this.results.drainage.length - 1];
    },
    hydrographyFormatted() {
      if (!("drainage" in this.results)) return "";
      return this.results.drainage.join(" → ");
    },
    weatherLink() {
      if (!("weather" in this.results)) return "";
      return `https://www.weather.gov/${this.results.weather.office_abbreviation}`
    },
    firstForecast() {
      return this.results?.weather?.forecast_1;
    },
    firstForecastIcon() {
      if (this.results?.weather?.forecast_icon_1?.time && this.results?.weather?.forecast_icon_1?.type) {
        return energyIconFromNwsIconDescription("ei-", this.results?.weather?.forecast_icon_1?.time, this.results?.weather?.forecast_icon_1?.type);
      }
      return "";
    },
    firstForecastDetails() {
      return this.results?.weather?.forecast_details_1;
    },
    level1Ecoregion() {
      if (!("ecoregions" in this.results)) return "";
      return this.results.ecoregions.level1;
    },
    level2Ecoregion() {
      if (!("ecoregions" in this.results)) return "";
      return this.results.ecoregions.level2;
    },
    level3Ecoregion() {
      if (!("ecoregions" in this.results)) return "";
      return this.results.ecoregions.level3;
    },
    timezone() {
      if (!("time" in this.results)) return "";
      return this.results.time.timezone;
    },
    sunrise() {
      const t = this.results.time;
      return t ? this.results.time.sunrise.format('time') : "";
    },
    sunset() {
      const t = this.results.time;
      return t ? this.results.time.sunset.format('time') : "";
    },
    lengthOfDay() {
      return this.results.time ? this.results.time.sunset.since(this.results.time.sunrise).abbreviated.join(" ") : "";
    },
    elevation() {
      if (this.results.topography?.elevation) {
        return `${Math.round(this.results.topography.elevation)} feet`;
      }
      return "";
    },
    setCountyMap() {
      nextTick(() => {
        if (!this.countyMap) {
          this.countyMap = L.map('countyMap', {scrollWheelZoom: false}).setView([this.latitude, this.longitude], 8);
          L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
              maxZoom: 19,
              attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          }).addTo(this.countyMap);

          this.layers = createLayerRegistry({ L, map: this.countyMap, raw });
          this.layers.add("place", () => L.marker([this.latitude, this.longitude],{icon: L.divIcon({className: 'icon-map-pin-bold', iconSize: [32, 32]})}));
        } else {
          this.countyMap.invalidateSize();
        }

        if (this.results?.drainageLatitude && this.results?.drainageLongitude) {
          this.layers.add("drainage", () => L.marker([this.results.drainageLatitude, this.results.drainageLongitude], { icon: L.divIcon({ className: 'icon-droplet-bold', iconSize: [32, 32] }) }));//.bindTooltip(this.results.nearestNationalPark.name));
        }

        if (this.results?.nearestNationalPark?.latitude && this.results?.nearestNationalPark?.longitude) {
          this.layers.add("nationalPark", () => L.marker([this.results.nearestNationalPark.latitude, this.results.nearestNationalPark.longitude], {icon: L.divIcon({className: 'icon-pine-tree-bold', iconSize: [32, 32]})}).bindTooltip(this.results.nearestNationalPark.name));
        }

        if (this.results?.nearestPlace?.latitude && this.results?.nearestPlace?.longitude) {
          this.layers.add("nearestPlace", () => L.marker([this.results.nearestPlace.latitude, this.results.nearestPlace.longitude], {icon: L.divIcon({className: 'icon-city-skyline-bold', iconSize: [32, 32]})}).bindTooltip(this.nearestPlace()));
        }

        if (this.results?.countyShape) {
          this.layers.add("county", () => L.geoJSON(JSON.parse(this.results.countyShape), {}));
        }

        if ((this.results?.topography?.nearestSummitLatitude && this.results?.topography?.nearestSummitLongitude)) {
          this.layers.add("summit", () => L.marker([this.results?.topography?.nearestSummitLatitude, this.results?.topography?.nearestSummitLongitude], {icon: L.divIcon({className: 'icon-mountain-snow-bold',  iconSize: [32, 32]})}).bindTooltip(this.results.topography.nearestSummit));
        }
      });
    },
    summitTooltip() {
      console.log("here")
      this.layers.showTooltip("summit");
    },
    clearMarkers() {
      if (!this.countyMap) return;
      this.layers.clear();

      this.countyMap.setView([this.latitude, this.longitude], 8);
      this.layers.add("place", () => L.marker([this.latitude, this.longitude]));
    },
    scrollToResults(e) {
      const target = document.querySelector(".results-section");

      if (lenis && target) {
        lenis.scrollTo(target);
      }

      if (this.countyMap) {
        this.countyMap.invalidateSize();
      }
    },
    locate(e) {
      this.loadingResults = true;
      this.clearMarkers();
      let self = this;
      const coords = { lat: this.latitude, lng: this.longitude };

      self.results = {};
      let politcalPromise = api.political(coords)
        .then((r) => {
          if (r.congressionalDistrict) {
            self.results.congressionalDistrict = r.congressionalDistrict;
          }
          if (r.county) {
            self.results.county = r.county;
            self.results.state = r.state;
            self.results.countyShape = r.countyShape;
            self.isLoaded = true;
          }
          if (r.place) {
            self.results.place = r.place;
            self.results.placeType = r.placeType;
          }
          if (r.nearestNationalPark) {
            self.results.nearestNationalPark = {
              name: r.nearestNationalPark.name,
              distance: r.nearestNationalPark.distance,
              bearing: r.nearestNationalPark.bearing,
              latitude: r.nearestNationalPark.latitude,
              longitude: r.nearestNationalPark.longitude,
            };
          }
          if (r.nearestPlace) {
            self.results.nearestPlace = {
              name: r.nearestPlace.place,
              state: r.nearestPlace.state,
              distance: r.nearestPlace.distance,
              bearing: r.nearestPlace.bearing,
              latitude: r.nearestPlace.latitude,
              longitude: r.nearestPlace.longitude,
            };
          }
          self.setCountyMap();
        });

      let physicalPromise = api.physical(coords)
        .then((r) => {
          if (r.drainage) {
            self.results.drainage = r.drainage;
            self.results.drainageLatitude = r.drainageLatitude;
            self.results.drainageLongitude = r.drainageLongitude;
          }
          if (r.ecoregions) {
            self.results.ecoregions = {
              level1: r.ecoregions.level1,
              level2: r.ecoregions.level2,
              level3: r.ecoregions.level3,
            };
          }
          self.setCountyMap();
        });

      let forecastPromise = api.forecast(coords)
        .then((r) => {
          if (r.time) {
            let snow = spacetime.now().goto(r.time.timezone);
            self.results.time = {
              sunset: spacetime(r.time.sunset, r.time.timezone),
              sunrise: spacetime(r.time.sunrise, r.time.timezone),
              timezone: r.time.timezone,
              now: snow,
            };
          }
          if (r.topography) {
            self.results.topography = {
              nearestSummit: r.topography.nearestSummit,
              nearestSummitBearing: r.topography.nearestSummitBearing,
              nearestSummitElevation: r.topography.nearestSummitElevation,
              nearestSummitDistance: r.topography.nearestSummitDistance,
              nearestSummitLatitude: r.topography.nearestSummitLatitude,
              nearestSummitLongitude: r.topography.nearestSummitLongitude,
              elevation: r.topography.elevation,
            };
          }
          if (r.weather) {
            self.results.weather = {
              office_abbreviation: r.weather.office_abbreviation,
              office: r.weather.office,
              forecast_details_1: r.weather.forecast_details_1,
              forecast_details_2: r.weather.forecast_details_2,
              forecast_1: r.weather.forecast_1,
              forecast_2: r.weather.forecast_2,
              forecast_wind_direction_1: r.weather.forecast_wind_direction_1,
              forecast_wind_direction_2: r.weather.forecast_wind_direction_2,
              forecast_wind_speed_1: r.weather.forecast_wind_speed_1,
              forecast_wind_speed_2: r.weather.forecast_wind_speed_2,
              forecast_short_forecast_1: r.weather.forecast_short_forecast_1,
              forecast_short_forecast_2: r.weather.forecast_short_forecast_2,
              forecast_temperature_1: r.weather.forecast_temperature_1,
              forecast_temperature_2: r.weather.forecast_temperature_2,
              forecast_icon_1: r.weather.forecast_icon_1,
              forecast_icon_2: r.weather.forecast_icon_2,
            };
          }
          self.setCountyMap();
        });

      Promise.all([politcalPromise, physicalPromise, forecastPromise]).finally((a) => {
        self.loadingResults = false;
        self.scrollToResults();
      });
    },
    search(e) {
      let self = this;
      e.preventDefault();

      searchApi.reverse(this.searchFilter, this.mapboxToken)
        .then((r) => {
          if (r.features && r.features.length > 0) {
            const feature = r.features[0];
            if (feature.geometry && feature.geometry.coordinates) {
              [self.longitude, self.latitude] = feature.geometry.coordinates;

              self.place = feature.properties.name;
              self.placeState = feature.properties.context.region.name
              self.isCurrentLocation = false;
              self.results = {};
            }
          }
        });
    },
  };
}
