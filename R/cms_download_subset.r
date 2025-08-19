#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('questioning')` Subset and download a specific marine product from Copernicus.
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
#' @param progress TODO
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
#'   variable      = c("uo", "vo"),
#'   region        = c(-1, 50, 10, 55),
#'   timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
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
    username = cms_get_username(),
    password = cms_get_password(),
    destination,
    product,
    layer,
    variable,
    region,
    timerange,
    verticalrange,
    overwrite = FALSE,
    progress = TRUE) {
  
  if (Sys.getenv("COPERNICUS_R_MODE") != "EXPERIMENTAL") {
    message(paste("Subsetting is currently not possible with this package.",
                  "Please check https://github.com/pepijn-devries/CopernicusMarine for the latest news", sep = "\n"))
    return(invisible())
  }
  
  subset_request <- list(
    product       = product,
    layer         = layer,
    variable      = variable,
    region        = if (missing(region)) NULL else .as_bbox(region),
    timerange     = if (missing(timerange)) NULL else timerange,
    verticalrange = if (missing(verticalrange)) NULL else verticalrange
  )
  service <- .get_best_arco_service_type(subset_request, "")
  dims <- names(attributes(service))
  dims <- dims[dims != "names"]
  
  if (progress) rlang::inform("Downloading zarr meta information")
  
  serv_props <-
    dplyr::tibble(
      var        = variable,
      serv_props = lapply(variable, function(x) .get_xarray_properties(service, x))
    ) |>
    dplyr::group_by(.data$var) |>
    dplyr::summarise(
      zattrs  = list(dplyr::as_tibble(.data$serv_props[[1]]$zattrs)),
      zarray  = list(dplyr::as_tibble(lapply(.data$serv_props[[1]]$zarray, \(x) {
        if (length(x) == 1) x else list(x)
      }))),
      dims    = list(.data$serv_props[[1]]$dims),
      .groups = "keep"
    ) |>
    tidyr::unnest("zarray")
  
  if (progress) rlang::inform("Downloading chunk data")
  
  ## TODO this is not the outer dimension. it is only the dimension of 1 chunk
  outer_dimensions <-
    lapply(dims, function(dm) dplyr::tibble(
      outer_dim = dm,
      length = dplyr::as_tibble(service$viewDims[[dm]]$chunkLen),
      length2 = dplyr::as_tibble(lapply(attributes(service)[[dm]]$chunk_id, \(x)
                                        length(unique(x))))
    )) |>
    dplyr::bind_rows() |>
    tidyr::unnest(c("length", "length2"), names_sep = "_") |>
    tidyr::pivot_longer(-1, names_sep = "_", names_to = c("len", "var")) |>
    dplyr::group_by(.data$outer_dim, .data$var) |>
    dplyr::summarise(
      n_outer = prod(value),
      .groups = "keep"
    ) |>
    dplyr::group_by(.data$var) |>
    dplyr::summarise(
      outer_dimensions = list(as.list(structure(.data$n_outer, names = .data$outer_dim))),
      .groups = "keep"
    ) |>
    dplyr::ungroup()
  
  chunk_id <-
    lapply(dims, function(dm) attributes(service)[[dm]]$chunk_id) |>
    lapply(dplyr::as_tibble)
  chunk_id <- dplyr::tibble(chunk_id = chunk_id, dim = dims) |>
    tidyr::unnest("chunk_id") |>
    dplyr::distinct() |>
    tidyr::pivot_longer(variable, names_to = "var", values_to = "id") |>
    tidyr::pivot_wider(id_cols = "var", names_from = "dim", values_from = "id",
                       values_fn = list) |>
    tidyr::expand_grid() |>
    dplyr::group_by(.data$var) |>
    dplyr::group_modify(~{
      do.call(tidyr::expand_grid, lapply(., `[[`, 1)) |>
        dplyr::as_tibble()
    }) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      combi_id = paste(.data$time, .data$elevation, .data$latitude, .data$longitude, sep = ".")
    ) |>
    dplyr::mutate(
      chunk_url = {
        cg <- dplyr::cur_group()
        mapply(sprintf, fmt = "%s/%s/%s", service$href, .data$var, .data$combi_id,
               SIMPLIFY = FALSE) |>
          lapply(httr2::request)
      },
      ## TODO checkout and set max request from meta data
      chunk_data = httr2::req_perform_parallel(.data$chunk_url, progress = progress),
      chunk_data = lapply(.data$chunk_data, httr2::resp_body_raw)
    )
  if (progress) rlang::inform("Decompressing data")
  ## TODO time chunk combo id: 1 = time index, 2 = elevation index
  chunk_id <-
    dplyr::left_join(
      chunk_id,
      serv_props,
      by = "var"
    ) |>
    dplyr::mutate(
      chunk_data = lapply(seq_along(.data$chunk_data), \(i) {
        if (.data$compressor[[i]]$id != "blosc") rlang::abort("Unkown compressor '%s'",
                                                              .data$compressor[[i]]$id)
        ## TODO check which zarr version is being used (2 or 3)
        blosc::blosc_decompress(x        = .data$chunk_data[[i]],
                                dtype    = .data$dtype[[i]],
                                na_value = .data$fill_value[[i]])
      })
    )
  ## chunk dim
  chunk_dim <- lapply(dims, \(dm) dplyr::as_tibble(service$viewDims[[dm]]$chunkLen)) |>
    dplyr::bind_rows()
  temp <- array(chunk_id$chunk_data[[1]], dim = rev(structure(chunk_dim[[1]], names = dims)))
  temp <- stars::st_as_stars(temp)
  ## TODO set all dimensions (also time and elevation)
  temp <- stars::st_set_dimensions(
    temp, "longitude",
    values = service$viewDims$longitude$coords$min +
      (chunk_id$longitude[[1]] * service$viewDims$longitude$chunkLen$uo
       + seq_len(service$viewDims$longitude$chunkLen$uo) - 1) *
      service$viewDims$longitude$coords$step
  )
  temp <- stars::st_set_dimensions(
    temp, "latitude",
    values = service$viewDims$latitude$coords$min +
      (chunk_id$latitude[[1]] * service$viewDims$latitude$chunkLen$uo
       + seq_len(service$viewDims$latitude$chunkLen$uo) - 1) *
      service$viewDims$latitude$coords$step
  )
  sf::st_crs(temp) <- 4326 # TODO get from meta data!
  return (temp)
}

