# CopernicusMarine

## Overview

[Copernicus Marine Service
Information](https://marine.copernicus.eu/about/) is a programme
subsidised by the European Commission. Its mission is to provide free
authoritative information on the oceans physical and biogeochemical
state. The `CopernicusMarine` R package is developed apart from this
programme and facilitates retrieval of information from
<https://data.marine.copernicus.eu>. With the package you can:

- List available marine data for Copernicus and provide
  meta-information.
- Download and use the data directly in R.

## Why Use `CopernicusMarine`

Copernicus Marine offers access to their data services through a [Python
application interface](https://pypi.org/project/copernicusmarine/). For
R users this requires complex installation procedures and is difficult
to maintain in a stable R package. The `CopernicusMarine` R package has
a much simpler installation procedure (see below) and does not depend on
third party software, other than packages available from
[CRAN](https://cran.r-project.org/).

## Installation

Install CRAN release:

``` r

install.packages("CopernicusMarine")
```

Install latest developmental version from R-Universe:

``` r

install.packages("CopernicusMarine", repos = c('https://pepijn-devries.r-universe.dev', 'https://cloud.r-project.org'))
```

## Usage

The package provides an interface between R and the Copernicus Marine
services. Note that for some of these services you need an account and
have to comply with [specific
terms](https://marine.copernicus.eu/user-corner/service-commitments-and-licence).
The usage section briefly shows three different ways of obtaining data
from Copernicus:

- [Downloading a subset](#sec-subset)
- [Downloading a full dataset](#sec-full)
- [Using the WMTS server](#sec-wtms)

If you want to explore the available products and their layers, you
should consult
[`vignette("product-info")`](https://pepijn-devries.github.io/CopernicusMarine/articles/product-info.md).
Please check the manual for complete documentation of the package.

For an excellent tutorial showing how to combine multiple spatial
datasets from different sources (amongst which is CopernicusMarine),
check out: [EMODnet Biology Geospatial R Tutorials (Tutorial
4)](https://emodnet.github.io/emodnet-bio-r-geo-tutorials/tutorials/tutorial-04.html)
by [Anna Krystalli](https://github.com/annakrystalli)

### Downloading a subset

The example below demonstrates how to subset a specific layer for a
specific product. The subset is constrained by the `region`, `timerange`
and `verticalrange` arguments. The subset is downloaded to memory
represented as a [`stars`](https://r-spatial.github.io/stars/) object.

``` r

my_data <-
  cms_download_subset(
    product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    variable      = c("uo", "vo"),
    region        = c(-1, 50, 10, 55),
    timerange     = c("2025-01-01", "2025-01-02"),
    verticalrange = c(0, -0.5),
    progress      = FALSE
)

plot(my_data["vo", drop = TRUE], col = hcl.colors(100), axes = TRUE)
```

![Example plots of downloaded
subsets](reference/figures/README-download-subset-1.png)

You can also use the request code from the Copernicus Marine Service
website to download a subset. For more details see
[`vignette("translate")`](https://pepijn-devries.github.io/CopernicusMarine/articles/translate.md)

In addition it is also possible to subset data with `stars_proxy`
objects, using either
[`cms_zarr_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_zarr_proxy.md)
or
[`cms_native_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_native_proxy.md).
This is explained in more detail in
[`vignette("proxy")`](https://pepijn-devries.github.io/CopernicusMarine/articles/proxy.md).

### Downloading a complete Copernicus marine product

If you don’t want to subset the data and want the complete set, you can
download complete native files, if these are available for your product.
You can list available files with (restricted to first 10 results with
`max=10`):

``` r

native_files <-
  cms_list_native_files(
    "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    max = 10)
native_files
#>                                                                                                                                                              Key
#> 1  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220601-20220601_3D-uovo_hcst_R20220615.nc
#> 2  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220602-20220602_3D-uovo_hcst_R20220615.nc
#> 3  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220603-20220603_3D-uovo_hcst_R20220615.nc
#> 4  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220604-20220604_3D-uovo_hcst_R20220615.nc
#> 5  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220605-20220605_3D-uovo_hcst_R20220615.nc
#> 6  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220606-20220606_3D-uovo_hcst_R20220615.nc
#> 7  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220607-20220607_3D-uovo_hcst_R20220615.nc
#> 8  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220608-20220608_3D-uovo_hcst_R20220622.nc
#> 9  native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220609-20220609_3D-uovo_hcst_R20220622.nc
#> 10 native/GLOBAL_ANALYSISFORECAST_PHY_001_024/cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m_202406/2022/06/glo12_rg_1d-m_20220610-20220610_3D-uovo_hcst_R20220622.nc
#>           LastModified                                   ETag       Size
#> 1  2024-04-18 15:10:35 "4861eb87b345d6d4f9db438d65a14832-232" 1939007453
#> 2  2024-04-18 15:10:52 "925a1faf0821efaa3714f76e716c0877-232" 1939116986
#> 3  2024-04-18 15:11:10 "924a5992ebdefda7d33c84b2da441a64-232" 1939263598
#> 4  2024-04-18 15:11:27 "cb651f56b56cea2f9af57c9c13236082-232" 1939067595
#> 5  2024-04-18 15:11:42 "250d5ad3351b9d51b85fe71ec9feddbc-232" 1938891867
#> 6  2024-04-18 15:11:58 "0808cac15870cc8b4225278ab19f5c1e-232" 1938981754
#> 7  2024-04-18 15:12:16 "57094e222da33e8900ffe11adbd9c43f-232" 1939169524
#> 8  2024-04-18 15:12:35 "5412dc75f6a6bb2986d1d83195d28fd9-232" 1939241026
#> 9  2024-04-18 15:12:51 "96f2661e1da6260d6f32ed382b70925d-232" 1939215570
#> 10 2024-04-18 15:13:04 "161fcf7147a9f72e8e11060084f29779-232" 1939313977
#>    StorageClass        Bucket                 base_url
#> 1      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 2      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 3      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 4      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 5      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 6      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 7      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 8      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 9      STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
#> 10     STANDARD mdl-native-14 s3.waw3-1.cloudferro.com
```

Downloading a specific (or multiple file) can be done with:

``` r

cms_download_native(
  destination   = tempdir(),
  product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
  layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
  prefix        = "2022/06/",
  pattern       = "m_20220630"
)
```

The file, whose file name matches the pattern, will be stored in the
specified destination folder. By default the progress is printed as
files can be very large and may take some time to download.

### Copernicus Web Map Tile Services (WMTS)

Web Map Tile Services (WMTS) allow to quickly plot pre-rendered images
onto a map. This may not be useful when you need the data for analyses
but is handy for quick visualisations, inspection or presentation of
data. In R it is very easy to add WMTS layers to an interactive map
using [leaflet](https://rstudio.github.io/leaflet/). This page is
rendered statically and resulting in a non-interactive map.

``` r

leaflet::leaflet() |>
  leaflet::setView(lng = 3, lat = 54, zoom = 4) |>
  leaflet::addProviderTiles("Esri.WorldImagery") |>
  addCmsWMTSTiles(
    product     = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
    layer       = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
    variable    = "thetao",
    time        = "2026-01-01 UTC",
    elevation   = -1.5413750410079956
  )
```

![Static example image of a leaflet
map](reference/figures/README-leaflet-1.png)

### Citing the Data You Use

A Copernicus account comes with several terms of use. One of these is
that you [properly
cite](https://help.marine.copernicus.eu/en/articles/4444611-how-to-cite-copernicus-marine-products-and-services)
the data you use in publications. In fact, we also have credit the data
used in this documentation, which can be easily done with the following
code:

``` r

cms_cite_product("GLOBAL_ANALYSISFORECAST_PHY_001_024")$doi
#> [1] "E.U. Copernicus Marine Service Information; Global Ocean Physics Analysis and Forecast - GLOBAL_ANALYSISFORECAST_PHY_001_024 (2016-10-14). DOI:10.48670/moi-00016"
```

## More of Copernicus

More R packages for exploring other Copernicus data services:

- [CopernicusClimate](https://github.com/pepijn-devries/CopernicusClimate)
  Dedicated to climate change datasets

## Resources

- [E.U. Copernicus Marine Service
  Information](https://data.marine.copernicus.eu)
- [Global Ocean Physics Analysis and Forecast -
  GLOBAL_ANALYSISFORECAST_PHY_001_024 (2016-10-14);
  DOI:10.48670/moi-00016](https://doi.org/10.48670/moi-00016)

## Code of Conduct

Please note that the CopernicusMarine project is released with a
[Contributor Code of
Conduct](https://pepijn-devries.github.io/CopernicusMarine/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
