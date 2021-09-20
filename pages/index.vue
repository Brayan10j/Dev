<template>
  <div>
    <v-container id="map" fluid fill-heigh style="height: 700px" />
    <br />
    <br />
    <v-row v-if="multi">
      <v-col v-for="(item, index) in multipleList" :key="index">
        <v-card class="mx-auto" max-width="344">
          <v-card-text>
            <div>ID</div>
            <p class="display-1 text--primary">{{ item.hexID }}</p>
            <div>Place</div>
            <p class="display-1 text--primary">{{ item.location }}</p>
            <p>Cordenates</p>
            <div class="text--primary">
              {{ item.cordenates }}
            </div>
          </v-card-text>
          <v-card-actions> </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <v-row v-else-if="dataHex.hexID !== undefined">
      <v-col>
        <v-card class="mx-auto" max-width="344">
          <v-card-text>
            <div>ID</div>
            <p class="display-1 text--primary">{{ dataHex.hexID }}</p>
            <div>Place</div>
            <p class="display-1 text--primary">{{ dataHex.location }}</p>
            <p>Cordenates:</p>
            <div class="text--primary">
              {{ dataHex.cordenates }}
            </div>
          </v-card-text>
          <v-card-actions> </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>


<script>
import geojson2h3 from "geojson2h3";
import { ScatterplotLayer } from "@deck.gl/layers";
import { MapboxLayer } from "@deck.gl/mapbox";
import { H3HexagonLayer } from "@deck.gl/geo-layers";
import {HexagonLayer} from '@deck.gl/aggregation-layers';

