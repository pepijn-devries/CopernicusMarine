# Obtain product meta data

**\[stable\]** Obtain product meta data such as spatio-temporal bounds
of the data.

## Usage

``` r
cms_product_metadata(product, ...)
```

## Arguments

- product:

  An identifier (type `character`) of the desired Copernicus marine
  product. Can be obtained with
  [`cms_products_list`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md).

- ...:

  Ignored

## Value

Returns a `data.frame`/`tibble` with the metadata. Each row in the
`data.frame` represents a layer available for the product.

## Details

See
[`vignette("product-info")`](https://pepijn-devries.github.io/CopernicusMarine/articles/product-info.md)
for more details.

## See also

Other product:
[`cms_cite_product()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_cite_product.md),
[`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md),
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
}
```
