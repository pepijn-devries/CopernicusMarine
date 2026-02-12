#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('experimental')` Subset and download a specific marine product
#' from Copernicus.
#'
#' Currently, credentials are ignored. The subsetting service seems to be
#' public. You can use this function without using your account. This might
#' change in the future.
#' @include cms_login.r
#' @inheritParams cms_login
#' @param product An identifier (type `character`) of the desired Copernicus marine product.
#' Can be obtained with [`cms_products_list`].
#' @param layer The name of a desired layer within a product (type `character`). Can be obtained with [`cms_product_services`] (listed as `id` column).
#' @param variable The name of a desired variable in a specific layer of a product (type `character`).
#' Can be obtained with [`cms_product_details`].
#' @param region Specification of the bounding box as a `vector` of `numeric`s WGS84 lat and lon coordinates.
#' Should be in the order of: xmin, ymin, xmax, ymax.
#' @param timerange A `vector` with two elements (lower and upper value)
#' for a requested time range. The `vector` should be coercible to `POSIXct`.
#' @param verticalrange A `vector` with two elements (minimum and maximum)
#' numerical values for the depth of the vertical layers (if any). Note that values below the
#' sea surface needs to be specified as negative values.
#' @param progress A logical value. When `TRUE` (default) progress is reported to the console.
#' Otherwise, this function will silently proceed.
#' @param crop `r lifecycle::badge('deprecated')`. This version now
#' uses the GDAL library to handle the subsetting and downloading of
#' subsets. The `crop` argument is therefore no longer supported.
#' @param asset Type of asset to be used when subsetting data. Should be one
#' of `"default"`, `"ARCO"`, `"static"`, `"omi"`, or `"downsampled4"`.
#' When missing, set to `NULL` or set to `"default"`, it will use the first
#' asset available for the requested product and layer, in the order as listed
#' before.
#' @param ... Ignored (reserved for future features).
#' @returns Returns a [stars::st_as_stars()] object.
#' @rdname cms_download_subset
#' @name cms_download_subset
#' @examples
#' if (interactive()) {
#'
#'   mydata <- cms_download_subset(
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'     variable      = c("uo", "vo"),
#'     region        = c(-1, 50, 10, 55),
#'     timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
#'     verticalrange = c(0, -2)
#'   )
#'
#'   plot(mydata["vo"])
#' } else {
#'   message("Make sure to run this in an interactive environment")
#' }
#' @author Pepijn de Vries
#' @export
cms_download_subset <- function(
    username = cms_get_username(),
    password = cms_get_password(),
    product,
    layer,
    variable,
    region,
    timerange,
    verticalrange,
    progress = TRUE,
    crop,
    asset,
    ...) {
  if (missing(asset)) asset <- NULL
  if (is.null(asset)) asset <- "default"
  asset <- match.arg(asset, c("default", "ARCO", "static", "omi", "downsampled4"))
  
  if (!missing(crop))
    rlang::warn("The `crop` argument is deprecated and ignored")
  
  if (missing(variable) || is.null(variable)) variable <- character(0)
  subset_request <- list(
    product       = product,
    layer         = layer,
    variable      = variable,
    region        = if (missing(region)) NULL else region,
    timerange     = if (missing(timerange)) NULL else timerange,
    verticalrange = if (missing(verticalrange)) NULL else verticalrange
  )
  if (progress)
    cli::cli_progress_step("Obtaining best or specified service")
  service <- .get_best_arco_service_type(
    subset_request, "", progress, asset)
  
  if (progress)
    cli::cli_progress_step("Contacting {.href [service]({service$href}/.zmetadata)}")
  
  numthr <- Sys.getenv("GDAL_NUM_THREADS")
  Sys.setenv(GDAL_NUM_THREADS = "ALL_CPUS")
  Sys.setenv(GDAL_HTTP_MULTICURL = "YES")
  Sys.setenv(GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR")
  
  mdim_proxy <-
    service$href |>
    .uri_to_vsi(progress) |>
    .get_stars_proxy(variable)
  
  if (progress)
    cli::cli_progress_step("Subsetting and downloading data")

  dms <- stars::st_dimensions(mdim_proxy)
  idx <- lapply(names(dms), \(dm) {
    idx_start <- stars::st_get_dimension_values(mdim_proxy, dm, where = "start")
    idx_end   <- stars::st_get_dimension_values(mdim_proxy, dm, where = "end")
    if (dm != "time") {
      idx_start <- as.numeric(idx_start)
      idx_end   <- as.numeric(idx_end)
    }
    comparator <-
      switch(
        dm,
        longitude = region[c(1, 3)],
        latitude = region[c(2, 4)],
        time = lubridate::as_datetime(timerange),
        elevation = verticalrange
      )
    if (length(comparator) == 1) comparator <- comparator[c(1,1)]
    comparator <- sort(comparator)
    idx <- if (length(comparator) == 0) rep(TRUE, length(idx_end)) else {
      (idx_end > comparator[[1]] & idx_end < comparator[[2]]) |
      (idx_start >= comparator[[1]] & idx_start <= comparator[[2]]) |
        (idx_end > comparator[[1]] & idx_start <= comparator[[2]])

    }
    result <- which(idx)
    if (length(result) == 0)
      rlang::abort(sprintf("Dimension '%s' not within selected range", dm))
    result
  })

  mdim_proxy <- rlang::inject(mdim_proxy[,!!!idx])

  result <- .muffle_403({
    stars::st_as_stars(mdim_proxy)
  })
  
  Sys.setenv(GDAL_NUM_THREADS = numthr)

  cli::cli_progress_done()
  result
}

.as_bbox <- function(x, crs_arg) {
  if (is.numeric(x) && is.null(names(x))) {
    names(x) <- c("xmin", "ymin", "xmax", "ymax")
  }
  x <- sf::st_bbox(x)
  if (is.na(sf::st_crs(x))) sf::st_crs(x) <- crs_arg
  x
}

.get_refsys <- function(dim_props) {
  ref_sys <-
    lapply(dim_props, \(x) {
      if (!is.null(x$axis) && x$axis %in% c("x", "y")) {
        x$reference_system
      } else {
        NULL
      }
    }) |>
    unlist() |>
    unique()
  if (length(ref_sys) > 1) stop("Axes use mix of reference systems")
  ref_sys
}

.get_best_arco_service_type <- function(subset_request, dataset_version, progress,
                                        asset) {

  meta <-
    cms_product_metadata(subset_request$product) |>
    dplyr::filter(startsWith(.data$id, subset_request$layer)) |>
    dplyr::filter(dplyr::row_number() == 1)
  
  var_properties <- meta$properties[[1]]$`cube:variables`
  dim_properties <- meta$properties[[1]]$`cube:dimensions`
  
  if (!is.null(subset_request$region))
    subset_request$region <-
    .as_bbox(subset_request$region, .get_refsys(dim_properties))
  
  variables <- lapply(meta$properties[[1]]$`cube:variables`,
                      `[[`, "standardName")
  variables[lengths(variables) == 0] <- NA
  if (length(subset_request$variable) == 0) variables <- names(variables) else {
    variables <- 
      names(variables)[
        names(variables) %in% subset_request$variable |
          variables %in% subset_request$variable
      ]
  }
  
  dimnames       <- names(dim_properties)
  time_chunked   <- meta$assets[[1]]$timeChunked
  geo_chunked    <- meta$assets[[1]]$geoChunked
  static         <- meta$assets[[1]]$static
  omi            <- meta$assets[[1]]$omi
  ds4            <- meta$assets[[1]]$downsampled4
  
  if (asset == "default" && (!is.null(time_chunked) || !is.null(geo_chunked)))
    asset <- "ARCO"
  
  if ((!is.null(static) && asset == "default") || asset == "static") {
    result <- static
    asset <- "static"
  } else if ((!is.null(omi) && asset == "default") || asset == "omi") {
    result <- omi
    asset <- "omi"
  } else if ((!is.null(ds4) && asset == "default") || asset == "downsampled4") {
    result <- ds4
    asset <- "ds4"
  }
  
  if (asset == "ARCO") { ## Time or geo-chunked
    
    if (!is.null(time_chunked)) {
      indices_timec  <- .get_chunk_indices(subset_request, variables,
                                           time_chunked, dimnames, dim_properties)
      count_timec    <- .get_chunk_count(indices_timec) |> unlist() |> sum()
    } else {
      count_timec <- 0
      count_geoc  <- 1
    }
    if (!is.null(geo_chunked)) {
      indices_geoc   <- .get_chunk_indices(subset_request, variables,
                                           geo_chunked, dimnames, dim_properties)
      count_geoc     <- .get_chunk_count(indices_geoc) |> unlist() |> sum()
    } else {
      count_timec <- 1
      count_geoc  <- 0
    }
    
    if (!is.null(time_chunked)) {
      indices_timec  <- .get_chunk_indices(subset_request, variables,
                                           time_chunked, dimnames, dim_properties)
      count_timec    <- .get_chunk_count(indices_timec) |> unlist() |> sum()
    } else {
      count_timec <- 0
      count_geoc  <- 1
    }
    if (!is.null(geo_chunked)) {
      indices_geoc   <- .get_chunk_indices(subset_request, variables,
                                           geo_chunked, dimnames, dim_properties)
      count_geoc     <- .get_chunk_count(indices_geoc) |> unlist() |> sum()
    } else {
      count_timec <- 1
      count_geoc  <- 0
    }

    if (count_timec < count_geoc) {
      result <- time_chunked
    } else {
      result <- geo_chunked
    }
  } else {
    indices <- .get_chunk_indices(subset_request, variables,
                                  result, dimnames, dim_properties)

  }

  return (result)
}

.get_chunk_count <- function(indices) {
  lapply(indices, function(x) lapply(x, function(y) length(unique(y)))) |>
    lapply(dplyr::as_tibble) |>
    dplyr::bind_rows() |>
    dplyr::summarise(dplyr::across(dplyr::everything(), prod))
}

.get_chunk_indices <- function(subset_request, variables, chunk_info, dims, dim_props) {
  chunk_dimlen <-
    lapply(dims, function(y) chunk_info$viewDims[[y]]$chunkLen) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      .generic = purrr::pmap(dplyr::pick(dplyr::everything()), \(...) {
        unique(stats::na.omit(c(...)))
      }),
      .check = lengths(.data$.generic) == 1L,
      dim = dims)
  
  if (!all(chunk_dimlen$.check))
    rlang::abort(c(x = "Detected parameters with incompatible chunk dimensions",
                   i = "Please report at <https://github.com/pepijn-devries/CopernicusMarine/issues>"))
  
  dims_alt <- c(elevation = "verticalrange", time = "timerange")
  chunk_ids <-
    lapply(structure(dims, names = dims), function(dim) {
      dim_range <- unlist(dim_props[[dim]]$extent)
      
      alt_dim <- dim_props[[dim]]$axis
      if (!is.null(alt_dim) && alt_dim %in% c("x", "y")) {
        req_range <- subset_request$region[paste0(alt_dim, c("min", "max"))] |> unname()
      } else {
        req_range <- subset_request[[
          dims_alt[[which(names(dims_alt) == dim)]]
        ]]
        if (is.null(req_range) || all(is.na(req_range)))
          req_range <- dim_range else
            req_range <- range(req_range, na.rm = TRUE)
      }
      
      if (dim_props[[dim]]$type == "temporal") {
        dim_range <- lubridate::as_datetime(dim_range)
        req_range <- lubridate::as_datetime(req_range)
        step <- dim_props[[dim]]$step
        if (!is.null(step)) dim_props[[dim]]$step <- .code_to_period(step)
      }
      my_range <-
        c(
          max(c(req_range[[1L]], dim_range[[1L]]), na.rm = TRUE),
          min(c(req_range[[2L]], dim_range[[2L]]), na.rm = TRUE)
        )
      
      dat <- chunk_info$viewDims[[dim]]$coords
      coord_values <- if(dat$type == "minMaxStep") {
        dat_len <- chunk_info$viewDims[[dim]]$chunkLen[[1]]
        dat_len <- dat_len*ceiling(dat$len/dat_len)
        
        dim_range[[1]] + (seq_len(dat_len) - 1L) * dim_props[[dim]]$step
        
      } else if (dat$type == "explicit") {
        result <- dim_props[[dim]]$values |> unlist()
        if (dim_props[[dim]]$type == "temporal")
          result <- lubridate::as_datetime(result)
        result
      } else {
        rlang::abort(c(x = sprintf("Dimension type '%s' not implemented", dat$type),
                       i = "Please contact developers with regex"))
      }
      if (length(coord_values) == 1) flex <- 1e-6 else {
        flex <- (coord_values |> diff() |> min())/10
      }
      indices <- which(coord_values >= (my_range[[1]] - flex) &
                         coord_values <= (my_range[[2]] + flex))
      dim_len <-
        chunk_dimlen |>
        dplyr::filter(.data$dim == .env$dim) |>
        dplyr::select(dplyr::any_of(variables)) |>
        as.list()
      
      lapply(dim_len, function(dl) floor((indices - 1L)/dl))
      
    })
  
  chunk_ids
}

