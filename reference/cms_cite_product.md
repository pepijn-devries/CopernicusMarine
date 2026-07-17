# How to cite a Copernicus marine product

**\[stable\]** Get details for properly citing a Copernicus product.

## Usage

``` r
cms_cite_product(product)
```

## Arguments

- product:

  An identifier (type `character`) of the desired Copernicus marine
  product. Can be obtained with
  [`cms_products_list`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md).

## Value

Returns a vector of character strings. The first element is always the
product title, id and doi. Remaining elements are other associated
references. Note that the remaining references are returned as listed at
Copernicus. Note that the citing formatting does not appear to be
standardised.

## See also

Other product:
[`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_metadata()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_metadata.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md),
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_cite_product("SST_MED_PHY_SUBSKIN_L4_NRT_010_036")
}
```
