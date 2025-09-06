#' Subset and download a specific marine product from Copernicus
#'
#' `r lifecycle::badge('experimental')` Subset and download a specific marine product
#' from Copernicus.
#'
#' @include cms_login.r
#' @inheritParams cms_login
#' @param destination `r lifecycle::badge("deprecated")` This argument is deprecated.
#' Data is no longer written to a file but loaded as a [stars::st_as_stars()] object
#' into memory.
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
#' @param overwrite `r lifecycle::badge("deprecated")` This argument is deprecated.
#' Data is no longer written to a file but loaded as a [stars::st_as_stars()] object
#' into memory.
#' @param progress A logical value. When `TRUE` (default) progress is reported to the console.
#' Otherwise, this function will silently proceed.
#' @param crop On the server, the data is organised in chunks. The subset
#' will download chunks that overlap with the specified ranges, but often
#' covers a larger area. When `crop = TRUE` (default), the data will be cropped
#' to the specified `region`. If set to `FALSE` all downloaded data will be returned.
#' @param ... Ignored (reserved for future features).
#' @returns Returns a [stars::st_as_stars()] object.
#' @rdname cms_download_subset
#' @name cms_download_subset
#' @examples
#' if (interactive()) {
#'   destination <- tempfile("copernicus", fileext = ".nc")
#'
#'   mydata <- cms_download_subset(
#'     destination   = destination,
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'     variable      = c("uo", "vo"),
#'     region        = c(-1, 50, 10, 55),
#'     timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
#'     verticalrange = c(0, -2)
#'   )
#'
#'   my_data
#'   plot(mydata["vo"])
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
    progress = TRUE,
    crop = TRUE,
    ...) {
  
  subset_request <- list(
    product       = product,
    layer         = layer,
    variable      = variable,
    region        = if (missing(region)) NULL else region,
    timerange     = if (missing(timerange)) NULL else timerange,
    verticalrange = if (missing(verticalrange)) NULL else verticalrange
  )
  service               <- .get_best_arco_service_type(subset_request, "", progress)
  current_refsys        <- .get_refsys(attributes(service)$dim_properties)
  subset_request$region <- .as_bbox(subset_request$region, current_refsys)
  variable              <- service$viewVariables |> names()
  dims                  <- names(attributes(service)$dims)

  ## access_token is currently not used.
  if (!is.null(username) && !is.null(password) &&
      !is.na(username) && !is.na(password) && username != "" && password != "")
    access_token <- .get_access_token(username, password)

  if (progress) rlang::inform("Downloading zarr meta information")
  serv_props <- .get_service_properties(service, variable)

  if (progress) rlang::inform("Downloading chunks")
  
  result <- .download_chunks(dims, service, variable, progress)
  
  if (progress) {
    rlang::inform("") # Empty line to replace progress bar, not very nice I know
    rlang::inform("Decompressing data")
  }
  
  if (any(serv_props$zarr_format != 2))
    stop("Sorry at the moment only zarr format verions 2 is implemented")
  
  result <- .decompress_data(result, serv_props)
  
  if (progress) rlang::inform("Formatting data")
  
  result <- .process_data(result, dims, variable, service, crop, current_refsys)

  if (progress) rlang::inform("Done")
  return (result)
}

