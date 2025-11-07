# Obtain details for a specific Copernicus marine product

**\[stable\]** Obtain details for a specific Copernicus marine product.

## Usage

``` r
cms_product_details(product, ...)
```

## Arguments

- product:

  An identifier (type `character`) of the desired Copernicus marine
  product. Can be obtained with
  [`cms_products_list`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md).

- ...:

  Ignored

## Value

Returns a named `list` with product details.

## See also

Other product-functions:
[`cms_cite_product()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_cite_product.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md),
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024")
}
```
