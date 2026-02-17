# Get a proxy stars object from a Zarr service

**\[experimental\]** The advantage of [`stars_proxy`
objects](https://r-spatial.github.io/stars/articles/stars2.html#stars-proxy-objects),
is that they do not contain any data. They are therefore fast to handle
and consume only limited memory. You can still manipulate the object
lazily (like selecting slices). These operation are only executed when
calling
[`stars::st_as_stars()`](https://r-spatial.github.io/stars/reference/st_as_stars.html)
or [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on the
object.

## Usage

``` r
cms_zarr_proxy(
  product,
  layer,
  variable,
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

- asset:

  An asset that is available for the `product`. Should be one of
  `"native"`, `"wmts"`, `"timeChunked"`, `"downsampled4"`, or
  `"geoChunked"`.

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

A [`stars_proxy`
object](https://r-spatial.github.io/stars/articles/stars2.html#stars-proxy-objects)

## Details

For more details see
[`vignette("proxy")`](https://pepijn-devries.github.io/CopernicusMarine/articles/proxy.md).

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  myproxy <- cms_zarr_proxy(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    variable      = c("uo", "vo"),
    asset         = "timeChunked")
  plot(myproxy["uo",1:200,1:100,50,1], axes = TRUE)
}
```