export default {
  data: () => ({
    geoData: {},
    dataHex: {},
    multi: false,
    prueba: "k",
    reveal: false,
    area: "",
    location: "",
    multipleList: [],
  }),
  methods: {
    loginBinance() {
      window.BinanceChain.request({ method: "eth_accounts" });
    },
  },
  mounted() {
    // NEW
    var hexagonLayer = new MapboxLayer({
      type: HexagonLayer,
      id: "heatmap",
      data: [{ position: [0, 0], size: 10000 }],
      getPosition: d => d.position,
      getRadius: d => d.size,
      getColor: [0, 0, 255],

    });
    var ctx = this;
    const mapboxgl = require("mapbox-gl");
    // const MapboxGeocoder = require("mapbox-gl-geocoder"); unstall
    const h3 = require("h3-js");
    mapboxgl.accessToken =
      "pk.eyJ1Ijoic3Rvcm1ibGF4IiwiYSI6ImNrb2Z6a2F3bzBib3gyb3BucDV5eG1maXoifQ.BgKgtZQJa5m1xOXGNuJfjw";
    var map = new mapboxgl.Map({
      container: "map",
      style: "mapbox://styles/mapbox/light-v9",
      center: [0, 0],
      zoom: 1,
      pitch: 45,
    });
    var view3D = false;
    var searchControl = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      marker: false,
    });

    class MultiControl {
      onAdd(map) {
        this._map = map;
        this._container = document.createElement("div");
        this._container.className = "mapboxgl-ctrl";
        this._btn = document.createElement("button");
        this._btn.className = "multi mapboxgl-ctrl-geocoder--input";
        this._btn.type = "button";
        this._btn.id = "idmulti";
        this._btn.textContent = "Multiselect";
        this._btn.onclick = function () {
          ctx.multi = !ctx.multi;
        };
        this._container.appendChild(this._btn);
        return this._container;
      }

      onRemove() {
        this._container.parentNode.removeChild(this._container);
        this._map = undefined;
      }
    }

    class View3DControl {
      onAdd(map) {
        this._map = map;
        let _this = this;
        this._container = document.createElement("div");
        this._container.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
        this._btn = document.createElement("button");
        this._btn.className = "mapboxgl-ctrl-icon mapboxgl-ctrl-pitchtoggle-2d";
        this._btn.type = "button";
        this._btn.id = "view3D";
        this._btn.onclick = function () {
          if (view3D) {
            map.setPitch(45);
            _this._btn.className =
              "mapboxgl-ctrl-icon mapboxgl-ctrl-pitchtoggle-2d";
          } else {
            map.setPitch(0);
            _this._btn.className =
              "mapboxgl-ctrl-icon mapboxgl-ctrl-pitchtoggle-3d";
          }
          view3D = !view3D;
        };
        this._container.appendChild(this._btn);
        return this._container;
      }

      onRemove() {
        this._container.parentNode.removeChild(this._container);
        this._map = undefined;
      }
    }

    const myCustomControl = new MultiControl();
    const myCustomControl3D = new View3DControl();

    // Add the control to the map.
    map.addControl(searchControl);
    map.addControl(myCustomControl3D);

    map.addControl(new mapboxgl.NavigationControl());
    map.on("load", function () {
      map.addLayer(hexagonLayer);
      var layers = map.getStyle().layers;
      var labelLayerId;
      for (var i = 0; i < layers.length; i++) {
        if (layers[i].type === "symbol" && layers[i].layout["text-field"]) {
          labelLayerId = layers[i].id;
          break;
        }
      }
      // The 'building' layer in the Mapbox Streets
      // vector tileset contains building height data
      // from OpenStreetMap.
      map.addLayer(
        {
          id: "add-3d-buildings",
          source: "composite",
          "source-layer": "building",
          filter: ["==", "extrude", "true"],
          type: "fill-extrusion",
          minzoom: 15,
          paint: {
            "fill-extrusion-color": "#aaa",
            // Use an 'interpolate' expression to
            // add a smooth transition effect to
            // the buildings as the user zooms in.
            "fill-extrusion-height": [
              "interpolate",
              ["linear"],
              ["zoom"],
              15,
              0,
              15.05,
              ["get", "height"],
            ],
            "fill-extrusion-base": [
              "interpolate",
              ["linear"],
              ["zoom"],
              15,
              0,
              15.05,
              ["get", "min_height"],
            ],
            "fill-extrusion-opacity": 0.6,
          },
        },

        labelLayerId
      );
      searchControl.on("result", (ev) => {
        map.flyTo({
          center: [
            ev.result.geometry.coordinates[0],
            ev.result.geometry.coordinates[1],
          ],
          zoom: 18,
          speed: 1.8,
        });
      });
      map.addSource("hex", {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features: [
            {
              type: "Feature",
              geometry: {
                type: "Polygon",
                coordinates: [
                  [
                    [-122.47485823276713, 37.85878356045377],
                    [-122.47504834087829, 37.86196795698972],
                    [-122.47845104316997, 37.86010614563313],
                    [-122.47485823276713, 37.85878356045377],
                  ],
                ],
              },
            },
          ],
        },
      });

      map.addLayer({
        id: "hex",
        type: "fill",
        source: "hex",
        paint: {
          "fill-outline-color": "rgba(0,0,0,0.1)",
          "fill-color": "rgba(0,0,0,0.1)",
        },
      });
      map.addLayer({
        id: "hex-highlighted",
        type: "fill",
        source: "hex",
        paint: {
          "fill-outline-color": "#484896",
          "fill-color": "#6e599f",
          "fill-opacity": 0.75,
        },
        filter: ["in", "FIPS", ""],
      }); // Place polygon under these labels.
      map.on("click", async function (e) {
        var clicked_hex_id = h3.geoToH3(e.lngLat["lat"], e.lngLat["lng"], 11);
        var res = await ctx.$axios.$get(
          `https://api.mapbox.com/geocoding/v5/mapbox.places/${e.lngLat["lng"]},${e.lngLat["lat"]}.json?access_token=${mapboxgl.accessToken}`
        );
        var info = res.features[0];
        var data = {
          hexID: clicked_hex_id,
          cordenates: `Lng: ${e.lngLat["lng"]} \nLat: ${e.lngLat["lat"]}`,
          location: info.place_name,
        };
        ctx.dataHex = data;
        if (ctx.multi) {
          let listID = ctx.multipleList.map((i) => i.hexID);
          if (listID.includes(clicked_hex_id)) {
            var i = listID.indexOf(clicked_hex_id);
            listID.splice(i, 1);
            ctx.multipleList.splice(i, 1);
          } else {
            ctx.multipleList.push(data);
            listID.push(clicked_hex_id);
          }
          focusMapMult(listID);
        } else {
          focusMap(clicked_hex_id);
        }
      });
    });
    map.on("zoom", function (e) {
      let zoom = map.getZoom();
      if (zoom > 15) {
        let elemento = document.getElementById("idmulti");
        if (!elemento) {
          map.addControl(myCustomControl);
        }
        var bounds = map.getBounds();
        let coor = [
          [bounds._sw.lng - 0.01, bounds._sw.lat - 0.01],
          [bounds._ne.lng - 0.01, bounds._sw.lat + 0.01],
          [bounds._ne.lng + 0.01, bounds._ne.lat + 0.01],
          [bounds._sw.lng + 0.01, bounds._ne.lat - 0.01],
          [bounds._sw.lng - 0.01, bounds._sw.lat - 0.01],
        ];
        let source = map.getSource("hex");
        const polygon = {
          type: "Feature",
          geometry: {
            type: "Polygon",
            coordinates: [coor],
          },
        };

        const hexagons = geojson2h3.featureToH3Set(polygon, 11);
        // -> ['8a2830855047fff', '8a2830855077fff', '8a283085505ffff', '8a283085506ffff']
        var geodata = geojson2h3.h3SetToMultiPolygonFeature(hexagons);
        // -> {type: 'Feature', properties: {}, geometry: {type: 'Polygon', coordinates: [...]}}
        source.setData(geodata);
      }
    });
    function focusMap(hex_id) {
      // Hex to geo
      let hexCenterCoordinates = h3.h3ToGeo(hex_id);
      // Move map focus
      map.flyTo({
        center: [hexCenterCoordinates[1], hexCenterCoordinates[0]],
        zoom: 18,
        speed: 1.8,
      });
      // Plot graphic point into map
      let singleHexGeojson = geojson2h3.h3ToFeature(hex_id);

      const selected_sourceId = "h3-hexes_selected";
      const selected_layerId = `${selected_sourceId}-layer`;
      let selected_source = map.getSource(selected_sourceId);
      if (!selected_source) {
        map.addSource(selected_sourceId, {
          type: "geojson",
          data: singleHexGeojson,
        });
        map.addLayer({
          id: selected_layerId,
          source: selected_sourceId,
          type: "fill",
          interactive: false,
          paint: {
            "fill-outline-color": "#4A90E2",
            "fill-color": "rgba(74,144,226,0.20)",
            "fill-opacity": 1,
          },
        });
        selected_source = map.getSource(selected_sourceId);
      }
      // Update the h3Geo data
      selected_source.setData(singleHexGeojson);
      map.setLayoutProperty(selected_layerId, "visibility", "visible");

      // multiple
    }
    function focusMapMult(multipleLandSelectionList) {
      let featureOfSelectedLands = geojson2h3.h3SetToFeatureCollection(
        multipleLandSelectionList
      );
      const selected_sourceId = "h3-hexes_multi_selected";
      const selected_layerId = `${selected_sourceId}-layer`;
      let selected_source = map.getSource(selected_sourceId);
      if (!selected_source) {
        map.addSource(selected_sourceId, {
          type: "geojson",
          data: featureOfSelectedLands,
        });
        map.addLayer({
          id: selected_layerId,
          source: selected_sourceId,
          type: "fill",
          interactive: false,
          paint: {
            "fill-outline-color": "#ec663c",
            "fill-color": "rgba(249,180,38,0.5)",
            "fill-opacity": 1,
          },
        });
        selected_source = map.getSource(selected_sourceId);
      }
      selected_source.setData(featureOfSelectedLands);
      map.setLayoutProperty(selected_layerId, "visibility", "visible");
    }
  },
};
</script>

