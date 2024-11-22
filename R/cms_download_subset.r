#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('stable')` Subset and download a specific marine product from Copernicus.
#' You need to register an account
#' at <https://data.marine.copernicus.eu> before you can use this function.
#'
#' @include cms_login.r
#' @inheritParams cms_login
#' @param destination File or path where the requested file will be downloaded to.
#' @param product An identifier (type `character`) of the desired Copernicus marine product.
#' Can be obtained with [`cms_products_list`].
#' @param layer The name of a desired layer within a product (type `character`). Can be obtained with [`cms_product_details`].
#' @param variable The name of a desired variable in a specific layer of a product (type `character`).
#' Can be obtained with [`cms_product_details`].
#' @param region Specification of the bounding box as a `vector` of `numeric`s WGS84 lat and lon coordinates.
#' Should be in the order of: xmin, ymin, xmax, ymax.
#' @param timerange A `vector` with two elements (lower and upper value)
#' for a requested time range. The `vector` should be coercible to `POSIXct`.
#' @param verticalrange A `vector` with two elements (minimum and maximum)
#' numerical values for the depth of the vertical layers (if any). Note that values below the
#' sea surface needs to be specified as negative values.
#' @param overwrite A `logical` value. When `FALSE` (default), files at the `destination` won't be
#' overwritten when the exist. Instead an error will be thrown if this is the case. When set to
#' `TRUE`, existing files will be overwritten.
#' @returns Returns a `logical` value invisibly indicating whether the requested file was
#' successfully stored at the `destination`.
#' @rdname cms_download_subset
#' @name cms_download_subset
#' @examples
#' \dontrun{
#' destination <- tempfile("copernicus", fileext = ".nc")
#'
#' ## Assuming that Copernicus account details are provided as `options`
#' cms_download_subset(
#'   destination   = destination,
#'   product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'   layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'   variable      = "sea_water_velocity",
#'   region        = c(-1, 50, 10, 55),
#'   timerange     = c("2021-01-01 UTC", "2021-01-02 UTC"),
#'   verticalrange = c(0, -2)
#' )
#' 
#' mydata <- stars::read_stars(destination)
#' 
#' plot(mydata["vo"])
#' }
#' @author Pepijn de Vries
#' @export
cms_download_subset <- function(
    username = getOption("CopernicusMarine_uid", ""),
    password = getOption("CopernicusMarine_pwd", ""),
    destination,
    product,
    layer,
    variable,
    region,
    timerange,
    verticalrange,
    overwrite = FALSE) {

  if (dir.exists(destination))
    stop("Destination should be a filename not a path")
  if (!overwrite & file.exists(destination))
    stop("Destination file already exists. Set 'overwrite' to TRUE to proceed.")
  
  base_url <- "https://data-be-prd.marine.copernicus.eu/api/download/"
  
  message(crayon::white("Preparing job..."))

  details <- cms_product_details(product, layer, variant = "detailed-v2")

  var_check1 <- names(details) %in% paste0(layer, "/", variable)
  var_check2 <- !(paste0(layer, "/", variable) %in% names(details))
  variable <- c(
    lapply(details[var_check1], `[[`, "subsetVariableIds") |> unlist() |> unname(),
    variable[var_check2]
  ) |> unique()

  scalar <- function(x) structure(x, class = "scalar")
  payload <- list(
    datasetId    = scalar(product),
    subdatasetId = scalar(layer),
    variableIds  = variable)
  
  payload[["subsetValues"]][["extraVariableIds"]] <- variable
  
  if (!missing(region)) {
    payload[["subsetValues"]][["lonMin"]] <- scalar(region[[1]])
    payload[["subsetValues"]][["latMin"]] <- scalar(region[[2]])
    payload[["subsetValues"]][["lonMax"]] <- scalar(region[[3]])
    payload[["subsetValues"]][["latMax"]] <- scalar(region[[4]])
  }
  if (!missing(timerange)) {
    timerange <- timerange |>
      as.POSIXct(tz = "UTC") |>
      as.numeric(origin = "1970-01-01 UTC")*1000
    payload[["subsetValues"]][["timeMin"]] <- scalar(timerange[[1]])
    payload[["subsetValues"]][["timeMax"]] <- scalar(timerange[[2]])
  }
  if (!missing(verticalrange)) {
    payload[["subsetValues"]][["elevationMin"]] <- scalar(verticalrange[[1]])
    payload[["subsetValues"]][["elevationMax"]] <- scalar(verticalrange[[2]])
  }
  
  job <-
    .try_online({
      base_url |>
        httr2::request() |>
        httr2::req_auth_basic(username, password) |>
        httr2::req_body_json(payload, auto_unbox = FALSE) |>
        httr2::req_perform()
    }, "subset-job")
  if (is.null(job)) return(invisible(FALSE))
  job <- httr2::resp_body_json(job)
  
  message(crayon::white("Waiting for job to finish..."))
  repeat {
    job_check <-
      .try_online({
        base_url |>
          paste0(job$jobId) |>
          httr2::request() |>
          httr2::req_perform()
      }, "job-check")
    if (is.null(job_check)) return(invisible(FALSE))
    job_check <- httr2::resp_body_json(job_check)
    
    if (job_check$finished) break
    Sys.sleep(0.5)
  }

  if (is.null(job_check$url)) {
    message(job_check$`_errorDescription`)
    return(invisible(FALSE))
  }
  
  message(crayon::white("Downloading file..."))
  download <-
    .try_online({
      job_check$url |>
        httr2::request() |>
        httr2::req_perform(destination)
    }, "subset-download")
  if (is.null(download)) return(invisible(FALSE))
  
  message(crayon::green("Done"))
  return(invisible(TRUE))
}