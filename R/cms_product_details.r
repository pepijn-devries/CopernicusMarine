#' Obtain details for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Obtain details for a specific Copernicus marine product. This can be
#' narrowed down to specific layers and/or variables within the product.
#' @inheritParams cms_download_subset
#' @param variant A `character` string indicating the type of details that should be returned.
#' Should be one of `""` (default), `"detailed-v2"`, or `"detailed-v3"`.
#' @returns Returns a named `list` with properties of the requested product.
#' @rdname cms_product_details
#' @name cms_product_details
#' @family product-functions
#' @examples
#' cms_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' 
#' cms_product_details(
#'   product  = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer    = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
#'   variable = "thetao"
#' )
#' @author Pepijn de Vries
#' @export
cms_product_details <- function(product, layer, variable,
                                variant = c("", "detailed-v2", "detailed-v3")) {
  variant <- match.arg(variant)
  if (missing(layer) && !missing(variable)) stop("Variable specified without layer.")
  if (missing(product)) product <- ""
  result <- .try_online({
    "https://data-be-prd.marine.copernicus.eu/api/dataset/%s?variant=%s" |>
      sprintf(product, variant) |>
      httr2::request() |>
      httr2::req_perform()
  }, "Copernicus")
  
  if (is.null(result)) return (result)
  result <-
    result |>
    httr2::resp_body_json()
  if (!missing(layer)) {
    result <- result$layers[names(result$layers) |> startsWith(paste0(layer, "_"))]
  }
  if (!missing(variable)) {
    result <- result[names(result) |> endsWith(paste0("/", variable))]
  }
  return(result)
}