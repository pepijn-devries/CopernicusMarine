# Download raw files as provided to Copernicus Marine

**\[stable\]** Full marine data sets can be downloaded using the
functions documented here. Use `cms_list_native_files()` to list
available files, and `cms_download_native()` to download specific files.
Files are usually organised per product, layer, year, month and day.

## Usage

``` r
cms_download_native(
  destination,
  product,
  layer,
  pattern,
  prefix,
  progress = TRUE,
  ...
)

cms_list_native_files(product, layer, pattern, prefix, max = Inf, ...)
```

## Arguments

- destination:

  Path where to store the downloaded file(s).

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

- progress:

  A `logical` value. When `TRUE` a progress bar is shown.

- ...:

  Ignored

- max:

  A maximum number of records to be returned.

## Value

Returns `NULL` invisibly.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_list_native_files(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
    prefix        = "2022/06/"
  )

## If you omit the prefix, you may want to limit the
## number of results by setting `max`
  cms_list_native_files(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
    max           = 10
  )
  
## Prefix can be omitted when not relevant:
  cms_list_native_files(product = "SEALEVEL_GLO_PHY_MDT_008_063")
  
## Use 'pattern' to download a file for a specific day:
  cms_download_native(
    destination   = tempdir(),
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
    prefix        = "2022/06/",
    pattern       = "m_20220630"
  )
}
```
