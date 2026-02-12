#' Obtain details for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Obtain details for a specific Copernicus marine product.
#' @inheritParams cms_download_subset
#' @param ... Ignored
#' @returns Returns a named `list` with product details.
#' @rdname cms_product_details
#' @name cms_product_details
#' @family product-functions
#' @examples
#' if (interactive()) {
#'   cms_product_details("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
cms_product_details <- function(product, ...) {
  clients <- cms_get_client_info()
  stac_url <- gsub("/$", "", clients$catalogues[[1]]$stacRoot)
  product_url <- paste(
    stac_url,
    product,
    "product.stac.json",
    sep = "/"
  )

  result <-
    product_url |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  attr(result, "stac_url") <- stac_url
  
  return(result)
}