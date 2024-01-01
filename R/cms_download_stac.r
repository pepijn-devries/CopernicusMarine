#' List and get STAC files for a Copernicus marine product
#'
#' `r lifecycle::badge('stable')` Full marine data sets can be downloaded using the
#' SpatioTemporal Asset Catalogs (STAC). Use these functions to list download locations and get
#' the files.
#' @inheritParams cms_download_subset
#' @param file_tibble A [`dplyr::tibble()`] with in each row the files to be downloaded.
#' Should be created with [`cms_list_stac_files()`].
#' @param destination A `character` string representing the path location where the downloaded
#' files should be stored.
#' @param show_progress A `logical` value. When `TRUE` (default) the download progress will be shown.
#' This can be useful for large files.
#' @returns In case of `cms_stac_properties` a [`dplyr::tibble()`] is returned with some
#' product properties, It is used as precursor for `cms_list_stac_files`.
#' In case of `cms_list_stac_files` a [`dplyr::tibble()`] is returned containing
#' available URLs (for the specified `product` and `layer`) and some meta information is returned.
#' In case of `cms_download_stac` an invisible `logical` value is returned, indicating whether
#' all requested files are successfully stored at the `destination` path. A `list` of responses
#' (of class [`httr2::response()`]) for all requested download links is included as attribute
#' to the result.
#' @rdname cms_stac
#' @name cms_download_stac
#' @examples
#' \dontrun{
#' ## List some STAC properties for a specific product and layer
#' cms_stac_properties(
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m"
#' )
#' 
#' ## Get the available files for a specific product and layer:
#' file_tibble <-
#'   cms_list_stac_files("GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'                       "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m")
#'
#' dest <- tempdir()
#'
#' ## download the first file from the file_tibble to 'dest'
#' cms_download_stac(file_tibble[1,, drop = FALSE], dest)
#' }
#' @family stac-functions download-functions
#' @author Pepijn de Vries
#' @export
cms_download_stac <- function(file_tibble, destination, show_progress = TRUE, overwrite = FALSE) {
  if (!dir.exists(destination))
    stop(sprintf("The path '%s' is not an existing directory", destination))
  result <- TRUE
  responses <- lapply(seq_len(nrow(file_tibble)), function(i) {
    dest <- file.path(destination, basename(file_tibble$current_path[[i]]))
    if (!overwrite && file.exists(dest))
      stop(sprintf("File '%s' already exists! Use `overwrite=TRUE` to proceed", dest))
    resp <- .try_online({
      req <-
        paste(
          "https:/",
          file_tibble$home[[i]],
          file_tibble$native[[i]],
          file_tibble$current_path[[i]],
          sep = "/"
        ) |>
        httr2::request()
      if (show_progress) req <- req |> httr2::req_progress()
      req |>
        httr2::req_perform(path = dest)
    }, "stac-download")
    if (is.null(resp)) result <- FALSE
    resp
  })
  attr(result, "responses") <- responses
  return(invisible(result))
}