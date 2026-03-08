# Product Information

Before you start downloading data, you first need to know which data you
need and for which purpose. And not unimportant: you need to know where
to find it. Although data discovery is not the primary objective of this
package, it provides several instruments to obtain product information.

## The Web Browser

Perhaps the easiest way to find products and layers is via the [online
catalogue](https://data.marine.copernicus.eu/products). To streamline
your workflow using the web browser, you should check
[`vignette("translate")`](https://pepijn-devries.github.io/CopernicusMarine/articles/translate.md).
That vignette explains how you can copy a request from the catalogue and
use it in R.

## Listing Products

To get a complete overview of all available products, you can list them
with either
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)
or
[`cms_products_list2()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md):

``` r
library(CopernicusMarine)

cms_products_list() |> head(3)
#> # A tibble: 3 × 19
#>   product_id         catalogue title thumbnailUrl sources processingLevel areas 
#>   <chr>              <chr>     <chr> <chr>        <list>  <chr>           <list>
#> 1 GLOBAL_ANALYSISFO… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#> 2 GLOBAL_ANALYSISFO… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#> 3 GLOBAL_ANALYSISFO… CMEMS     Glob… https://mdl… <list>  Level 4         <list>
#> # ℹ 12 more variables: geoResolution <list>, vertLevels <int>,
#> #   tempExtentBegin <chr>, tempResolutions <list>, stacOrCswBbox <list>,
#> #   stacOrCswTbox <list>, mainVariables <list>, `_isViewableOmi` <lgl>,
#> #   numLayers <int>, thumbnailMeta <list>, tempExtentEnd <chr>,
#> #   omiFigureUrl <chr>

cms_products_list2() |> head(3)
#> $`C3S-GLO-SST-L4-REP-OBS-SST`
#> [1] "SST_GLO_SST_L4_REP_OBSERVATIONS_010_024"
#> 
#> $`CERSAT-GLO-SEAICE_30DAYS_DRIFT_ASCAT_SSMI_MERGED_RAN-OBS_FULL_TIME_SERIE`
#> [1] "SEAICE_ARC_SEAICE_L3_REP_OBSERVATIONS_011_010"
#> 
#> $`CERSAT-GLO-SEAICE_30DAYS_DRIFT_QUICKSCAT_SSMI_MERGED_RAN-OBS_FULL_TIME_SERIE`
#> [1] "SEAICE_ARC_SEAICE_L3_REP_OBSERVATIONS_011_010"
```

The first returns a `data.frame` complete with al sorts of meta
information about the type of variables in the product, the
spatio-temporal coverage, number of vertical layers, etc. You can use
this `data.frame` to narrow your search by applying a
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
on it.

You can even pass arguments that er used to search the online catalogue.
These are not well documented. The example below shows how to search for
free text and filter on area and variables:

``` r
cms_products_list(freeText = "wave",
                  facetValues = list(areas             = list("Europe"),
                                     specificVariables = list("Velocity")))
#> # A tibble: 1 × 16
#>   product_id         catalogue title thumbnailUrl sources processingLevel areas 
#>   <chr>              <chr>     <chr> <chr>        <chr>   <chr>           <list>
#> 1 SEALEVEL_EUR_PHY_… CMEMS     EURO… https://mdl… Satell… Level 3         <list>
#> # ℹ 9 more variables: geoResolution <list>, tempExtentBegin <chr>,
#> #   tempResolutions <chr>, stacOrCswBbox <list>, stacOrCswTbox <list>,
#> #   mainVariables <chr>, `_isViewableOmi` <lgl>, numLayers <int>,
#> #   thumbnailMeta <list>
```

The reason this is poorly documented is because this function does not
use the formal API. Instead it uses the web-form used by the online
catalogue. Users should therefore not rely on it too much as it may get
discontinued or altered at any time.

Instead, users can use
[`cms_products_list2()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)
which produces a list of products, by using the official API.
Unfortunately, this list does not contain any additional information.
For this purpose users can refer to
[`cms_product_metadata()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_metadata.md),
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
or
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md)
as described below.

## Product Details

With
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md)
you will get some descriptive information about your product. Nothing
too fancy, but it will help you understand what the product is all
about.

``` r
cms_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024") |> summary()
#>                 Length Class  Mode     
#> id               1     -none- character
#> type             1     -none- character
#> stac_version     1     -none- character
#> stac_extensions  1     -none- list     
#> title            1     -none- character
#> description      1     -none- character
#> license          1     -none- character
#> providers        2     -none- list     
#> keywords        52     -none- list     
#> links           30     -none- list     
#> extent           2     -none- list     
#> assets           1     -none- list     
#> properties      32     -none- list     
#> sci:doi          1     -none- character
```

## Product Metadata

When subsetting a dataset with
[`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md),
the most tricky thing is discovering what the available ranges are for
its dimensions. You can use
[`cms_product_metadata()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_metadata.md)
for this purpose. It returns a named list.

``` r
meta_info <- cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")

## Get the dimension properties for the first layer in this product
meta_info$properties[[1]]$`cube:dimensions` |> summary()
#>           Length Class  Mode
#> latitude  5      -none- list
#> longitude 5      -none- list
#> elevation 5      -none- list
```

Another way to get the dimension ranges is by setting up a stars proxy
object (see
[`vignette("proxy")`](https://pepijn-devries.github.io/CopernicusMarine/articles/proxy.md))
and call
[`st_dimensions()`](https://r-spatial.github.io/stars/reference/st_dimensions.html)
on it:

``` r
library(stars) |> suppressMessages()

myproxy <- cms_zarr_proxy(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    asset         = "timeChunked")
st_dimensions(myproxy)
#>           from   to     offset  delta  refsys
#> longitude    1 4320         NA     NA      NA
#> latitude     1 2041         NA     NA      NA
#> elevation    1   50         NA     NA udunits
#> time         1 1386 2022-06-01 1 days    Date
#>                                                            values x/y
#> longitude            [-180.0417,-179.9583),...,[179.875,179.9584) [x]
#> latitude            [-80.04167,-79.95833),...,[89.95834,90.04166) [y]
#> elevation [-5727.917,-5274.784) [m],...,[-0.494025,0.5533251) [m]    
#> time                                                         NULL
```

## Product Services

If you want a more raw access point to your data, you can use
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md).
It will present a `data.frame` for your product with all services
provided by Copernicus. You can use any of the columns with the
`"_href"` suffix to get an URL of a specific service. If you want to
access those directly, you are on your own. It is easier to use any of
the wrappers provided by this package to access the data.

``` r
cms_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#> # A tibble: 22 × 61
#>    id        type  stac_version stac_extensions geometry     bbox   properties  
#>    <chr>     <chr> <chr>        <chr>           <list>       <list> <list>      
#>  1 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  2 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  3 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  4 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  5 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  6 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  7 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  8 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#>  9 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#> 10 cmems_mo… Feat… 1.0.0        https://stac-e… <named list> <list> <named list>
#> # ℹ 12 more rows
#> # ℹ 54 more variables: links <list>, collection <chr>, native_id <chr>,
#> #   native_href <chr>, native_type <chr>, native_roles <chr>,
#> #   native_title <chr>, native_description <chr>, wmts_id <chr>,
#> #   wmts_href <chr>, wmts_type <chr>, wmts_roles <chr>, wmts_title <chr>,
#> #   wmts_description <chr>, static_id <list<list>>, static_href <list<list>>,
#> #   static_type <list<list>>, static_roles <list<list>>, …
```