.process_data <- function(data, dims, variable, service, crop, current_refsys) {

  chunk_dim <- lapply(dims, \(dm) dplyr::as_tibble(service$viewDims[[dm]]$chunkLen)) |>
    dplyr::bind_rows()
  
  xy <- .get_xy_axes(attr(service, "dim_properties"))
  dms <- dims
  if (service$id == "timeChunked") {
    dim_order = match(dms, c("time", xy[[1]], xy[[2]], "elevation"))
  } else if (service$id == "geoChunked") {
    dim_order = match(dms, c(xy[[1]], xy[[2]], "elevation", "time"))
  } else if (service$id == "static") {
    dim_order = match(dms, c(xy[[1]], xy[[2]], "elevation"))
  } else {
    stop("Unknown service id")
  }
  result <- NULL ## avoid global bindings note in CRAN checks
  
  data <-
    data |>
    dplyr::group_by(.data$var) |>
    dplyr::mutate(
      chunk_data = {
        lapply(seq_along(dplyr::cur_group_rows()), \(i, v, idxs, dat, dmn) {
          result <- dat[[i]]
          idx <- idxs[i,]
          chunk_dim[is.na(chunk_dim)] <- 1L
          result <-
            array(result, dim = structure(chunk_dim[[v]][dim_order],
                                          names = dmn[dim_order])) |>
            stars::st_as_stars() |>
            stars::st_set_dimensions(result, xy = xy)
          ## Set dimensions of stars object properly
          result <-
            purrr::reduce(
              dmn, \(y, z) {
                .set_subset_dim(y, idx[[z]], z, v, service)
              },
              .init = result
            )
          
          names(result) <- v
          
          sf::st_crs(result) <- current_refsys
          result
          
        },
        v    = .data$var[[1]],
        idxs = dplyr::pick(dplyr::any_of(dms)),
        dat  = .data$chunk_data,
        dmn  = dms)
      }
    )
  remaining_dims <- dims
  
  data <-
    purrr::reduce(dims, \(x, y) tidyr::unnest(x, dplyr::any_of(y)), .init = data)
  
  for (dm in rev(dims)) {
    remaining_dims <- setdiff(remaining_dims, dm)
    data <- 
      data |>
      dplyr::group_by(dplyr::pick(dplyr::any_of(c("var", remaining_dims)))) |>
      dplyr::summarise(
        chunk_data = {
          if (dplyr::n() == 1) .data$chunk_data else
            list(do.call(c, c(.data$chunk_data, along = dm)))
        }
      ) |>
      dplyr::ungroup()
  }
  
  data <- do.call(c, c(data$chunk_data, list(try_hard = TRUE)))

  for (dm in dims) {
    if (crop) {
      chunk_offset <- stats::na.omit(unlist(attr(service, "dims")[[dm]]$chunk_offset))[[1]]
      selection <- attr(service, "dims")[[dm]]$indices - chunk_offset
      is.na(stars::st_get_dimension_values(data, dm))
      data <-
        dplyr::slice(data, !!dm, selection)
    } else {
      data <-
        dplyr::slice(data, !!dm,
                     which(!is.na(stars::st_get_dimension_values(data, dm))))
    }
  }
  
  data <- sf::st_normalize(data)
  
  for (dm in dims) {
    fr <- stars::st_dimensions(data)[[dm]]$from
    if (fr != 1L &&
        is.na(stars::st_dimensions(data)[[dm]]$offset)) {
      stars::st_dimensions(data)[[dm]]$to   <-
        stars::st_dimensions(data)[[dm]]$to - fr + 1L
      stars::st_dimensions(data)[[dm]]$from <- 1L
    }
  }

  ## Add unit to variable if possible
  var_prop <- attributes(service)$var_properties
  
  for (v in variable) {
    data[[v]] <- tryCatch({
      units::as_units(data[[v]], var_prop[[v]]$unit)
    }, error = function(e) result[[v]])
  }
  data
}

.get_xy_axes <- function(dim_props) {
  xy <- lapply(dim_props, \(x) {
    c("x", "y")[match(x$axis, c("x", "y"))]
  }) |>
    unlist()
  lapply(c("x", "y"), \(z) names(xy)[!is.na(xy) & xy == z]) |>
    unlist()
}

.decompress_data <- function(data, service_properties) {
  data |>
    dplyr::left_join(
      service_properties,
      by = "var"
    ) |>
    dplyr::mutate(
      chunk_data = lapply(seq_along(.data$chunk_data), \(i) {
        if (.data$compressor[[i]]$id != "blosc") rlang::abort("Unkown compressor '%s'",
                                                              .data$compressor[[i]]$id)
        ## If zarr version 3 is used, translate data type
        ## and endianness to dtype code
        blosc::blosc_decompress(x        = .data$chunk_data[[i]],
                                dtype    = .data$dtype[[i]],
                                na_value = .data$fill_value[[i]])
      })
    )
}

