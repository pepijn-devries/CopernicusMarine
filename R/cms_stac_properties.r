#' @rdname cms_stac
#' @name cms_stac_properties
#' @export
cms_stac_properties <- function(product, layer) {
  services <-
    cms_product_services(product) |>
    dplyr::filter(!is.na(.data$`WWW:STAC`))
  if (!missing(layer)) services <- services |> dplyr::filter(layer == !!layer)
  services <- services$`WWW:STAC` |> unlist()
  
  .props <- function(stac_url) {

    x <- .try_online({
      httr2::request(stac_url) |>
        httr2::req_perform()
    }, "stac-properties")
    if (is.null(x)) return(NULL)
    if (is.null(x$headers$`content-type`) || is.na(x$headers$`content-type`))
      x$headers$`content-type` <- "application/json"
    return(httr2::resp_body_json(x))
  }
  props <- purrr::map(services, ~{
    .props(.x)$assets$native |>
      dplyr::as_tibble()
  }) |> dplyr::bind_rows()
  
  return(props)
}
