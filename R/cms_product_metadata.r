#' Obtain product meta data
#'
#' `r lifecycle::badge('experimental')`TODO
#'
#' @include cms_download_subset.r
#' @param product Ignored. TODO
#' @param type Deprecated and ignored.
#' @param ... Ignored
#' @returns TODO
#' @rdname cms_product_metadata
#' @name cms_product_metadata
#' @examples
#' cms_product_metadata("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' @author Pepijn de Vries
#' @export
cms_product_metadata <- function(product, type, ...) {
  if (!missing(type)) {
    rlang::warn(c("argument 'type' in `cms_product_metadata()` is deprecated and ignored.",
                  i = "Please remove from your call"))
  }
  details <- cms_product_details(product)
  if (is.null(details)) return (NULL)
  links     <- lapply(details$links, as.data.frame) |> dplyr::bind_rows()
  item      <- links |> dplyr::filter(.data$rel == "item") |> dplyr::pull("href")
  meta_url  <- paste(attr(details, "stac_url"), product, item, sep = "/")
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
}