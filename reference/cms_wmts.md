# Obtain a WMTS entry for specific Copernicus marine products and add to a leaflet map

**\[stable\]** Functions for retrieving Web Map Tile Services
information for specific products, layers and variables and add them to
a `leaflet` map.

## Usage

``` r
cms_wmts_details(product, layer, variable)

addCmsWMTSTiles(
  map,
  product,
  layer,
  variable,
  tilematrixset = "EPSG:3857",
  options = leaflet::WMSTileOptions(format = "image/png", transparent = TRUE),
  ...
)

cms_wmts_get_capabilities(product, layer, variable, type = c("list", "xml"))
```

## Arguments

- product:

  An identifier (type `character`) of the desired Copernicus marine
  product. Can be obtained with
  [`cms_products_list`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md).

- layer:

  The name of a desired layer within a product (type `character`). Can
  be obtained with
  [`cms_product_services`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md)
  (listed as `id` column).

- variable:

  The name of a desired variable in a specific layer of a product (type
  `character`). Can be obtained with
  [`cms_product_details`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md).

- map:

  A map widget object created from
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)

- tilematrixset:

  A `character` string representing the tilematrixset to be used. In
  many cases `"EPSG:3857"` (Pseudo-Mercator) or `"EPSG:4326"` (World
  Geodetic System 1984) are available, but should be checked with
  `cms_wmts_details`.

- options:

  Passed on to
  [`leaflet::addWMSTiles()`](https://rstudio.github.io/leaflet/reference/map-layers.html).

- ...:

  Passed on to
  [`leaflet::addWMSTiles()`](https://rstudio.github.io/leaflet/reference/map-layers.html).

- type:

  A `character` string indicating whether the capabilities should be
  returned as `"list"` (default) or `"xml"`
  ([`xml2::xml_new_document()`](http://xml2.r-lib.org/reference/xml_new_document.md)).

## Value

`cms_wmts_details` returns a tibble with detains on the WMTS service.
`cms_wmts_getcapabilities` returns either a `list` or `xml_document`
depending on the value of `type`. `AddCmsWMTSTiles` returns a `leaflet`
`map` updated with the requested tiles.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  wmts_details <-
    cms_wmts_details(
      product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
      variable = "thetao"
    )

  capabilities <-
    cms_wmts_get_capabilities("GLOBAL_ANALYSISFORECAST_PHY_001_024")

  if (nrow(wmts_details) > 0) {
    leaflet::leaflet() |>
      leaflet::setView(lng = 3, lat = 54, zoom = 4) |>
      leaflet::addProviderTiles("Esri.WorldImagery") |>
      addCmsWMTSTiles(
        product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
        layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        variable = "thetao")
  }
}
```
