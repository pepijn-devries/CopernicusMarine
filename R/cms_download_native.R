#' @examples
#' cms_download_native(
#'   destination   = tempdir(),
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m",
#'   pattern       = "m_20220630"
#' )
#' 
#' @export
cms_download_native <- function(destination, product, layer, pattern, ...) {
  browser() #TODO
  if (missing(pattern)) pattern <- ""

  file_list <- cms_list_native_files(product, layer, pattern)
  if (nrow(file_list)) stop("TODO multiple files download not yet implemented")
  con <- aws.s3::s3connection(
    file_list$Key[[1]],
    region = "",
    bucket = file_list$Bucket[[1]],
    base_url = file_list$base_url
  )
  ## TODO read from s3 connection and write to local file (and optionally show progress)
  temp <- readBin(con, "raw", 1024L)
  close(con)

}

#' @examples
#' cms_list_native_files(
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy_anfc_0.083deg_PT1H-m"
#' )
#' @export
cms_list_native_files <- function(product, layer, pattern, ...) {
  s3_info <- .preprocess_native(product, layer)
  
  if (is.null(s3_info)) return(NULL)
  
  with(s3_info, {
    aws.s3::get_bucket_df(
      path,
      region = "",
      bucket = bucket,
      base_url = endpoint
    ) |>
      dplyr::filter(grepl(pattern, .data$Key, perl = TRUE)) |>
      dplyr::mutate(base_url = endpoint)
  })
}

.preprocess_native <- function(product, layer, ...) {
  services <-
    cms_product_services(product)
  if (is.null(services)) return(NULL)
  services <-
    services |>
    dplyr::filter(startsWith(.data$id, layer))
  native_url <- services$native_href
  
  ## regex used in python toolbox to parse url
  parse_regex <- "^(http|https):\\/\\/([\\w\\-\\.]+)(:[\\d]+)?(\\/.*)"
  
  m <- gregexpr(parse_regex, native_url, perl = TRUE)
  m_start  <- attr(m[[1]], "capture.start")
  m_length <- attr(m[[1]], "capture.length")
  fragments <-
    mapply(function(start, len) {
      substr(native_url, start, start + len - 1)
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