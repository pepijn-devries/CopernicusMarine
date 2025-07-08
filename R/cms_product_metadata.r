#' Obtain meta data (Deprecated)
#'
#' `r lifecycle::badge('deprecated')`This function is no longer supported by Copernicus
#' Marine. Use `cms_product_details()` instead.
#'
#' @include cms_download_subset.r
#' @param product Ignored.
#' @param type Ignored.
#' @returns Returns `NULL` as this service is no longer provided by Copernicus.
#' @rdname cms_product_metadata
#' @name cms_product_metadata
#' @author Pepijn de Vries
#' @export
cms_product_metadata <- function(product, type = c("list", "xml")) {
  .Deprecated("cms_product_details")
  return (NULL)
}