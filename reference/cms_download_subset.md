# Subset and download a specific marine product from Copernicus

**\[experimental\]** Subset and download a specific marine product from
Copernicus.

## Usage

``` r
cms_download_subset(
  product,
  layer,
  variable,
  region,
  timerange,
  verticalrange,
  progress = TRUE,
  crop,
  asset,
  ...,
  username = cms_get_username(),
  password = cms_get_password()
)
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

- region:

  Specification of the bounding box as a `vector` of `numeric`s WGS84
  lat and lon coordinates. Should be in the order of: xmin, ymin, xmax,
  ymax.

- timerange:

  A `vector` with two elements (lower and upper value) for a requested
  time range. The `vector` should be coercible to `POSIXct`.

- verticalrange:

  A `vector` with two elements (minimum and maximum) numerical values
  for the depth of the vertical layers (if any). Note that values below
  the sea surface needs to be specified as negative values.

- progress:

  A logical value. When `TRUE` (default) progress is reported to the
  console. Otherwise, this function will silently proceed.

- crop:

  **\[deprecated\]**. This version now uses the GDAL library to handle
  the subsetting and downloading of subsets. The `crop` argument is
  therefore no longer supported.

- asset:

  Type of asset to be used when subsetting data. Should be one of
  `"default"`, `"ARCO"`, `"static"`, `"omi"`, or `"downsampled4"`. When
  missing, set to `NULL` or set to `"default"`, it will use the first
  asset available for the requested product and layer, in the order as
  listed before.

- ...:

  Ignored (reserved for future features).

- username:

  Your Copernicus marine user name. Can be provided with
  [`cms_get_username()`](https://pepijn-devries.github.io/CopernicusMarine/reference/account.md)
  (default), or as argument here.

- password:

  Your Copernicus marine password. Can be provided as
  [`cms_get_password()`](https://pepijn-devries.github.io/CopernicusMarine/reference/account.md)
  (default), or as argument here.

## Value

Returns a
[`stars::st_as_stars()`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
object.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {

  mydata <- cms_download_subset(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    variable      = c("uo", "vo"),
    region        = c(-1, 50, 10, 55),
    timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
    verticalrange = c(0, -2)
  )

  plot(mydata["vo"])
} else {
  message("Make sure to run this in an interactive environment")
}
#> Make sure to run this in an interactive environment
```