.as_bbox <- function(x) {
  if (is.numeric(x) && is.null(names(x))) {
    names(x) <- c("xmin", "ymin", "xmax", "ymax")
  }
  x <- sf::st_bbox(x)
  if (is.na(sf::st_crs(x))) sf::st_crs(x) <- 4326
  x
}

.get_best_arco_service_type <- function(subset_request, dataset_version) {
  rlang::inform("Downloading product meta data...")
  meta <-
    cms_product_metadata(subset_request$product) |>
    dplyr::filter(startsWith(.data$id, subset_request$layer)) |>
    dplyr::filter(dplyr::row_number() == 1)
  
  variables <- lapply(meta$properties[[1]]$`cube:variables`,
                      `[[`, "standardName") |> unlist()
  if (length(subset_request$variable) == 0) variables <- names(variables) else {
    variables <- 
      names(variables)[
        names(variables) %in% subset_request$variable |
          variables %in% subset_request$variable
      ]
  }
  
  dimnames <- meta$properties[[1]]$`cube:dimensions` |>names()
  time_chunked   <- meta$assets[[1]]$timeChunked
  geo_chunked    <- meta$assets[[1]]$geoChunked
  
  indices_timec  <- .get_chunk_indices(subset_request, variables, time_chunked, dimnames)
  indices_geoc   <- .get_chunk_indices(subset_request, variables, geo_chunked, dimnames)
  count_timec    <- .get_chunk_count(indices_timec) |> unlist() |> sum()
  count_geoc     <- .get_chunk_count(indices_geoc) |> unlist() |> sum()
  if (count_timec < count_geoc) {
    result <- meta$assets[[1]]$timeChunked
    attributes(result) <- c(attributes(result), indices_timec)
  } else {
    result <- meta$assets[[1]]$geoChunked
    attributes(result) <- c(attributes(result), indices_geoc)
  }
  return (result)
}

