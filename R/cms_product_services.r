#' Obtain available services for a specific Copernicus marine product
#'
#' `r lifecycle::badge('deprecated')` Obtain an overview of services provided by Copernicus
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
  result <- cms_product_metadata(product, "xml")
  if (is.null(result)) return (NULL)
  result <-
    result |>
    xml2::xml_find_all("//gmd:CI_OnlineResource") |>
    xml2::as_list() |>
    lapply(dplyr::as_tibble) |>
    dplyr::bind_rows() |>
    dplyr::mutate(ext = stringr::str_extract(unlist(.data$linkage), "(?<=--ext--)(.*)(?=/)")) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        ~ { lapply(.x, function(y) if (is.null(y)) NA else y[[1]]) |> unlist() })
    ) |>
    dplyr::select(dplyr::any_of(c("name", "ext", "linkage", "protocol"))) |>
    dplyr::rename(!!"layer" := "name") |>
    dplyr::filter(!is.na(.data$protocol) & !is.na(.data$layer)) |>
    tidyr::pivot_wider(id_cols = c("layer", "ext"),
                       names_from = "protocol", values_from = "linkage", values_fn = list)
  return(result)
}