<style >
.multi {
  color: #00000094;
  background: white;
  border-radius: 4px;
}

.v-card--reveal {
  bottom: 0;
  opacity: 1 !important;
  position: absolute;
  width: 100%;
}

.mapboxgl-ctrl-pitchtoggle-3d {
  background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMCIgaGVpZ2h0PSIzMCI+ICAgIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkeT0iLjM1ZW0iIHN0eWxlPSJmb250LXNpemU6IDE0cHg7IGZvbnQtZmFtaWx5OiAnSGVsdmV0aWNhIE5ldWUnLEFyaWFsLEhlbHZldGljYSxzYW5zLXNlcmlmOyBmb250LXdlaWdodDogYm9sZDsgdGV4dC1hbmNob3I6IG1pZGRsZTsiPjNEPC90ZXh0Pjwvc3ZnPg==);
}

.mapboxgl-ctrl-pitchtoggle-2d {
  background-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMCIgaGVpZ2h0PSIzMCI+ICAgIDx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkeT0iLjM1ZW0iIHN0eWxlPSJmb250LXNpemU6IDE0cHg7IGZvbnQtZmFtaWx5OiAnSGVsdmV0aWNhIE5ldWUnLEFyaWFsLEhlbHZldGljYSxzYW5zLXNlcmlmOyBmb250LXdlaWdodDogYm9sZDsgdGV4dC1hbmNob3I6IG1pZGRsZTsiPjJEPC90ZXh0Pjwvc3ZnPg==);
}
</style>