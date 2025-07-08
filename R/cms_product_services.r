#' Obtain available services for a specific Copernicus marine product
#'
#' `r lifecycle::badge('experimental')` Obtain an overview of services provided by Copernicus
#' for a specific marine product.
#'
#' @include cms_download_subset.r
#' @inheritParams cms_download_subset
#' @returns Returns a `tibble` with a list of available services for a
#' Copernicus marine `product`.
#' @examples
#' cms_product_services("GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' @family product-functions
#' @author Pepijn de Vries
#' @export
cms_product_services <- function(product) {
  result <- cms_product_details(product)
  result <- result$stacItems |>
    lapply(\(x)
           lapply(x$assets, \(y)
                  tibble::enframe(y) |>
                    tidyr::pivot_wider(values_from = "value", names_from = "name"))) |>
    lapply(dplyr::bind_rows)
  layers <- names(result)
  result <- tibble::tibble(layer = layers, data = result) |>
    tidyr::unnest("data")
  result <-
    result |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        function (x) {
          if (all(lengths(x) == 1)) unlist(x) else x
        }
      )
    )
  return(result)
}