.get_service_properties <- function(service, variable) {
  dplyr::tibble(
    var = variable,
    serv_props = lapply(variable, \(x) .get_xarray_properties(service, x))
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
}

.download_chunks <- function(dims, service, variable, progress) {
  dims_out_of_range <- lengths(lapply(attributes(service)$dims, `[[`, "chunk_id") |>
                                 lapply(`[[`, 1))
  dims_out_of_range <- names(dims_out_of_range)[dims_out_of_range == 0]
  if (length(dims_out_of_range) > 0) {
    rlang::abort(
      c(x = sprintf("No data within selected range (for these dimensions: %s)",
                    paste(sprintf("'%s'", dims_out_of_range), collapse = ", ")),
        i = "Check data extent with `cms_product_metadata()`")
    )
  }
  result <-
    lapply(dims, function(dm) attributes(service)$dims[[dm]]$chunk_id) |>
    lapply(dplyr::as_tibble) |>
    lapply(\(x) {
      dplyr::mutate(
        x,
        .generic = purrr::pmap(dplyr::pick(dplyr::everything()), \(...) {
          unique(stats::na.omit(c(...)))
        }) |> unlist(),
        dplyr::across(dplyr::everything(), ~ {
          ifelse(is.na(.), -.data$.generic - 1L, .)
        })
      ) |>
        dplyr::select(-".generic")
    })
  result <- dplyr::tibble(result = result, dim = dims) |>
    tidyr::unnest("result") |>
    dplyr::distinct() |>
    tidyr::pivot_longer(dplyr::all_of(variable), names_to = "var", values_to = "id") |>
    tidyr::pivot_wider(id_cols = "var", names_from = "dim", values_from = "id",
                       values_fn = list) |>
    tidyr::expand_grid() |>
    dplyr::group_by(.data$var) |>
    dplyr::group_modify(~{
      do.call(tidyr::expand_grid, lapply(., `[[`, 1)) |>
        dplyr::as_tibble()
    }) |>
    dplyr::ungroup() |>
    dplyr::distinct() |>
    dplyr::mutate(
      combi_id = purrr::pmap(
        dplyr::pick(dplyr::any_of(c("time", "elevation", "latitude", "longitude"))),
        \(...) {
          result <- c(...)
          result[result >= 0] |>
            paste(collapse = ".")
        }) |> unlist()
    ) |>
    dplyr::mutate(
      chunk_url = {
        mapply(sprintf, fmt = "%s/%s/%s", service$href, .data$var, .data$combi_id,
               SIMPLIFY = FALSE) |>
          lapply(httr2::request)
      },
      ## Currently uses default max number of requests of 10
      chunk_data = httr2::req_perform_parallel(.data$chunk_url, progress = progress),
      chunk_data = lapply(.data$chunk_data, httr2::resp_body_raw)
    )
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
  if (length(ref_sys) != 1) stop("Axes use mix of reference systems or is missing")
  ref_sys
}

## function args: stars, index, dimension, variable, service-info
.set_subset_dim <- function(x, i, d, v, service) {
  if (i < 0) i <- abs(i + 1)
  vals <- attr(service, "dims")[[d]]$values
  dim_prop <- attributes(service)$dim_properties[[d]]
  
  tp <- service$viewDims[[d]]$coords$type
  if (tp == "explicit") {
    cl <- service$viewDims[[d]]$chunkLen[[1]]
    vals <- vals[i*cl + seq_len(cl)]
    if (!is.null(dim_prop$unit)) {
      vals <- tryCatch({
        units::as_units(vals, dim_prop$unit)
      }, error = function(e) vals)
    }
  } else if (tp == "minMaxStep") {
    vals <-
      vals[
        i * service$viewDims[[d]]$chunkLen[[v]] +
          seq_len(service$viewDims[[d]]$chunkLen[[v]])
      ]
  } else {
    stop("Unknown dimension type '%s'", tp)
  }
  
  stars::st_dimensions(x)[[d]]$point <- NA_real_
  if (dim_prop$type == "temporal") {
    if (is.null(dim_prop$step)) {
      stars::st_dimensions(x)[[d]]$delta  <- NA_real_
      stars::st_dimensions(x)[[d]]$offset <- NA_real_
      stars::st_dimensions(x)[[d]]$values <- vals
    } else {
      stars::st_dimensions(x)[[d]]$values <- NULL
      stars::st_dimensions(x)[[d]]$offset <- min(vals)
      stars::st_dimensions(x)[[d]]$delta <- .code_to_period(dim_prop$step)
    }
    stars::st_dimensions(x)[[d]]$refsys <- class(vals)[[1]]
  } else {
    stars::st_dimensions(x)[[d]]$delta  <- NA_real_
    stars::st_dimensions(x)[[d]]$offset <- NA_real_
    stars::st_dimensions(x)[[d]]$values <- vals
    if (inherits(vals, "units"))
      stars::st_dimensions(x)[[d]]$refsys <- "udunits"
  }
  x

}

.as_bbox <- function(x, crs_arg) {
  if (is.numeric(x) && is.null(names(x))) {
    names(x) <- c("xmin", "ymin", "xmax", "ymax")
  }
  x <- sf::st_bbox(x)
  if (is.na(sf::st_crs(x))) sf::st_crs(x) <- crs_arg
  x
}

.get_best_arco_service_type <- function(subset_request, dataset_version, progress) {
  if (progress) rlang::inform("Downloading product meta data")
  meta <-
    cms_product_metadata(subset_request$product) |>
    dplyr::filter(startsWith(.data$id, subset_request$layer)) |>
    dplyr::filter(dplyr::row_number() == 1)
  
  var_properties <- meta$properties[[1]]$`cube:variables`
  dim_properties <- meta$properties[[1]]$`cube:dimensions`
  
  subset_request$region <- .as_bbox(subset_request$region, .get_refsys(dim_properties))

  variables <- lapply(meta$properties[[1]]$`cube:variables`,
                      `[[`, "standardName") |> unlist()
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
  
  if (is.null(static)) { ## Time or geo-chunked
    
    indices_timec  <- .get_chunk_indices(subset_request, variables,
                                         time_chunked, dimnames, dim_properties)
    indices_geoc   <- .get_chunk_indices(subset_request, variables,
                                         geo_chunked, dimnames, dim_properties)
    
    count_timec    <- .get_chunk_count(indices_timec) |> unlist() |> sum()
    count_geoc     <- .get_chunk_count(indices_geoc) |> unlist() |> sum()
    
    if (count_timec < count_geoc) {
      result <- time_chunked
      attributes(result) <- c(attributes(result), list(dims = indices_timec))
    } else {
      result <- geo_chunked
      attributes(result) <- c(attributes(result), list(dims = indices_geoc))
    }
  } else { ## static
    
    result <- static
    indices_static <- .get_chunk_indices(subset_request, variables,
                                         static, dimnames, dim_properties)
    attributes(result) <- c(attributes(result), list(dims = indices_static))
    
  }
  result$viewVariables <- result$viewVariables[variables]
  attributes(result) <- c(attributes(result),
                          list(dim_properties = dim_properties),
                          list(var_properties = var_properties))
  
  return (result)
}

.get_chunk_count <- function(indices) {
  lapply(indices, function(x) lapply(x$chunk_id, function(y) length(unique(y)))) |>
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
  corrected_ranges <-
    lapply(structure(dims, names = dims), function(dim) {
      dim_range <- unlist(dim_props[[dim]]$extent)
      
      alt_dim <- dim_props[[dim]]$axis
      if (!is.null(alt_dim) && alt_dim %in% c("x", "y")) {
        req_range <- subset_request$region[paste0(alt_dim, c("min", "max"))] |> unname()
      } else {
        req_range <- range(subset_request[[
          dims_alt[[which(names(dims_alt) == dim)]]
        ]], na.rm = TRUE)
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

      flex <- (coord_values |> diff() |> min())/10
      indices <- which(coord_values >= (my_range[[1]] - flex) &
                         coord_values <= (my_range[[2]] + flex))
      dim_len <-
        chunk_dimlen |>
        dplyr::filter(.data$dim == .env$dim) |>
        dplyr::select(dplyr::any_of(variables)) |>
        as.list()

      chunk_id <- lapply(dim_len, function(dl) floor((indices - 1L)/dl))

      if (any(lengths(chunk_id) == 0)) chunk_offset <- numeric() else
        chunk_offset <- mapply(\(x, y) y*min(x), x = chunk_id, y = dim_len)
      coord_values <- list(
        values = coord_values,
        indices = indices,
        chunk_id = chunk_id,
        chunk_offset = chunk_offset
      )
      
      c(list(range = my_range), coord_values)
    })
  
  corrected_ranges
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

.get_xarray_properties <- function(service, var) {

  zattrs <-
    paste(service$href, var, ".zattrs", sep = "/") |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)

  zarray <-
    paste(service$href, var, ".zarray", sep = "/") |>
    httr2::request() |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type = FALSE)
  if (is.null(zarray$fill_value)) zarray$fill_value <- NA_real_
  
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
