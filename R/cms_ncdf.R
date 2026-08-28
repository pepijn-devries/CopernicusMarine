#' Store Typical Copernicus Marine Rasters Objects as NCDF
#' 
#' `r lifecycle::badge('experimental')` The [cms_download_subset()] returns a `stars` class object.
#' This is fine if you want to use it directly in R. But if
#' you want to open it in external software, you need a more
#' acceptable exchange format. You can use this function to
#' store the `stars` object as a [NetCDF](https://en.wikipedia.org/wiki/NetCDF)
#' file.
#' 
#' Note that dimensions returned by [cms_download_subset()]
#' have interval values, describing between what range the
#' raster cell lies. When reading a file stored with
#' `cms_write_ncdf()`, you must specify where from the file
#' the bounds of the dimension should be read. Otherwise
#' the GDAL driver will (often incorrectly) deduce dimension
#' values. The example shows how to read the written file
#' using [stars::read_mdim()].
#' 
#' The `cms_write_ncdf()` function is tailored to `stars`
#' objects returned by `cms_download_subset()`. It might
#' work on other `stars` objects, but it is not guaranteed.
#' 
#' Writing multidimensional data to a standardised format is the
#' source of many headaches. The current implementation is not ideal,
#' which is why it is currently experimental. Perhaps future GDAL
#' release will have better support for writing higher dimension
#' raster data. To be safe, you can also save your data as `.rdata`,
#' or reduce the dimensions by storing specific slices.
#' @param x A `stars` class object created with [cms_download_subset()].
#' Note that this is not a highly generic NetCDF writer, so it
#' makes certain assumptions about the `stars` object, that
#' may not be true for all.
#' @param file File path where to store the object.
#' @param missval Value used to represent missing data (`NA`)
#' in your object.
#' @param prec Precision used for storing the data (`"double"`
#' by default).
#' @param ... Ignored.
#' @return Returns `NULL` invisibly.
#' @family supporting
#' @examples
#' if (interactive()) {
#'   ## Download some data to store
#'   mydata <- cms_download_subset(
#'     product       = "GLOBAL_ANALYSISFORECAST_PHY_001_024",
#'     layer         = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
#'     variable      = c("uo", "vo"),
#'     region        = c(-1, 50, 10, 55),
#'     timerange     = c("2025-01-01 UTC", "2025-01-02 UTC"),
#'     verticalrange = c(0, -2)
#'   )
#'   fn <- tempfile(fileext = ".nc")
#'   cms_write_ncdf(mydata, fn)
#'   mydata2 <- stars::read_mdim(
#'     fn,
#'     ## You explicitly need to specify dimension bounds when reading back the data
#'     bounds = c(
#'       longitude = "longitude_bnds",
#'       latitude  = "latitude_bnds",
#'       elevation = "elevation_bnds"))
#'
#'   ## clean up after our selves
#'   unlink(fn, TRUE, TRUE)
#' }
#' @export
cms_write_ncdf <- function(x, file, missval = -999, prec = "double", ...) {
  if (!inherits(x, "stars"))
    stop("Expect `stars` but got", class(x))
  
  if (requireNamespace("ncdf4") && requireNamespace("units")) {
    dms <-
      stars::st_dimensions(x)
    ## Dimension holding bounds
    dim_nv <- ncdf4::ncdim_def(
      name = "nv", units = "", vals = 1:2,
      create_dimvar = FALSE)
    
    nc_dims <- list()
    nc_vars <- list()
    dim_vals <- list()
    for (dm in dimnames(x)) {
      dim_vals[[dm]] <-
        lapply(c("center", "start", "end"),
               \(w) stars::st_get_dimension_values(x, dm, where = w)) |>
        dplyr::bind_cols() |>
        suppressMessages() |>
        as.matrix() |>
        unname()
      unit <- dms[[dm]]$refsys
      unit <- ifelse(is.character(unit), unit, NA_character_)
      if (dm == "elevation") unit <- "m"
      if (dm == "longitude") unit <- "degrees_east"
      if (dm == "latitude") unit <- "degrees_north"
      if (dm == "time") {
        dim_vals[[dm]] <- matrix(
          lubridate::as_datetime(dim_vals[[dm]]) |>
            lubridate::seconds() |> as.numeric(),
          nrow = nrow(dim_vals[[dm]]))
        unit <- "seconds since 1970-01-01 00:00:00 UTC"
      }
      nc_dims[[dm]] <-
        ncdf4::ncdim_def(
          name = dm, units = unit, vals = dim_vals[[dm]][,1]
        )
      nc_vars[[sprintf("var_%s_bnds", dm)]] <-
        ncdf4::ncvar_def(
          paste(dm, "bnds", sep = "_"),
          units = unit,
          dim = list(dim_nv, nc_dims[[dm]]),
          prec = prec
        )
    }
    ## Use explicit order for writing dimensions to nc
    target_dims <- c("longitude", "latitude", "elevation", "time")
    matched_dims <- target_dims[target_dims %in% dimnames(x)]
    for (v_nm in names(x)) {
      nc_vars[[v_nm]] <- ncdf4::ncvar_def(
        name    = v_nm,
        units   = units::deparse_unit(x[[v_nm]]),
        dim     = nc_dims[matched_dims],
        missval = missval,
        prec    = prec)
      
    }
    nc_vars[["crs_var"]] <- ncdf4::ncvar_def(
      name = "crs", 
      units = "", 
      dim = list(),
      prec = "char"
    )
    
    nc_file <- ncdf4::nc_create(file, nc_vars)
    for (dm in dimnames(x)) {
      ncdf4::ncatt_put(
        nc_file,
        varid = dm,
        attname = "bounds",
        attval = sprintf("var_%s_bnds", dm))
      ncdf4::ncvar_put(
        nc_file,
        varid = nc_vars[[sprintf("var_%s_bnds", dm)]],
        vals = t(dim_vals[[dm]][,-1]))
    }
    ncdf4::ncatt_put(nc_file, "crs", "grid_mapping_name", "latitude_longitude")
    ncdf4::ncatt_put(nc_file, "crs", "crs_wkt", sf::st_crs(x)$wkt)
    for (v_nm in names(x)) {
      ncdf4::ncvar_put(
        nc_file,
        varid = nc_vars[[v_nm]],
        vals = as.array(aperm(x[v_nm], matched_dims)[[v_nm]]))
      ncdf4::ncatt_put(nc_file, v_nm, "grid_mapping", "crs")
    }
    ncdf4::nc_close(nc_file)

  }
}