# List products available from data.marine.copernicus.eu

**\[stable\]** Collect a list of products and some brief descriptions
for marine products available from Copernicus. `cms_products_list()`
does not use a formal API, but provides a more detailed list.
`cms_products_list2()` Does use the formal API, but provides less
details

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

## See also

Other product-functions:
[`cms_cite_product()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_cite_product.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md)

## Author

Pepijn de Vries

## Examples

``` r
cms_products_list()
#> # A tibble: 308 × 19
#>    product_id        catalogue title thumbnailUrl sources processingLevel areas 
#>    <chr>             <chr>     <chr> <chr>        <list>  <chr>           <list>
#>  1 GLOBAL_ANALYSISF… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  2 GLOBAL_ANALYSISF… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  3 GLOBAL_ANALYSISF… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  4 GLOBAL_MULTIYEAR… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  5 GLOBAL_MULTIYEAR… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  6 GLOBAL_MULTIYEAR… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  7 GLOBAL_MULTIYEAR… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  8 GLOBAL_MULTIYEAR… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#>  9 ARCTIC_ANALYSISF… CMEMS     Arct… https://mdl… <list>  Level 4         <list>
#> 10 ARCTIC_ANALYSIS_… CMEMS     Arct… https://mdl… <list>  Level 4         <list>
#> # ℹ 298 more rows
#> # ℹ 12 more variables: geoResolution <list>, vertLevels <int>,
#> #   tempExtentBegin <chr>, tempResolutions <list>, stacOrCswBbox <list>,
#> #   stacOrCswTbox <list>, mainVariables <list>, `_isViewableOmi` <lgl>,
#> #   numLayers <int>, thumbnailMeta <list>, tempExtentEnd <chr>,
#> #   omiFigureUrl <chr>

## Query a specific product:
cms_products_list(freeText = "GLOBAL_ANALYSISFORECAST_PHY_001_024")
#> # A tibble: 1 × 17
#>   product_id          catalogue title thumbnailUrl sources processingLevel areas
#>   <chr>               <chr>     <chr> <chr>        <chr>   <chr>           <chr>
#> 1 GLOBAL_ANALYSISFOR… CMEMS     Glob… https://mdl… Numeri… Level 4         Glob…
#> # ℹ 10 more variables: geoResolution <list>, vertLevels <int>,
#> #   tempExtentBegin <chr>, tempResolutions <list>, stacOrCswBbox <list>,
#> #   stacOrCswTbox <list>, mainVariables <list>, `_isViewableOmi` <lgl>,
#> #   numLayers <int>, thumbnailMeta <list>
```
