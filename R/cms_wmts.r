#' Obtain a WMTS entry for specific Copernicus marine products and add to a leaflet map
#'
#' `r lifecycle::badge('stable')` Functions for retrieving Web Map Tile Services infromation for
#' specific products, layers and variables and add them to a `leaflet` map.
#' @include cms_download_subset.r
#' @inheritParams cms_download_subset
#' @param map A map widget object created from [`leaflet::leaflet()`]
#' @param tilematrixset A `character` string representing the tilematrixset to be used. In
#' many cases `"EPSG:3857"` (Pseudo-Mercator) or `"EPSG:4326"` (World Geodetic System 1984)
#' are available, but should be checked with `cms_wmts_details`.
#' @param options Passed on to [`leaflet::addWMSTiles()`].
#' @param type A `character` string indicating whether the capabilities should be returned
#' as `"list"` (default) or `"xml"` ([`xml2::xml_new_document()`]).
#' @param ... Passed on to [`leaflet::addWMSTiles()`].
#' @returns `cms_wmts_details` returns a tibble with detains on the WMTS service.
#' `cms_wmts_getcapabilities` returns either a `list` or `xml_document` depending on the value
#' of `type`. `AddCmsWMTSTiles` returns a `leaflet` `map` updated with the requested tiles.
#' @rdname cms_wmts
#' @name cms_wmts_details
#' @examples
#' \donttest{
#' cms_wmts_details(
#'   product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'   variable = "thetao"
#' )
#' 
#' cms_wmts_get_capabilities("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' 
#' if (interactive()) {
#'   leaflet::leaflet() |>
#'     leaflet::setView(lng = 3, lat = 54, zoom = 4) |>
#'     leaflet::addProviderTiles("Esri.WorldImagery") |>
#'     addCmsWMTSTiles(
#'       product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'       layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'       variable = "thetao")
#' }
#' }
#' @author Pepijn de Vries
#' @export
cms_wmts_details <- function(product, layer, variable) {
  copwmtsinfo <-
    sf::gdal_utils(
      "info",
      "WMTS:https://wmts.marine.copernicus.eu/teroWmts/%s?request=GetCapabilities" |>
        sprintf(product),
      quiet = TRUE)
  desc <- copwmtsinfo |> stringr::str_match_all("SUBDATASET_(\\d)_DESC=(.*?)\n")
  if (length(desc) == 0) return(dplyr::tibble(desc = character(0), url = character(0)))
  desc <- desc[[1]][,3]
  url  <- copwmtsinfo |> stringr::str_match_all("SUBDATASET_(\\d)_NAME=(.*?)\n")
  url  <- url[[1]][,3]
  result <- dplyr::bind_cols(desc = desc, url = url)
  
  if (!missing(layer)) {
    result <- result |> dplyr::filter(grepl(layer, url, fixed = TRUE))
  }
  if (!missing(variable)) {
    result <- result |> dplyr::filter(grepl(paste0("/", variable, ","), url, fixed = TRUE))
  }
  return(result)
}

#' @rdname cms_wmts
#' @name addCmsWMTSTiles
#' @export
addCmsWMTSTiles <- function(
    map, product, layer, variable,
    tilematrixset = "EPSG:3857",
    options = leaflet::WMSTileOptions(format = "image/png", transparent = TRUE),
    ...) {
  
  detail <- cms_wmts_details(product, layer, variable)
  detail <- detail$url |> strsplit(",") |> unlist()
  detail <- detail[startsWith(detail, "layer=")]
  leaflet::addTiles(
    map = map,
    urlTemplate =
      .wmts_base_url |>
      paste0(
        .wmts_req,
        "GetTile&tilematrixset=%s&style=default&tilematrix={z}&tilerow={y}&tilecol={x}&%s") |>
      sprintf(tilematrixset, detail),
    options = options,
    ...
  )
}

#' @rdname cms_wmts
#' @name cms_wmts_get_capabilities
#' @export
cms_wmts_get_capabilities <- function(product, layer, variable, type = c("list", "xml")) {
  type <- match.arg(type)
  layer    <- if(missing(layer)) NULL else layer
  variable <- if(missing(variable)) NULL else variable
  set <- c(product, layer, variable) |>
    paste0(collapse = "/")
  result <-
    .wmts_base_url |>
    paste0(product, "/", .wmts_req, "GetCapabilities&layer=", set) |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_xml()
  if (type == "list") result <- xml2::as_list(result)
  return(result)
}

.wmts_base_url <- "http://wmts.marine.copernicus.eu/teroWmts/"
.wmts_req      <- "?service=WMTS&version=1.0.0&request="