.get_chunk_count <- function(indices) {
  lapply(indices, function(x) lapply(x$chunk_id, function(y) length(unique(y)))) |>
    lapply(dplyr::as_tibble) |>
    dplyr::bind_rows() |>
    dplyr::summarise(dplyr::across(dplyr::everything(), prod))
}

.get_chunk_indices <- function(subset_request, variables, chunk_info, dims) {
  chunk_dimlen <- 
    lapply(dims, function(y) chunk_info$viewDims[[y]]$chunkLen) |>
    dplyr::bind_rows() |>
    dplyr::mutate(dim = dims)
  .dim_range <- function(nm) {
    dat <- chunk_info$viewDims[[nm]]$coords
    dat <- dat[names(dat) %in% c("min", "max", "values")] |>
      unlist() |> unname() |> range()
  }
  dims_alt <- c(elevation = "verticalrange", time = "timerange")
  corrected_ranges <-
    lapply(structure(dims, names = dims), function(dim) {
      if (dim %in% c("longitude", "latitude")) {
        alt_dim <- c("x", "y")[match(dim, c("longitude", "latitude"))]
        req_range <- subset_request$region[paste0(alt_dim, c("min", "max"))] |> unname()
        dim_range <- .dim_range(dim)
      } else {
        dim_range <- .dim_range(dim)
        req_range <- range(subset_request[[dims_alt[[which(names(dims_alt) == dim)]] ]], na.rm = TRUE)
      }
      if (dim == "time") {
        req_range <- lubridate::as_datetime(req_range, tz = "UTC")
        dim_range <- lubridate::as_datetime(dim_range/1000, tz = "UTC")
      }
      my_range <-
        c(
          max(c(req_range[[1L]], dim_range[[1L]]), na.rm = TRUE),
          min(c(req_range[[2L]], dim_range[[2L]]), na.rm = TRUE)
        )
      dat <- chunk_info$viewDims[[dim]]$coords
      coord_values <- if(dat$type == "minMaxStep") {
        result <- seq(from = dat$min, to = dat$max, by = dat$step)
      } else if (dat$type == "explicit") {
        result <- dat$values |> unlist()
      } else {
        rlang::abort(c(x = sprintf("Dimension type '%s' not implemented", dat$type),
                       i = "Please contact developers with regex"))
      }
      if (dim == "time") {
        coord_values <- lubridate::as_datetime(coord_values/1000, tz = "UTC")
      }
      indices <- which(coord_values >= my_range[[1]] & coord_values <= my_range[[2]])
      dim_len <-
        chunk_dimlen |>
        dplyr::filter(.data$dim == .env$dim) |>
        dplyr::select(dplyr::any_of(variables)) |>
        as.list()
      
      chunk_id <- lapply(dim_len, function(dl) floor((indices - 1L)/dl))
      coord_values <- list(
        values = coord_values[indices],
        indices = indices,
        chunk_id = chunk_id
      )
      
      c(list(range = my_range), coord_values)
    })
  
  corrected_ranges
}

.get_xarray_properties <- function(service, var) {
  rlang::inform("Downloading xarray attributes...")
  zattrs <-
    ## TODO use cleaned variable name from previous step!
    paste(service$href, var, ".zattrs", sep = "/") |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)
  rlang::inform("Downloading xarray attributes...")
  
  zarray <-
    ## TODO use cleaned variable name from previous step!
    paste(service$href, var, ".zarray", sep = "/") |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)
  
  chunk_dimensions <-
    structure(
      unlist(zarray$chunks),
      names = unlist(zattrs$`_ARRAY_DIMENSIONS`)
    )
  if (zarray$order == "C") chunk_dimensions <- rev(chunk_dimensions)
  
  list(
    zarray = zarray,
    zattrs = zattrs,
    dims = chunk_dimensions
  )
}
