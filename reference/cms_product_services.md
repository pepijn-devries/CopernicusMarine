# Obtain available services for a specific Copernicus marine product

**\[stable\]** Obtain an overview of services provided by Copernicus for
a specific marine product.

## Usage

``` r
cms_product_services(product, ...)
```

## Arguments

- product:

  An identifier (type `character`) of the desired Copernicus marine
  product. Can be obtained with
  [`cms_products_list`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md).

- ...:

  Ignored.

## Value

Returns a `tibble` with a list of available services for a Copernicus
marine `product`.

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
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

Other product:
[`cms_cite_product()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_cite_product.md),
[`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_metadata()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_metadata.md),
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
}
```
