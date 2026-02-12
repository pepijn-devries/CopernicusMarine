#' List products available from data.marine.copernicus.eu
#'
#' `r lifecycle::badge('stable')` Collect a list of products and some brief
#' descriptions for marine products available from Copernicus. `cms_products_list()`
#' does not use a formal API, but provides a more detailed list. `cms_products_list2()`
#' Does use the formal API, but provides less details
#'
#' @param ... Allows you to pass (search) query parameters to apply to the list.
#' When omitted, the full list of products is returned.
#' @param info_type One of `"list"` (default) or `"meta"`. `"list"` returns the actual list
#' whereas `"meta"` returns meta information for the executed query (e.g. number of hits).
#' @returns Returns a `tibble` of products available from <https://data.marine.copernicus.eu> or
#' a named `list` when `info_type = "meta"`. Returns `NULL` in case on-line services are
#' unavailable.
#' @rdname cms_products_list
#' @name cms_products_list
#' @family product-functions
#' @examples
#' cms_products_list()
#' 
#' ## Query a specific product:
#' cms_products_list(freeText = "GLOBAL_ANALYSISFORECAST_PHY_001_024")
#' @author Pepijn de Vries
#' @export
cms_products_list <- function(..., info_type = c("list", "meta")) {
  info_type   <- match.arg(info_type)
  payload     <- .payload_data_list
  payload_mod <- list(...)
  payload[names(payload_mod)] <- payload_mod
  result <-
    "https://data-be-prd.marine.copernicus.eu/api/datasets" |>
    httr2::request() |>
    httr2::req_method("POST") |>
    httr2::req_body_json(payload) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  switch(
    info_type,
    meta = {
      result[names(result) != "datasets"]
    },
    ## default is main data:
    {
      result[["datasets"]] |>
        purrr::map(~purrr::map(.x, list)) |>
        purrr::map_dfr(~ .x |> dplyr::as_tibble(), .id = "product_id") |>
        dplyr::mutate(
          dplyr::across(
            dplyr::everything(),
            function(x) {
              x[unlist(lapply(x, length)) == 0] <- list(NA)
              if (all(unlist(lapply(x, length)) == 1)) {
                unlist(x)
              } else x
            }
          )
        )
    })
}

#' @rdname cms_products_list
#' @name cms_products_list
#' @export
cms_products_list2 <- function(...) {
  clients <- cms_get_client_info()
  clients$catalogues[[1]]$idMapping |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

.payload_data_list <- list(
  facets = c("favorites",
             "timeRange",
             "vertLevels",
             "colors",
             "mainVariables",
             "areas",
             "omis",
             "indicatorFamilies",
             "featureTypes",
             "tempResolutions",
             "sources",
             "processingLevel",
             "directives",
             "communities",
             "originatingCenter"),
  facetValues = structure(list(), names = character(0)),
  freeText = "",
  dateRange =
    list(
      begin     = NA,
      end       = NA,
      coverFull = FALSE),
  favoriteIds   = list(),
  offset        = 0,
  size          = 1000,
  variant       = "summary",
  includeOmis   = TRUE,
  `__myOcean__` = TRUE)