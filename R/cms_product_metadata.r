#' Obtain product meta data
#'
#' `r lifecycle::badge('experimental')`TODO
#'
#' @include cms_download_subset.r
#' @param product Ignored. TODO
#' @param type Deprecated and ignored.
#' @returns TODO
#' @rdname cms_product_metadata
#' @name cms_product_metadata
#' @examples
#' cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' @author Pepijn de Vries
#' @export
cms_product_metadata <- function(product, type, ...) {
  details <- cms_product_details(product)
  if (is.null(details)) return (NULL)
  links     <- lapply(details$links, as.data.frame) |> dplyr::bind_rows()
  item      <- links |> dplyr::filter(.data$rel == "item") |> dplyr::pull("href")
  meta_url  <- paste(attr(details, "stac_url"), product, item, sep = "/")
  meta_data <- .try_online({
    meta_url |>
      httr2::request() |>
      httr2::req_perform()
  }, "meta-data-page")
  if (is.null(meta_data)) return(NULL) else {
    return(httr2::resp_body_json(meta_data))
  }
}