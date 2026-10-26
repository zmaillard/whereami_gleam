import { getPlace, getAbbreviatedPlace, lengthOfDay, formatTime } from "./format.js";

export function locateComponent({
  api,
  searchApi,
  geolocation = navigator.geolocation,
} = {}) {
  return {
    latitude: "",
    longitude: "",
    searchFilter: "",
    mapboxToken: "",
    place: "",
    abbreviatedPlace: "",
    isLoaded: false,
    automaticCoordinates: false,
    showSearch: false,
    isCurrentLocation: true,
    results: {},
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
          self.place = getPlace(r);
          self.abbreviatedPlace = getAbbreviatedPlace(r);
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
    displaycoords() {
      return `<strong>Current Location</strong>: ${this.latitude}, ${this.longitude}`;
    },
    detailsButtonText() {
      return `Show Details for ${this.abbreviatedPlace}`;
    },
    hasPlace() {
      return this.isLoaded;
    },
    countyStateFormatted() {
      return `${this.results.county}, ${this.results.state}`
    },
    drainage() {
      if (!("drainage" in this.results)) return "";
      return this.results.drainage[this.results.drainage.length - 1];
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
      return this.results.time ? formatTime(this.results.time.sunrise) : "";
    },
    sunset() {
      return this.results.time ? formatTime(this.results.time.sunset) : "";
    },
    lengthOfDay() {
      return this.results.time ? lengthOfDay(this.results.time) : "";
    },
    locate(e) {
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
            };
          }
        });

      let physicalPromise = api.physical(coords)
        .then((r) => {
          if (r.drainage) {
            self.results.drainage = r.drainage;
          }
          if (r.ecoregions) {
            self.results.ecoregions = {
              level1: r.ecoregions.level1,
              level2: r.ecoregions.level2,
              level3: r.ecoregions.level3,
            };
          }
        });

      let forecastPromise = api.forecast(coords)
        .then((r) => {
          if (r.time) {
            self.results.time = {
              sunset: Date.parse(r.time.sunset),
              sunrise: Date.parse(r.time.sunrise),
              timezone: r.time.timezone,
            };
          }
          if (r.topography) {
            self.results.topography = {
              nearest_summit: r.topography.nearest_summit,
              nearest_summit_bearing: r.topography.nearest_summit_bearing,
              nearest_summit_elevation: r.topography.nearest_summit_elevation,
              nearest_summit_distance: r.topography.nearest_summit_distance,
              elevation: r.topography.elevation,
            };
          }
          if (r.weather) {
            self.results.weather = {
              office_abbreviation: r.weather.office_abbreviation,
              forecast_details_1: r.weather.forecast_details_1,
              forecast_details_2: r.weather.forecast_details_2,
              forecast_1: r.weather.forecast_1,
              forecast_2: r.weather.forecast_2,
            };
          }
        });

      Promise.all([politcalPromise, physicalPromise, forecastPromise]).then((a) =>
        console.log(self.results),
      );
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

              self.place = feature.properties.full_address;
              self.abbreviatedPlace = feature.properties.name;
              self.isCurrentLocation = false;
            }
          }
        });
    },
  };
}
