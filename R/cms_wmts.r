.xml_find <- function(node, node_name, where = "first") {
  fun <- switch(
    where,
    all = xml2::xml_find_all,
    xml2::xml_find_first
  )
  fun(node, sprintf(".//*[local-name()='%s']", node_name))
}

.parse_xml_struct <- function(node) {
  fun <- \(nd) {
    children <- xml2::xml_children(nd)
    elements <- xml2::xml_name(children) |> unique()
    lapply(elements, \(el) .xml_find(nd, el, "all") |>
             xml2::as_list() |> unlist()) |>
      stats::setNames(elements)
  }
  tryCatch({
    lapply(node, fun)
  }, error = \(e) fun(node)) |> list()
}

.parse_contents <- function(node) {
  lapply(node, \(child) {
    dplyr::tibble(
      Title      = .xml_find(child, "Title") |> xml2::xml_text(),
      Identifier = .xml_find(child, "Identifier") |> xml2::xml_text(),
      Style      = .xml_find(child, "Style") |> xml2::xml_text(),
      Format     = .xml_find(child, "Format") |> xml2::xml_text(),
      Dimension  = .xml_find(child, "Dimension", "all") |> .parse_xml_struct(),
      InfoFormat = .xml_find(child, "InfoFormat") |> xml2::xml_text() |>
        list(),
      TileMatrixSetLink = .xml_find(child, "TileMatrixSetLink") |>
        xml2::xml_text() |>
        list(),
      WGS84BoundingBox = .xml_find(child, "WGS84BoundingBox") |>
        .parse_xml_struct()
    )
  }) |>
    dplyr::bind_rows()

}

#' Obtain a WMTS entry for specific Copernicus marine products and add to a leaflet map
#'
#' `r lifecycle::badge('stable')` Functions for retrieving Web Map Tile Services information for
#' specific products, layers and variables and add them to a `leaflet` map.
#' @include cms_download_subset.r
#' @param map A map widget object created from [`leaflet::leaflet()`]
#' @inheritParams cms_download_subset
#' @param elevation,time Elevation or time dimension value for which to add
#' the tiles to the map. When missing; or not matching exactly with the values
#' specified by `cms_wmts_get_capabilities()`; the default dimension value
#' will be used.
#' @param tilematrixset A `character` string representing the tilematrixset to be used. In
#' many cases `"EPSG:3857"` (Pseudo-Mercator) or `"EPSG:4326"` (World Geodetic System 1984)
#' are available, but should be checked with `cms_wmts_details`.
#' @param options Passed on to [`leaflet::addWMSTiles()`].
#' @param type A `character` string indicating whether the capabilities should be returned
#' as `"data.frame"` (default) or `"xml"` ([`xml2::xml_new_document()`]).
#' @param ... Passed on to [`leaflet::addWMSTiles()`].
#' @returns `cms_wmts_details` returns a tibble with details on the WMTS service.
#' `cms_wmts_get_capabilities` returns either a `data.frame` or `xml_document` depending on the value
#' of `type`. `AddCmsWMTSTiles` returns a `leaflet` `map` updated with the requested tiles.
#' @rdname cms_wmts
#' @name cms_wmts_details
#' @include generics.r
#' @examples
#' if (interactive()) {
#'   wmts_details <-
#'     cms_wmts_details(
#'       product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'       layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'       variable = "thetao"
#'     )
#' 
#'   capabilities <-
#'     cms_wmts_get_capabilities("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' 
#'   if (nrow(wmts_details) > 0) {
#'     leaflet::leaflet() |>
#'       leaflet::setView(lng = 3, lat = 54, zoom = 4) |>
#'       leaflet::addProviderTiles("Esri.WorldImagery") |>
#'       addCmsWMTSTiles(
#'         product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'         layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'         variable = "thetao")
#'   }
#' }
#' @author Pepijn de Vries
#' @export
cms_wmts_details <- function(product, layer, variable) {
  copwmtsinfo <-
    sf::gdal_utils(
      "info",
      sprintf(
        "WMTS:%s%s?request=GetCapabilities",
        .wmts_base_url, product),
      quiet = TRUE) |>
    suppressWarnings()
  desc <- copwmtsinfo |> stringr::str_match_all("SUBDATASET_(\\d+)_DESC=(.*?)\n")
  if (length(desc) == 0) return(dplyr::tibble(desc = character(0), url = character(0)))
  desc <- desc[[1]][,3]
  url  <- copwmtsinfo |> stringr::str_match_all("SUBDATASET_(\\d+)_NAME=(.*?)\n")
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
    time,
    elevation,
    options = leaflet::WMSTileOptions(format = "image/png", transparent = TRUE),
    ...) {
  
  detail <- cms_wmts_details(product, layer, variable)
  detail <- detail$url |> strsplit(",") |> unlist()

  if (length(detail) == 0) rlang::abort(
    c(x = "Could not find a WMTS URL",
      i = "Check your parameter settings")) else
        detail <- detail[startsWith(detail, "layer=")] |> unique()
  if (length(detail) > 1) rlang::abort(
    c(x = "Found ambiguous WMTS URLs",
      i = "Check your parameter settings"))
  if (missing(time)) time <- NULL else{
    time <-
      time |>
      lubridate::as_datetime() |>
      format(format = "%Y-%m-%dT%H:%M:%SZ")
  }
  if (missing(elevation)) elevation <- NULL
  wmts_dims <- list(time = time, elevation = elevation)
  wmts_dims <- wmts_dims[lengths(wmts_dims) > 0]
  qry <- list(
    tilematrixset = tilematrixset,
    style = "default",
    tilematrix = "{z}",
    tilerow = "{y}",
    tilecol = "{x}"
  ) |>
    c(wmts_dims)
  qry <- paste0(names(qry), "=", unlist(qry), collapse = "&")

  leaflet::addTiles(
    map = map,
    urlTemplate =
      .wmts_base_url |>
      paste0(
        .wmts_req,
        sprintf("GetTile&%s&%s", qry, detail)),
    options = options,
    ...
  )
}

#' @rdname cms_wmts
#' @name cms_wmts_get_capabilities
#' @export
cms_wmts_get_capabilities <- function(product, layer, variable, type = c("data.frame", "xml")) {
  type <- match.arg(type)
  layer    <- if(missing(layer)) NULL else layer
  variable <- if(missing(variable)) NULL else variable
  args <- list(product, layer, variable)
  set  <- paste(unlist(args), collapse = "/")
  args <- args[lengths(args) > 0]
  details <- do.call(cms_wmts_details, args)
  layers <- stringr::str_extract_all(details$url, "(?<=,layer=)(.*)(?=,)") |>
    unlist() |>
    unique()
  result <-
    .wmts_base_url |>
    paste0(product, "/", .wmts_req, "GetCapabilities",
           ifelse(length(layers) == 1, paste0("&layer=", layers), "")) |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_xml()
  if (type == "data.frame") {
    result <- {
      xpath <- "//*[local-name()='Contents']/*[local-name()='Layer']"
      if (length(layers) == 1) {
        xpath <- paste0(
          xpath,
          sprintf("[.//*[local-name()='Identifier']='%s']", layers[[1]])
        )
      }
      if (length(layers) == 0) layers <- ""
      result <-
        xml2::xml_find_all(result, xpath) |>
        .parse_contents()
      if (length(layers) > 1 || layers != "")
        result <- result |>
        dplyr::filter(stringr::str_starts(.data$Identifier, set))
    }
  }
  return(result)
}

.wmts_base_url <- "http://wmts.marine.copernicus.eu/teroWmts/"
.wmts_req      <- "?service=WMTS&version=1.0.0&request="