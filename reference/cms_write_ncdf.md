# Store Typical Copernicus Marine Rasters Objects as NCDF

The
[`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md)
returns a `stars` class object. This is fine if you want to use it
directly in R. But if you want to open it in external software, you need
a more exceptable exchange format. You can use this function to store
the `stars` object as a [NetCDF](https://en.wikipedia.org/wiki/NetCDF)
file.

## Usage

``` r
cms_write_ncdf(x, file, missval = -999, prec = "double", ...)
```

## Arguments

- x:

  A `stars` class object created with
  [`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md).
  Note that this is not a highly generic NetCDF writer, so it makes
  certain assumptions about the `stars` object, that may not be true for
  all.

- file:

  File path where to store the object.

- missval:

  Value used to represent missing data (`NA`) in your object.

- prec:

  Precision used for storing the data (`"double"` by default).

- ...:

  Ignored.

## Value

Returns `NULL` invisibly.

## Details

Note that dimensions returned by
[`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md)
have interval values, describing between what range the raster cell
lies. When reading a file stored with `cms_write_ncdf()`, you must
specify where from the file the bounds of the dimension should be read.
Otherwise the GDAL driver will (often incorrectly) deduce dimension
values. The example shows how to read the written file using
[`stars::read_mdim()`](https://r-spatial.github.io/stars/reference/mdim.html).

The `cms_write_ncdf()` function is tailored to `stars` objects returned
by
[`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md).
It might work on other `stars` objects, but it is not guaranteed.

## See also

Other supporting:
[`cms_get_client_info()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_get_client_info.md),
[`cms_glossary()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_glossary.md),
[`cms_translate()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_translate.md)

## Examples

``` r
if (interactive()) {
  ## Download some data to store
  mydata <- cms_download_subset(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    variable      = c("uo", "vo"),
    region        = c(-1, 50, 10, 55),
    timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
    verticalrange = c(0, -2)
  )
  fn <- tempfile(fileext = ".nc")
  cms_write_ncdf(mydata, fn)
  mydata2 <- stars::read_mdim(
    fn,
    ## You explicitly need to specify dimension bounds when reading back the data
    bounds = c(
      longitude = "longitude_bnds",
      latitude  = "latitude_bnds",
      elevation = "elevation_bnds"))
}
```
