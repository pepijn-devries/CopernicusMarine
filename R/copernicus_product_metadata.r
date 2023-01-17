#' Obtain meta data for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Collect meta information, such as vocabularies used,
#' for specific Copernicus marine products
#'
#' @inheritParams copernicus_download_motu
#' @return Returns a named `list` with info about the requested `product`.
#' @rdname copernicus_product_metadata
#' @name copernicus_product_metadata
#' @family product-functions
#' @examples
#' \donttest{
#' copernicus_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
copernicus_product_metadata <- function(product) {
  meta_data <-
    sprintf("https://cmems-be.lobelia.earth/api/metadata/%s", product) %>%
    httr::GET() %>%
    httr::content() %>%
    xml2::as_list()
  return(meta_data)
}