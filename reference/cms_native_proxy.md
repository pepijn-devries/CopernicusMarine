# Get a proxy stars object from a native service

The advantage of [`stars_proxy`
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
cms_native_proxy(product, layer, pattern, prefix, variable, ...)
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

- pattern:

  A regular expression
  ([regex](https://en.wikipedia.org/wiki/Regular_expression)) pattern.
  Only paths that match the pattern will be returned. It can be used to
  select specific files. For instance if `pattern = "2022/06/"`, only
  files for the year 2022 and the month June will be listed (assuming
  that the file path is structured as such, see examples)

- prefix:

  A `character` string. A prefix to be added to the search path of the
  files. Only the matching file (info) is downloaded (generally faster
  then using `pattern`)

- variable:

  The variable name for which to create the `stars_proxy`. If omitted it
  will include all variables in the layer.

- ...:

  Ignored

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
  native_proxy <-
    cms_native_proxy(
      product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
      layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
      prefix        = "2022/06/",
      pattern       = "20220621"
    )
  plot(native_proxy["zos", 1:1000, 1:500, 1, 1], axes = TRUE)
}
```
