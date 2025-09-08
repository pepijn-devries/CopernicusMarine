#' Download raw files as provided to Copernicus Marine
#' 
#' `r lifecycle::badge('stable')` Full marine data sets can be downloaded using the functions
#' documented here. Use `cms_list_native_files()` to list available files, and
#' `cms_download_native()` to download specific files. Files are usually organised per product,
#' layer, year, month and day.
#' @inheritParams cms_download_subset
#' @param destination Path where to store the downloaded file(s).
#' @param pattern A regular expression ([regex](https://en.wikipedia.org/wiki/Regular_expression))
#' pattern. Only paths that match the pattern will be returned. It can be used
#' to select specific files. For instance if `pattern = "2022/06/"`, only files for the
#' year 2022 and the month June will be listed (assuming that the file path is structured as such, see
#' examples)
#' @param prefix A `character` string. A prefix to be added to the search path of the files.
#' Only the matching file (info) is downloaded (generally faster then using `pattern`)
#' @param progress A `logical` value. When `TRUE` a progress bar is shown.
#' @param max A maximum number of records to be returned.
#' @param ... Ignored
#' @returns Returns `NULL` invisibly.
#' @author Pepijn de Vries
#' @examples
#' if (interactive()) {
#'   cms_list_native_files(
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
#'     prefix        = "2022/06/"
#'   )
#' 
#' ## If you omit the prefix, you may want to limit the
#' ## number of results by setting `max`
#'   cms_list_native_files(
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
#'     max           = 10
#'   )
#'   
#' ## Prefix can be omitted when not relevant:
#'   cms_list_native_files(product = "SEALEVEL_GLO_PHY_MDT_008_063")
#'   
#' ## Use 'pattern' to download a file for a specific day:
#'   cms_download_native(
#'     destination   = tempdir(),
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
#'     prefix        = "2022/06/",
#'     pattern       = "m_20220630"
#'   )
#' }
#' @rdname cms_download_native
#' @export
cms_download_native <- function(destination, product, layer, pattern, prefix, progress = TRUE, ...) {
  if (missing(pattern)) pattern <- ""
  if (missing(prefix)) prefix <- ""

  file_list <- cms_list_native_files(product, layer, pattern, prefix)
  
  for (i in nrow(file_list)) {
    path_out <- unlist(strsplit(file_list$Key[[i]], "/"))[-1:-2]
    file_out <- path_out[length(path_out)]
    path_out <- do.call(file.path, as.list(utils::head(path_out, -1)))
    path_out <- file.path(destination, path_out)
    
    j <- 0
    while (!dir.exists(path_out)) {
      dir.create(path_out, recursive = TRUE)
      j <- j + 1
      if (j > 10) stop("Failed to create directory for downloaded file")
    }
    
    con_out <- file(file.path(path_out, file_out), "wb")
    con_in <- aws.s3::s3connection(
      file_list$Key[[i]],
      region = "",
      bucket = file_list$Bucket[[1]],
      base_url = file_list$base_url
    )
    
    if (progress) cli::cli_inform("Downloading file {i} of {nrow(file_list)}.")
    if (progress) cli::cli_progress_bar(type = "download", total = as.numeric(file_list$Size))
    
    testing_mode <- Sys.getenv("R_COPERNICUS_MARINE_TESTING") == "TRUE"
    tryCatch({
      while (TRUE) {
        chunk <- readBin(con_in, "raw", 10240L)
        writeBin(chunk, con_out)
        if (progress) cli::cli_progress_update(length(chunk) |> as.numeric())
        if (length(chunk) == 0 || testing_mode) break
      }
      
    },
    error = function(e) {
      stop(e)
    },
    finally = {
      
      close(con_in)
      close(con_out)
      
    })
    if (progress) cli::cli_progress_done()
  }
  return (invisible())
}

#' @rdname cms_download_native
#' @export
cms_list_native_files <- function(product, layer, pattern, prefix, max = Inf, ...) {
  if (missing(pattern)) pattern <- ""
  if (missing(layer)) layer <- ""
  if (missing(prefix)) prefix <- NULL
  s3_info <- .preprocess_s3(product, layer, "native_href")
  if (is.null(s3_info)) return(NULL)

  with(s3_info, {
    aws.s3::get_bucket_df(
      region = "",
      bucket = bucket,
      base_url = endpoint,
      prefix = paste(c(path, prefix), collapse = "/"),
      max = max
    ) |>
      dplyr::filter(grepl(pattern, .data$Key, perl = TRUE)) |>
      dplyr::mutate(base_url = endpoint)
  }) |>
    dplyr::as_tibble()
}

.preprocess_s3 <- function(product, layer, what, ...) {
  services <-
    cms_product_services(product)
  if (is.null(services)) return(NULL)
  services <-
    services |>
    dplyr::filter(startsWith(.data$id, layer))
  service_url <- services[[what]]
  service_url <- unlist(service_url)
  if (length(service_url) > 1) stop("Unexpected multiple URLs")
  
  ## regex used in python toolbox to parse url
  parse_regex <- "^(http|https):\\/\\/([\\w\\-\\.]+)(:[\\d]+)?(\\/.*)"
  
  m <- gregexpr(parse_regex, service_url, perl = TRUE)
  m_start  <- attr(m[[1]], "capture.start")
  m_length <- attr(m[[1]], "capture.length")
  fragments <-
    mapply(function(start, len) {
      substr(service_url, start, start + len - 1)
    }, start = m_start, len = m_length)
  segments <- strsplit(fragments[4], "/") |> unlist()
  
  list(
    endpoint     = fragments[2],
    endpoint_url = paste(fragments[1], "://", fragments[2], sep = ""),
    full_path    = fragments[4],
    bucket       = segments[[2]],
    path         = segments[-1:-2] |> paste(collapse = "/")
  )
  
}