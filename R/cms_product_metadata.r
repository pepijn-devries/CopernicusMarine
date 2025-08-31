#' Obtain product meta data
#'
#' `r lifecycle::badge('stable')` Obtain product meta data such as spatio-temporal bounds
#' of the data. 
#'
#' @include cms_download_subset.r
#' @inheritParams cms_download_subset
#' @param ... Ignored
#' @returns Returns a `data.frame`/`tibble` with the metadata. Each row in the `data.frame`
#' represents a layer available for the product.
#' @rdname cms_product_metadata
#' @name cms_product_metadata
#' @examples
#' if (interactive()) {
#'   cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @author Pepijn de Vries
#' @export
cms_product_metadata <- function(product, ...) {
  details <- cms_product_details(product)
  if (is.null(details)) return (NULL)
  links     <- lapply(details$links, as.data.frame) |> dplyr::bind_rows()
  item      <- links |> dplyr::filter(.data$rel == "item") |> dplyr::pull("href")
  meta_url  <- paste(attr(details, "stac_url"), product, item, sep = "/")
  result <-
    lapply(meta_url, function(u) {
      .try_online({
        u |>
          httr2::request() |>
          httr2::req_perform()
      }, "meta-data-page")
    }) |>
    lapply(function(x) {
      if (is.null(x)) return(NULL) else {
        return(httr2::resp_body_json(x))
      }
    }) |>
    .simplify()
  return(result)
}