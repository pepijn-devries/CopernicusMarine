#' Obtain meta data for a specific Copernicus marine product
#'
#' `r lifecycle::badge('deprecated')` Deprecated. Use [`cms_product_metadata()`] instead.
#' 
#' Collect meta information, such as vocabularies used,
#' for specific Copernicus marine products
#'
#' @inheritParams copernicus_download_motu
#' @returns Returns a named `list` with info about the requested `product`. Returns `NULL`
#' when contacting Copernicus fails.
#' @rdname copernicus_product_metadata
#' @name copernicus_product_metadata
#' @family product-functions
#' @examples
#' \dontrun{
#' copernicus_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
copernicus_product_metadata <- function(product) {
  .Deprecated("cms_product_metadata")
  cms_product_metadata(product)
}