#' List and get FTP files for a Copernicus marine product
#'
#' `r lifecycle::badge('deprecated')` Full marine data sets can be downloaded using the
#' File Transfer Protocol (FTP). Use these functions to list download locations and get
#' the files.
#'
#' @param url The URL of the file to be downloaded. Obtain this URL with
#' [`copernicus_ftp_list`].
#' @param show_progress A `logical` value. When `TRUE` (default) the download progress will be shown.
#' This can be useful for large files.
#' @param recursive A `logical` value. When `TRUE` all nested files will be listed.
#' @param overwrite A `logical` value. When `FALSE` (default), files at the `destination` won't be
#' overwritten when the exist. Instead an error will be thrown if this is the case. When set to
#' `TRUE`, existing files will be overwritten.
#' @param subdir A `character` string of a subdir which will be appended to the obtained ftp address.
#' @inheritParams copernicus_download_motu
#' @returns In case of `copernicus_ftp_list` a `tibble` is returned containing available URLs
#' (for the specified product and layer) and some meta information is returned.
#' In case of `copernicus_ftp_get` an invisible `logical` value is returned, indicating whether
#' the requested file is successfully stored at the `destination` path.
#' @rdname copernicus_ftp
#' @name copernicus_ftp_list
#' @examples
#' \dontrun{
#' ## Assuming that Copernicus account details are provided as `options`
#' cop_ftp_files <- copernicus_ftp_list("GLOBAL_OMI_WMHE_heattrp")
#' 
#' destination   <- tempdir()
#' 
#' copernicus_ftp_get(cop_ftp_files$url[[1]], destination)
#' }
#' @author Pepijn de Vries
#' @export
copernicus_ftp_list <- function(
    product, layer,
    username  = getOption("CopernicusMarine_uid", ""),
    password  = getOption("CopernicusMarine_pwd", ""),
    recursive = TRUE,
    subdir    = NULL) {
  .Deprecated("cms_list_stac_files")
  name <- NULL # workaround for 'no visible binding global for global variable'
  dirlist <- function(url){
    dir_result <-
      .try_online({
        url |>
          httr2::request() |>
          httr2::req_method("LIST") |>
          .ftp_auth(username, password) |>
          httr2::req_options(dirlistonly = TRUE) |>
          httr2::req_perform()
      }, "Copernicus")
    if (is.null(dir_result)) return(NULL)
 
    dir_result <-
      dir_result |>
      httr2::resp_body_raw() |>
      rawToChar() |>
      readr::read_table(
        col_names = c("flags", "len", "protocol", "protocol2", "size", "month", "day", "time", "name"),
        col_types = readr::cols(
          flags     = readr::col_character(),
          len       = readr::col_integer(),
          protocol  = readr::col_character(),
          protocol2 = readr::col_character(),
          size      = readr::col_number(),
          month     = readr::col_character(),
          day       = readr::col_integer(),
          time      = readr::col_character(),
          name      = readr::col_character())) |>
      dplyr::mutate(url = paste0(url, name)) |>
      dplyr::select(!dplyr::any_of(c("protocol2", "name"))) |>
      dplyr::rowwise() |>
      dplyr::group_map(~{
        if (recursive && startsWith(..1$flags, "d")) dirlist(sprintf("%s/", ..1$url)) else ..1
      }) |>
      dplyr::bind_rows()
  }

  base_url <- copernicus_product_services(product)
  if (length(base_url) == 0) return(NULL)

  if (missing(layer)) {
    base_url <- dirname(base_url$ftp)[[1]]
  } else {
    base_url <- base_url |> dplyr::filter(layer == {{layer}}) |> dplyr::pull("ftp")
  }
  base_url <- paste(c(base_url, subdir), collapse = "/")

  result <- dirlist(paste0(base_url, "/"))
  return(result)
}

#' @rdname copernicus_ftp
#' @name copernicus_ftp_get
#' @export
copernicus_ftp_get <- function(
    url, destination, show_progress = TRUE, overwrite = FALSE,
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", "")) {
  .Deprecated("cms_download_stac")
  if (!dir.exists(destination)) stop("'destination' either doesn't exist or is not a directory!")
  destination <- file.path(destination, basename(url))

  if (!overwrite && file.exists(destination))
    stop("Destination file already exists. Set 'overwrite' to TRUE to proceed.")
  result <-
    .try_online({
      url <-
        url |>
        httr2::request() |>
        .ftp_auth(username, password)
      if (show_progress) url <- url |> httr2::req_progress()
      url |> httr2::req_perform(destination)
    }, "Copernicus")

  return(invisible(!is.null(result)))
}

.ftp_auth <- function(x, pwd, uid) {
  x |>
    httr2::req_options(
      httpauth = 1, # 1 = basic authorisation
      userpwd  = paste0(utils::URLencode(pwd), ":", utils::URLencode(uid)))
}