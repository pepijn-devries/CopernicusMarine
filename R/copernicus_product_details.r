#' Obtain details for a specific Copernicus marine product
#'
#' `r lifecycle::badge('deprecated')` Obtain details for a specific Copernicus marine product. This can be
#' narrowed down to specific layers and/or variables within the product.
#'
#' @inheritParams copernicus_download_motu
#' @returns Returns a named `list` with properties of the requested product.
#' @rdname copernicus_product_details
#' @name copernicus_product_details
#' @family product-functions
#' @examples
#' \dontrun{
#' copernicus_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' 
#' copernicus_product_details(
#'   product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'   variable = "thetao"
#' )
#' }
#' @author Pepijn de Vries
#' @export
copernicus_product_details <- function(product, layer, variable) {
  .Deprecated("cms_product_details")
  if (missing(layer) && !missing(variable)) stop("Variable specified without layer.")
  if (missing(product)) product <- ""
  result <- .try_online({
    sprintf("https://data-be-prd.marine.copernicus.eu/api/dataset/%s?variant=detailed-v2", product) |>
      httr2::request() |>
      httr2::req_perform()
  }, "Copernicus")
  if (is.null(result)) return(NULL)
  
  result <-
    result |>
    httr2::resp_body_json()
  if (!missing(layer)) {
    result <- result$layers[names(result$layers) |> startsWith(paste0(layer, "/"))]
  }
  if (!missing(variable)) {
    result <- result[[paste0(c(layer, variable), collapse = "/")]]
  }
  return(result)
}

#' Obtain available services for a specific Copernicus marine product
#'
#' `r lifecycle::badge('deprecated')` Obtain an overview of services provided by Copernicus
#' for a specific marine product.
#'
#' @inheritParams copernicus_download_motu
#' @returns Returns a `tibble` with a list of available services for a
#' Copernicus marine product
#' @rdname copernicus_product_services
#' @name copernicus_product_services
#' @examples
#' \dontrun{
#' copernicus_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
copernicus_product_services <- function(product) {
  .Deprecated("cms_product_details")
  services <- copernicus_product_details(product)
  services <- services$services |> purrr::map_dfr(dplyr::as_tibble) |>
    dplyr::mutate(layer = {
      nms <- names(services$services)
      nms[nms != ""] })
  return(services)
}