.code_to_period <- function(x) {
  switch(
    x,
    PT1H = lubridate::period(1, "hour"),
    PT5H = lubridate::period(6, "hour"),
    P1D = lubridate::period(1, "days"),
    P1M = lubridate::period(1, "months"),
    stop("Unknown time period '%s'", x)
  )
}

#' Get a proxy stars object from a Zarr service
#' 
#' The advantage of
#' [`stars_proxy` objects](https://r-spatial.github.io/stars/articles/stars2.html#stars-proxy-objects),
#' is that they do not contain any data. They are therefore fast to handle
#' and consume only limited memory. You can still manipulate the object
#' lazily (like selecting slices). These operation are only executed when
#' calling [stars::st_as_stars()] or `plot()` on the object.
#' @inheritParams cms_download_subset
#' @param asset An asset that is available for the `product`.
#' Should be one of `"native"`, `"wmts"`, `"timeChunked"`, `"downsampled4"`,
#' or `"geoChunked"`.
#' @returns A [`stars_proxy` object](https://r-spatial.github.io/stars/articles/stars2.html#stars-proxy-objects)
#' @author Pepijn de Vries
#' @examples
#' if (interactive()) {
#'   myproxy <- cms_zarr_proxy(
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'     variable      = c("uo", "vo"),
#'     asset         = "timeChunked")
#'   plot(myproxy["uo",1:200,1:100,50,1], axes = TRUE)
#' }
#' @export
cms_zarr_proxy <-
  function(
    product,
    layer,
    variable,
    asset
  ) {
    if (missing(variable) || is.null(variable)) variable <- character(0)
    meta <-
      cms_product_metadata(product) |>
      dplyr::filter(startsWith(.data$id, .env$layer)) |>
      dplyr::filter(dplyr::row_number() == 1)
    meta$assets[[1]][[asset]]$href |>
      .uri_to_vsi(FALSE) |>
      .get_stars_proxy(variable)
  }
