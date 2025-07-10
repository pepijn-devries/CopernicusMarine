#' Deprecated
#'
#' `r lifecycle::badge('deprecated')` Full marine data sets can be downloaded using the
#' SpatioTemporal Asset Catalogs (STAC). The API for interacting with these files is
#' no longer operational. Please use `cms_download_native()` instead.
#' @inheritParams cms_download_subset
#' @param file_tibble Ignored
#' @param destination Ignored
#' @param show_progress Ignored
#' @returns returns `NULL`, as the API is no longer available
#' @rdname cms_stac
#' @name cms_download_stac
#' @family stac-functions download-functions
#' @author Pepijn de Vries
#' @export
cms_download_stac <- function(file_tibble, destination, show_progress = TRUE, overwrite = FALSE) {
  .Deprecated("cms_download_native")
  return(invisible(NULL))
}