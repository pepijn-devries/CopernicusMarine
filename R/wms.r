#' Obtain a WMS entry for specific Copernicus marine products
#'
#' `r lifecycle::badge('experimental')` Web Map Services are not available for all
#' products and layers. Use this function to obtain URLs of WMS services if any.
#' @inheritParams copernicus_download_motu
#' @return Returns a `tibble` with WMS URLs and descriptors for the specified product.
#' @rdname copernicus_wms_details
#' @name copernicus_wms_details
#' @family wms-functions
#' @examples
#' \donttest{
#' copernicus_wms_details(
#'   product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'   variable = "thetao"
#' )
#' }
#' @author Pepijn de Vries
#' @export
copernicus_wms_details <- function(product, layer, variable) {
  product_details <- copernicus_product_details(product, layer, variable)

  copwmsinfo <- sf::gdal_utils("info", paste0("WMS:", product_details$wmsUrl), quiet = TRUE)
  
  desc <- copwmsinfo %>% stringr::str_match_all("SUBDATASET_(\\d)_DESC=(.*?)\n")
  desc <- desc[[1]][,3]
  url  <- copwmsinfo %>% stringr::str_match_all("SUBDATASET_(\\d)_NAME=(.*?)\n")
  url  <- url[[1]][,3]
  dplyr::bind_cols(desc = desc, url = url)
}

#' Add Copernicus Marine WMS Tiles to a leaflet map
#'
#' `r lifecycle::badge('experimental')` Create an interactive map with
#' `leaflet::leaflet()` and add layers of Copernicus marine WMS data
#' to it.
#' @param map A map widget object created from [`leaflet::leaflet()`]
#' @inheritParams copernicus_download_motu
#' @param options Passed on to [`leaflet::addWMSTiles()`].
#' @param ... Passed on to [`leaflet::addWMSTiles()`].
#' @return Returns an updated `map`
#' @rdname addCopernicusWMSTiles
#' @name addCopernicusWMSTiles
#' @family wms-functions
#' @examples
#' \donttest{
#' leaflet::leaflet() %>%
#'   leaflet::setView(lng = 3, lat = 54, zoom = 4) %>%
#'   leaflet::addProviderTiles("Esri.WorldImagery") %>%
#'   addCopernicusWMSTiles(
#'     product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'     variable = "thetao"
#'   )
#' }
#' @author Pepijn de Vries
#' @export
addCopernicusWMSTiles <- function(map, product, layer, variable,
                                  options = leaflet::WMSTileOptions(format = "image/png", transparent = TRUE),
                                  ...) {
  leaflet::addWMSTiles(
    map = map,
    baseUrl = copernicus_product_details(product, layer, variable)[["wmsUrl"]],
    layers  = variable,
    options = options,
    ...
  )
}

#' Extract and store WMS as a geo-referenced TIFF
#'
#' `r lifecycle::badge('experimental')` Extract and store imagery from a Copernicus WMS
#'  as a geo-referenced TIFF.
#'
#' A Web Map Service (WMS) cannot be plotted directly (base, ggplot2 and/or lattice).
#' For that purpose you need to extract and download a specific region in a format
#' that can be handled by plots. You can use this function to store a subset of a
#' WMS map as a geo-referenced TIFF file.
#' @inheritParams copernicus_download_motu
#' @param destination File name for the geo-referenced TIFF.
#' @param width Width in pixels of the TIFF image.
#' @param height Height in pixels of the TIFF image.
#' @return Stores the file as `destination` and returns invisible `NULL`
#' @rdname copernicus_wms2geotiff
#' @name copernicus_wms2geotiff
#' @family wms-functions
#' @examples
#' \donttest{
#' destination <- tempfile("wms", fileext = ".tiff")
#' copernicus_wms2geotiff(
#'   product     = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer       = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'   variable    = "thetao",
#'   region      = c(-1, 50, 7, 60),
#'   destination = destination,
#'   width       = 1920,
#'   height      = 1080
#' )
#' }
#' @author Pepijn de Vries
#' @export
copernicus_wms2geotiff <- function(product, layer, variable, region, destination, width, height) {
  wms_details     <- copernicus_wms_details(product, layer, variable)
  product_details <- copernicus_product_details(product, layer, variable)
  desc            <- NULL # <- silences R checks with respect to global bindings...
  url             <-
    wms_details %>%
    dplyr::filter(desc == variable | dplyr::n() == 1) %>%
    dplyr::pull("url") %>%
    stringr::str_replace("BBOX=(.*?)$", paste0("BBOX=", paste0(region, collapse = ',')))
  sf::gdal_utils(
    "translate",
    url,
    destination,
    c("-outsize", as.character(width), as.character(height), "-co", "COMPRESS=JPEG")
  )
  return(invisible(NULL))
}