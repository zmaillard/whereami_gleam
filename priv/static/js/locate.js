document.addEventListener("alpine:init", () => {
  Alpine.data("locate", () => ({
    latitude: "",
    longitude: "",
    searchFilter: "",
    mapboxToken: "",
    place: "",
    abbreviatedPlace: "",
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
      let self = this;
      this.mapboxToken = document.getElementById("mapbox_token").value;
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const crd = pos.coords;

          this.latitude = crd.latitude;
          this.longitude = crd.longitude;
          let latInput = document.getElementById("latitude");
          latInput.value = this.latitude;
          let lngInput = document.getElementById("longitude");
          lngInput.value = this.longitude;
          this.automaticCoordinates = true;

          let params = {
            method: "POST",
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
            body: new URLSearchParams({
              lat: this.latitude,
              lng: this.longitude,
            }),
          };
          fetch("/geocode", params)
            .then((r) => r.json())
            .then((r) => {
              self.isCurrentLocation = true;
              self.place = self.getPlace(r);
              self.abbreviatedPlace = self.getAbbreviatedPlace(r);
            });
        },
        (err) => {
          console.warn(`ERROR(${err.code}): ${err.message}`);
          self.showSearch = true;
          self.isCurrentLocation = false;
        },
        this.options,
      );
    },
    getAbbreviatedPlace(reverseGeocode) {
      if (reverseGeocode) {
        return reverseGeocode.place;
      }
      return "";
    },
    getPlace(reverseGeocode) {
      if (reverseGeocode) {
        return `${reverseGeocode.place}, ${reverseGeocode.state}`;
      }
      return "";
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
    locate(e) {
      let self = this;
      let params = {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({ lat: this.latitude, lng: this.longitude }),
      };

      self.results = {};
      let politcalPromise = fetch("/political", params)
        .then((r) => r.json())
        .then((r) => {
          if (r.congressionalDistrict) {
            self.results.congressionalDistrict = r.congressionalDistrict;
          }
          if (r.county) {
            self.results.county = r.county;
            self.results.state = r.state;
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

      let physicalPromise = fetch("/physical", params)
        .then((r) => r.json())
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

      let forecastPromise = fetch("/forecast", params)
        .then((r) => r.json())
        .then((r) => {
          if (r.time) {
            self.results.time = {
              sunset: r.time.sunset,
              sunrise: r.time.sunrise,
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

      Promise.all([politcalPromise, physicalPromise]).then((a) =>
        console.log(self.results),
      );
    },
    search(e) {
      let self = this;
      let latInput = document.getElementById("latitude");
      let lngInput = document.getElementById("longitude");

      e.preventDefault();

      fetch(
        `https://api.mapbox.com/search/geocode/v6/forward?q=${this.searchFilter}&access_token=${this.mapboxToken}&autocomplete=false&country=us`,
      )
        .then((r) => r.json())
        .then((r) => {
          if (r.features && r.features.length > 0) {
            const feature = r.features[0];
            console.log(feature);
            if (feature.geometry && feature.geometry.coordinates) {
              [self.longitude, self.latitude] = feature.geometry.coordinates;
              latInput.value = self.latitude;
              lngInput.value = self.longitude;

              self.place = feature.properties.full_address;
              self.abbreviatedPlace = feature.properties.name;
              self.isCurrentLocation = false;
            }
          }
        });
    },
  }));
});
