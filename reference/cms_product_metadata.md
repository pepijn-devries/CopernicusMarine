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

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
}
```
