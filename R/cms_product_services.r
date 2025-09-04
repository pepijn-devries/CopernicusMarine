#' Obtain available services for a specific Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Obtain an overview of services provided by Copernicus
#' for a specific marine product.
#'
#' @include cms_download_subset.r
#' @inheritParams cms_download_subset
#' @param ... Ignored.
#' @returns Returns a `tibble` with a list of available services for a
#' Copernicus marine `product`.
#' @examples
#' if (interactive()) {
#'   cms_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' }
#' @family product-functions
#' @author Pepijn de Vries
#' @export
cms_product_services <- function(product, ...) {
  meta_data <- cms_product_metadata(product)
  if (is.null(meta_data)) return(NULL)
  result <-
    meta_data$assets |>
    .simplify() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        .simplify
      )
    )

  unnest_names <- names(result)
  for (uname in unnest_names) {
    result <- tidyr::unnest_wider(result, dplyr::all_of(uname), names_sep = "_")
  }
  result <- dplyr::bind_cols(
    meta_data |> dplyr::select(!dplyr::all_of("assets")),
    result
  )
  return(result)
}