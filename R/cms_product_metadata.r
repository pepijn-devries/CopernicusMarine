#' Obtain meta data for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Collect meta information, such as vocabularies used,
#' for specific Copernicus marine products
#'
#' @include cms_download_subset.r
#' @inheritParams cms_download_subset
#' @param type A `character` string indicating how the data should be returned. Should be one of
#' `"list"` or `"xml"`.
#' @returns Returns a named `list` (when `type = "list"`) with info about the requested `product`.
#' Returns the same info as `xml_document` (see [`xml2::xml_new_document()`]) when `type = "xml"`.
#' Returns `NULL` when contacting Copernicus fails.
#' @rdname cms_product_metadata
#' @name cms_product_metadata
#' @family product-functions
#' @examples
#' cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' @author Pepijn de Vries
#' @export
cms_product_metadata <- function(product, type = c("list", "xml")) {
  type <- match.arg(type)
  meta_data <-
    .try_online({
      sprintf("https://data-be-prd.marine.copernicus.eu/api/metadata/%s", product) |>
        httr2::request() |>
        httr2::req_perform()
    }, "Copernicus")
  if (is.null(meta_data)) return(NULL)
  meta_data <-
    meta_data |>
    httr2::resp_body_xml()
  if (type == "list")
    meta_data <-
    meta_data |>
    xml2::as_list()
  return(meta_data)
}