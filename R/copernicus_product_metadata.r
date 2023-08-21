#' Obtain meta data for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Collect meta information, such as vocabularies used,
#' for specific Copernicus marine products
#'
#' @inheritParams copernicus_download_motu
#' @returns Returns a named `list` with info about the requested `product`. Returns `NULL`
#' when contacting Copernicus fails.
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
    .try_online({
      sprintf("https://cmems-be.lobelia.earth/api/metadata/%s", product) %>%
        httr::GET()
    }, "Copernicus")
  if (is.null(meta_data)) return(NULL)
  meta_data <-
    meta_data %>%
    httr::content() %>%
    xml2::as_list()
  return(meta_data)
}