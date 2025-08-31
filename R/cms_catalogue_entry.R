#' Get information about Copernicus Marine clients
#' 
#' `r lifecycle::badge('stable')` This function retrieves the client information
#' from the Copernicus Marine Service.
#' Among others, it lists where to find the catalogues required by this package
#' @param ... Ignored
#' @returns In case of success it returns a named `list` with information about the available
#' Copernicus Marine clients.
#' @author Pepijn de Vries
#' @examples
#' if (interactive()) {
#'   cms_get_client_info()
#' }
#' @export
cms_get_client_info <- function(...) {
  ci <- .try_online({
    "https://stac.marine.copernicus.eu/clients-config-v1" |>
      httr2::request() |>
      httr2::req_perform()
  }, "client-info-page")
  if (is.null(ci)) return(NULL) else return(httr2::resp_body_json(ci))
}
