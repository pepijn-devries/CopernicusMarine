#' List products available from data.marine.copernicus.eu
#'
#' `r lifecycle::badge('deprecated')` Collect a list of products and some brief
#' descriptions for marine products available from Copernicus
#'
#' @param ... Allows you to pass (search) query parameters to apply to the list.
#' When omitted, the full list of products is returned.
#' @param info_type One of `"list"` (default) or `"meta"`. `"list"` returns the actual list
#' whereas `"meta"` returns meta information for the executed query (e.g. number of hits).
#' @returns Returns a `tibble` of products available from <https://data.marine.copernicus.eu> or
#' a named `list` when `info_type = "meta"`. Returns `NULL` in case on-line services are
#' unavailable.
#' @rdname copernicus_products_list
#' @name copernicus_products_list
#' @family product-functions
#' @examples
#' \dontrun{
#' copernicus_products_list()
#' 
#' ## Query a specific product:
#' copernicus_products_list(freeText = "GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
copernicus_products_list <- function(..., info_type = c("list", "meta")) {
  .Deprecated("cms_products_list")
  cms_products_list(..., info_type)
}