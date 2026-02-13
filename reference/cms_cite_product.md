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

Other product-functions:
[`cms_product_details()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_details.md),
[`cms_product_services()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_product_services.md),
[`cms_products_list()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_products_list.md)

## Author

Pepijn de Vries

## Examples

``` r
cms_cite_product("SST_MED_PHY_SUBSKIN_L4_NRT_010_036")
#> $doi
#> [1] "E.U. Copernicus Marine Service Information; Mediterranean Sea - High Resolution Diurnal Subskin Sea Surface Temperature Analysis - SST_MED_PHY_SUBSKIN_L4_NRT_010_036 (2021-04-23). DOI:10.48670/moi-00170"
#> 
#> $id
#> [1] "SST_MED_PHY_SUBSKIN_L4_NRT_010_036"
#> 
#> $type
#> [1] "Collection"
#> 
#> $stac_version
#> [1] "1.0.0"
#> 
#> $stac_extensions
#> $stac_extensions[[1]]
#> [1] "https://stac-extensions.github.io/scientific/v1.0.0/schema.json"
#> 
#> 
#> $title
#> [1] "Mediterranean Sea - High Resolution Diurnal Subskin Sea Surface Temperature Analysis"
#> 
#> $description
#> [1] "For the Mediterranean Sea - the CNR diurnal sub-skin Sea Surface Temperature (SST) product provides daily gap-free (L4) maps of hourly mean sub-skin SST at 1/16° (0.0625°) horizontal resolution over the CMEMS Mediterranean Sea (MED) domain, by combining infrared satellite and model data (Marullo et al., 2014). The implementation of this product takes advantage of the consolidated operational SST processing chains that provide daily mean SST fields over the same basin (Buongiorno Nardelli et al., 2013). The sub-skin temperature is the temperature at the base of the thermal skin layer and it is equivalent to the foundation SST at night, but during daytime it can be significantly different under favorable (clear sky and low wind) diurnal warming conditions. The sub-skin SST L4 product is created by combining geostationary satellite observations aquired from SEVIRI and model data (used as first-guess) aquired from the CMEMS MED Monitoring Forecasting Center (MFC). This approach takes advantage of geostationary satellite observations as the input signal source to produce hourly gap-free SST fields using model analyses as first-guess. The resulting SST anomaly field (satellite-model) is free, or nearly free, of any diurnal cycle, thus allowing to interpolate SST anomalies using satellite data acquired at different times of the day (Marullo et al., 2014).\n \n[How to cite](https://help.marine.copernicus.eu/en/articles/4444611-how-to-cite-or-reference-copernicus-marine-products-and-services)\n\n**DOI (product):**   \nhttps://doi.org/10.48670/moi-00170\n\n**References:**\n\n* Marullo, S., Santoleri, R., Ciani, D., Le Borgne, P., Péré, S., Pinardi, N., ... & Nardone, G. (2014). Combining model and geostationary satellite data to reconstruct hourly SST field over the Mediterranean Sea. Remote sensing of environment, 146, 11-23.\n* Buongiorno Nardelli B., C.Tronconi, A. Pisano, R.Santoleri, 2013: High and Ultra-High resolution processing of satellite Sea Surface Temperature data over Southern European Seas in the framework of MyOcean project, Rem. Sens. Env., 129, 1-16, doi:10.1016/j.rse.2012.10.012.\n"
#> 
#> $license
#> [1] "proprietary"
#> 
#> $providers
#> $providers[[1]]
#> $providers[[1]]$name
#> [1] "CNR (Italy)"
#> 
#> $providers[[1]]$roles
#> $providers[[1]]$roles[[1]]
#> [1] "producer"
#> 
#> 
#> 
#> $providers[[2]]
#> $providers[[2]]$name
#> [1] "Copernicus Marine Service"
#> 
#> $providers[[2]]$roles
#> $providers[[2]]$roles[[1]]
#> [1] "host"
#> 
#> $providers[[2]]$roles[[2]]
#> [1] "processor"
#> 
#> 
#> $providers[[2]]$url
#> [1] "https://marine.copernicus.eu"
#> 
#> 
#> 
#> $keywords
#> $keywords[[1]]
#> [1] "oceanographic-geographical-features"
#> 
#> $keywords[[2]]
#> [1] "satellite-observation"
#> 
#> $keywords[[3]]
#> [1] "sea-surface-subskin-temperature"
#> 
#> $keywords[[4]]
#> [1] "near-real-time"
#> 
#> $keywords[[5]]
#> [1] "coastal-marine-environment"
#> 
#> $keywords[[6]]
#> [1] "weather-climate-and-seasonal-forecasting"
#> 
#> $keywords[[7]]
#> [1] "marine-resources"
#> 
#> $keywords[[8]]
#> [1] "marine-safety"
#> 
#> $keywords[[9]]
#> [1] "mediterranean-sea"
#> 
#> $keywords[[10]]
#> [1] "level-4"
#> 
#> 
#> $links
#> $links[[1]]
#> $links[[1]]$rel
#> [1] "root"
#> 
#> $links[[1]]$href
#> [1] "../catalog.stac.json"
#> 
#> $links[[1]]$title
#> [1] "Copernicus Marine Data Store"
#> 
#> $links[[1]]$type
#> [1] "application/json"
#> 
#> 
#> $links[[2]]
#> $links[[2]]$rel
#> [1] "parent"
#> 
#> $links[[2]]$href
#> [1] "../catalog.stac.json"
#> 
#> $links[[2]]$title
#> [1] "Copernicus Marine Data Store"
#> 
#> $links[[2]]$type
#> [1] "application/json"
#> 
#> 
#> $links[[3]]
#> $links[[3]]$rel
#> [1] "item"
#> 
#> $links[[3]]$href
#> [1] "cmems_obs-sst_med_phy-sst_nrt_diurnal-oi-0.0625deg_PT1H-m_202105/dataset.stac.json"
#> 
#> $links[[3]]$title
#> [1] "All data"
#> 
#> $links[[3]]$type
#> [1] "application/json"
#> 
#> 
#> $links[[4]]
#> $links[[4]]$rel
#> [1] "license"
#> 
#> $links[[4]]$href
#> [1] "https://marine.copernicus.eu/user-corner/service-commitments-and-licence"
#> 
#> $links[[4]]$title
#> [1] "Copernicus Marine Service Commitments and Licence"
#> 
#> $links[[4]]$type
#> [1] "text/html"
#> 
#> 
#> $links[[5]]
#> $links[[5]]$rel
#> [1] "cite-as"
#> 
#> $links[[5]]$href
#> [1] "https://doi.org/10.48670/moi-00170"
#> 
#> $links[[5]]$title
#> [1] "10.48670/moi-00170"
#> 
#> $links[[5]]$type
#> [1] "text/html"
#> 
#> 
#> $links[[6]]
#> $links[[6]]$rel
#> [1] "alternative"
#> 
#> $links[[6]]$href
#> [1] "https://data.marine.copernicus.eu/product/SST_MED_PHY_SUBSKIN_L4_NRT_010_036"
#> 
#> $links[[6]]$title
#> [1] "Product page"
#> 
#> $links[[6]]$type
#> [1] "text/html"
#> 
#> 
#> $links[[7]]
#> $links[[7]]$rel
#> [1] "describedby"
#> 
#> $links[[7]]$href
#> [1] "https://documentation.marine.copernicus.eu/PUM/CMEMS-SST-PUM-010-035-036.pdf"
#> 
#> $links[[7]]$title
#> [1] "Product User Manual"
#> 
#> $links[[7]]$type
#> [1] "application/pdf"
#> 
#> $links[[7]]$ref
#> [1] "CMEMS-SST-PUM-010-035-036"
#> 
#> $links[[7]]$createdAt
#> [1] "2021-04-23"
#> 
#> $links[[7]]$updatedAt
#> [1] "2024-07-26T13:29:56.843Z"
#> 
#> 
#> $links[[8]]
#> $links[[8]]$rel
#> [1] "describedby"
#> 
#> $links[[8]]$href
#> [1] "https://documentation.marine.copernicus.eu/QUID/CMEMS-SST-QUID-010-035-036.pdf"
#> 
#> $links[[8]]$title
#> [1] "Quality Information Document"
#> 
#> $links[[8]]$type
#> [1] "application/pdf"
#> 
#> $links[[8]]$ref
#> [1] "CMEMS-SST-QUID-010-035-036"
#> 
#> $links[[8]]$createdAt
#> [1] "2021-04-23"
#> 
#> $links[[8]]$updatedAt
#> [1] "2024-07-26T15:52:39.741Z"
#> 
#> 
#> $links[[9]]
#> $links[[9]]$rel
#> [1] "describedby"
#> 
#> $links[[9]]$href
#> [1] "https://documentation.marine.copernicus.eu/SQO/CMEMS-SST-SQO-010-035-036.pdf"
#> 
#> $links[[9]]$title
#> [1] "Synthesis Quality Overview"
#> 
#> $links[[9]]$type
#> [1] "application/pdf"
#> 
#> $links[[9]]$ref
#> [1] "CMEMS-SST-SQO-010-035-036"
#> 
#> $links[[9]]$createdAt
#> [1] "2023-11-30"
#> 
#> $links[[9]]$updatedAt
#> [1] "2024-07-26T13:38:33.707Z"
#> 
#> 
#> 
#> $extent
#> $extent$spatial
#> $extent$spatial$bbox
#> $extent$spatial$bbox[[1]]
#> $extent$spatial$bbox[[1]][[1]]
#> [1] -18.125
#> 
#> $extent$spatial$bbox[[1]][[2]]
#> [1] 30.25
#> 
#> $extent$spatial$bbox[[1]][[3]]
#> [1] 36.25
#> 
#> $extent$spatial$bbox[[1]][[4]]
#> [1] 46
#> 
#> 
#> 
#> 
#> $extent$temporal
#> $extent$temporal$interval
#> $extent$temporal$interval[[1]]
#> $extent$temporal$interval[[1]][[1]]
#> [1] "2019-01-01T00:00:00Z"
#> 
#> $extent$temporal$interval[[1]][[2]]
#> [1] "2026-02-12T23:00:00Z"
#> 
#> 
#> 
#> 
#> 
#> $assets
#> $assets$thumbnail
#> $assets$thumbnail$href
#> [1] "https://mdl-metadata.s3.waw3-1.cloudferro.com/metadata/thumbnails/SST_MED_PHY_SUBSKIN_L4_NRT_010_036.jpg"
#> 
#> $assets$thumbnail$type
#> [1] "image/jpeg"
#> 
#> $assets$thumbnail$roles
#> $assets$thumbnail$roles[[1]]
#> [1] "thumbnail"
#> 
#> 
#> $assets$thumbnail$title
#> [1] "Mediterranean Sea - High Resolution Diurnal Subskin Sea Surface Temperature Analysis thumbnail"
#> 
#> 
#> 
#> $properties
#> $properties$altId
#> [1] "4676ebab-6bdc-4401-bf6f-9cafbdb7f8c8"
#> 
#> $properties$providerMetadata
#> $properties$providerMetadata$source
#> [1] "cmems"
#> 
#> $properties$providerMetadata$type
#> [1] "csw"
#> 
#> $properties$providerMetadata$url
#> [1] "https://csw.marine.copernicus.eu/geonetwork/csw-MYOCEAN-CORE-PRODUCTS/eng/csw?service=CSW&version=2.0.2&request=GetRecordById&id=4676ebab-6bdc-4401-bf6f-9cafbdb7f8c8&elementsetname=full&outputSchema=http://www.isotc211.org/2005/gmd"
#> 
#> 
#> $properties$thumbnailMeta
#> $properties$thumbnailMeta$creationDate
#> [1] "2023-06-18T06:30:18.198Z"
#> 
#> $properties$thumbnailMeta$layerId
#> [1] "SST_MED_PHY_SUBSKIN_L4_NRT_010_036/cmems_obs-sst_med_phy-sst_nrt_diurnal-oi-0.0625deg_PT1H-m_202105/analysed_sst"
#> 
#> $properties$thumbnailMeta$time
#> [1] 1.546301e+12
#> 
#> $properties$thumbnailMeta$elevation
#> NULL
#> 
#> $properties$thumbnailMeta$basemapId
#> [1] "dark"
#> 
#> $properties$thumbnailMeta$overlays
#> $properties$thumbnailMeta$overlays$tags
#> $properties$thumbnailMeta$overlays$tags[[1]]
#> $properties$thumbnailMeta$overlays$tags[[1]]$name
#> [1] "SST"
#> 
#> 
#> $properties$thumbnailMeta$overlays$tags[[2]]
#> $properties$thumbnailMeta$overlays$tags[[2]]$name
#> [1] "Subskin"
#> 
#> 
#> 
#> 
#> $properties$thumbnailMeta$crs
#> [1] "epsg:4326"
#> 
#> $properties$thumbnailMeta$valueMin
#> [1] 286.84
#> 
#> $properties$thumbnailMeta$valueMax
#> [1] 293.65
#> 
#> $properties$thumbnailMeta$valueClamp
#> [1] TRUE
#> 
#> $properties$thumbnailMeta$logScale
#> [1] FALSE
#> 
#> $properties$thumbnailMeta$style
#> [1] "default"
#> 
#> $properties$thumbnailMeta$colormapId
#> [1] "thermal"
#> 
#> $properties$thumbnailMeta$colormapInvert
#> [1] FALSE
#> 
#> 
#> $properties$creationDate
#> [1] "2021-04-23"
#> 
#> $properties$modifiedDate
#> [1] "2023-11-30"
#> 
#> $properties$contacts
#> $properties$contacts[[1]]
#> $properties$contacts[[1]]$name
#> [1] ""
#> 
#> $properties$contacts[[1]]$organisationName
#> [1] "SST-CNR-ROMA-IT"
#> 
#> $properties$contacts[[1]]$responsiblePartyRole
#> [1] "resourceProvider"
#> 
#> $properties$contacts[[1]]$email
#> [1] ""
#> 
#> 
#> 
#> $properties$projection
#> [1] "WGS 84 (EPSG:4326)"
#> 
#> $properties$assimilatedData
#> list()
#> 
#> $properties$formats
#> $properties$formats[[1]]
#> [1] "NetCDF-4"
#> 
#> 
#> $properties$updateFrequencies
#> $properties$updateFrequencies$daily
#> [1] "14:00"
#> 
#> 
#> $properties$featureTypes
#> $properties$featureTypes[[1]]
#> [1] "Grid"
#> 
#> 
#> $properties$indicatorFamilies
#> list()
#> 
#> $properties$geoExtent
#> $properties$geoExtent$type
#> [1] "envelope"
#> 
#> $properties$geoExtent$coordinates
#> $properties$geoExtent$coordinates[[1]]
#> $properties$geoExtent$coordinates[[1]][[1]]
#> [1] -18.12
#> 
#> $properties$geoExtent$coordinates[[1]][[2]]
#> [1] 46
#> 
#> 
#> $properties$geoExtent$coordinates[[2]]
#> $properties$geoExtent$coordinates[[2]][[1]]
#> [1] 36.25
#> 
#> $properties$geoExtent$coordinates[[2]][[2]]
#> [1] 30.25
#> 
#> 
#> 
#> 
#> $properties$geoResolution
#> $properties$geoResolution$row
#> $properties$geoResolution$row$magnitude
#> [1] 0.0625
#> 
#> $properties$geoResolution$row$units
#> [1] "degree"
#> 
#> 
#> $properties$geoResolution$column
#> $properties$geoResolution$column$magnitude
#> [1] 0.0625
#> 
#> $properties$geoResolution$column$units
#> [1] "degree"
#> 
#> 
#> 
#> $properties$tempExtentBegin
#> [1] "2019-01-01"
#> 
#> $properties$tempResolutions
#> $properties$tempResolutions[[1]]
#> [1] "Hourly"
#> 
#> 
#> $properties$vertExtentMin
#> [1] 0
#> 
#> $properties$vertExtentMax
#> [1] 0
#> 
#> $properties$rank
#> [1] 12700
#> 
#> $properties$useCases
#> list()
#> 
#> $properties$areas
#> $properties$areas[[1]]
#> [1] "Mediterranean Sea"
#> 
#> 
#> $properties$times
#> $properties$times[[1]]
#> [1] "Present"
#> 
#> $properties$times[[2]]
#> [1] "Past"
#> 
#> 
#> $properties$sources
#> $properties$sources[[1]]
#> [1] "Satellite observations"
#> 
#> 
#> $properties$colors
#> $properties$colors[[1]]
#> [1] "Blue Ocean"
#> 
#> 
#> $properties$communities
#> $properties$communities[[1]]
#> [1] "Policy & governance"
#> 
#> $properties$communities[[2]]
#> [1] "Science & innovation"
#> 
#> $properties$communities[[3]]
#> [1] "Extremes, hazards & safety"
#> 
#> $properties$communities[[4]]
#> [1] "Coastal services"
#> 
#> $properties$communities[[5]]
#> [1] "Natural resources & energy"
#> 
#> $properties$communities[[6]]
#> [1] "Trade & marine navigation"
#> 
#> 
#> $properties$processingLevel
#> [1] "Level 4"
#> 
#> $properties$mainVariables
#> $properties$mainVariables[[1]]
#> [1] "Temperature"
#> 
#> 
#> $properties$allVariables
#> $properties$allVariables[[1]]
#> [1] "Sea surface subskin temperature"
#> 
#> 
#> $properties$directives
#> list()
#> 
#> $properties$crs
#> [1] "EPSG:4326"
#> 
#> $properties$isStaging
#> [1] FALSE
#> 
#> $properties$admp_updated
#> [1] "2026-02-13T12:02:15.215564Z"
#> 
#> 
#> $`sci:doi`
#> [1] "10.48670/moi-00170"
#> 
```
