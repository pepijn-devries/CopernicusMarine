#' @examples
#' cms_download_native(
#'   destination   = tempdir(),
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m"
#' )
#' 
#' @export
cms_download_native <- function(destination, product, layer, ...) {
  services <-
    cms_product_services(product) |>
    dplyr::filter(startsWith(.data$id, layer))
  native_url <- services$native_href
  ## TODO regex used in python toolbox to parse url
  parse_regex <- "^(http|https):\\/\\/([\\w\\-\\.]+)(:[\\d]+)?(\\/.*)"
  
  m <- gregexpr(parse_regex, native_url, perl = TRUE)
  m_start  <- attr(m[[1]], "capture.start")
  m_length <- attr(m[[1]], "capture.length")
  fragments <-
    mapply(function(start, len) {
      substr(native_url, start, start + len - 1)
    }, start = m_start, len = m_length)
  
  endpoint_url <- paste(fragments[1], "://", fragments[2], sep = "")
  full_path    <- fragments[4]
  segments     <- strsplit(full_path, "/") |> unlist()
  bucket       <- segments[[2]]
  path         <- segments[-1:-2] |> paste(collapse = "/")

  ## The line below will list objects for a completely different product :S
  my_bucketlist <-
    aws.s3::get_bucket(
      bucket = segments[[2]],
      region = "",
      base_url = fragments[[2]]
    )
  ## Same as above, but data.frame representation:
  my_bucketlist_r <-
    my_bucketlist |>
    lapply(unclass) |>
    lapply(as.data.frame) |>
    dplyr::bind_rows()
  
  ## The bucket below does exist
  aws.s3::bucket_exists(
    bucket = segments[[2]],
    region = "",
    path = "native/GLOBAL_ANALYSISFORECAST_BGC_001_028/cmems_mod_glo_bgc-bio_anfc_0.25deg_P1D-m_202311/2022/01/mercatorbiomer4v2r1_global_mean_bio_20220101.nc",
    base_url = fragments[[2]]
  )

  ## The connection below works! But it is for the wrong product!
  # path = "native/GLOBAL_ANALYSISFORECAST_BGC_001_028/cmems_mod_glo_bgc-bio_anfc_0.25deg_P1D-m_202311/2022/01/mercatorbiomer4v2r1_global_mean_bio_20220101.nc",
  con <- aws.s3::s3connection(
    "native/GLOBAL_ANALYSISFORECAST_BGC_001_028/cmems_mod_glo_bgc-bio_anfc_0.25deg_P1D-m_202311/2022/01/mercatorbiomer4v2r1_global_mean_bio_20220101.nc",
    region = "",
    bucket = segments[[2]],
    base_url = fragments[[2]]
  )
  ## Can read from this connection, read a fragment of 1MB:
  temp <- readBin(con, "raw", 1024L)
  close(con)

  aws.s3::bucket_exists(segments[[2]], region = "", base_url = fragments[[2]])
    
}
