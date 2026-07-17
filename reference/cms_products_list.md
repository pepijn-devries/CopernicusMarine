# List products available from data.marine.copernicus.eu

**\[stable\]** Collect a list of products and some brief descriptions
for marine products available from Copernicus. `cms_products_list()`
does not use a formal API, but provides a more detailed list.
`cms_products_list2()` Does use the formal API, but provides less
details.

## Usage

``` r
cms_products_list(..., info_type = c("list", "meta"))

cms_products_list2(...)
```

## Arguments

- ...:

  Allows you to pass (search) query parameters to apply to the list.
  When omitted, the full list of products is returned.

- info_type:

  One of `"list"` (default) or `"meta"`. `"list"` returns the actual
  list whereas `"meta"` returns meta information for the executed query
  (e.g. number of hits).

## Value

Returns a `tibble` of products available from
<https://data.marine.copernicus.eu> or a named `list` when
`info_type = "meta"`. Returns `NULL` in case on-line services are
unavailable.

## Details

See
[`vignette("product-info")`](https://pepijn-devries.github.io/CopernicusMarine/articles/product-info.md)
for more details.

## See also

Other product:
[`cms_cite_product()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_cite_product.md),
[`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_metadata()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_metadata.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md)

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_products_list()

## Query a specific product:
  cms_products_list(freeText = "GLOBAL_ANALYSISFORECAST_PHY_001_024")
}
```
