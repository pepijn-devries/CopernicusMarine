#' @include init.R
NULL

`%>=%` <- function(x, y) {
  x >= (y - .Machine$double.eps^.5)
}

`%<=%` <- function(x, y) {
  x <= (y + .Machine$double.eps^.5)
}

.check_vsi <- function(vsi, href, with_blosc) {
  is_zarr <- grepl("\\.zarr$", href, ignore.case = TRUE)
  if (is_zarr && !with_blosc) {
    info <- sf::gdal_utils("mdiminfo", vsi, quiet = TRUE)
    if (length(info) > 0 && grepl("blosc", info))
      cli::cli_abort(c(
        x = "Required BLOSC decompressor not available.",
        i = "Ensure to install `sf` with blosc support.",
        i = "See {.href [`vignette(\"blosc\")`](https://pepijn-devries.github.io/CopernicusMarine/articles/blosc.html)}"
      ))
  }
  warned <- FALSE
  withCallingHandlers({
    stars::detect.driver(href)
  }, warning = function(w) {
    if (grepl("is unknown", conditionMessage(w))) {
      warned <<- TRUE
      invokeRestart("muffleWarning")
    }
  })
  if (warned) cli::cli_abort(c(
    x = "No driver found for requested raster",
    i = "Please {.href [submit a bug report](https://github.com/pepijn-devries/CopernicusMarine/issues)} with reproducible example"
  ))
}

.simplify <- function(data) {
  empty_row <- data.frame(a = NA)[,-1]
  result <-
    data |>
    lapply(tibble::enframe) |>
    lapply(
      tidyr::pivot_wider,
      names_from  = "name",
      values_from = "value") |>
    lapply(function(x) {
      if (nrow(x) == 0) {
        empty_row
      } else {
        x
      }
    }) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        function (x) {
          if (all(lengths(x) == 1) && all(unlist(lapply(x, lengths)) == 1))
              unlist(x) else x
        }
      )
    )
}

## Some requests result in a 403 status response, which trigger a warning.
## Most likely this is the GDAL library trying to get directory listing
## where the server does not allow it. These warnings are harmless and
## do not affect the outcome. I will therefore muffle these warnings to
## not confuse/bother the end-user.
## Maybe this will be fixed in later GDAL releases.
.muffle_403 <- function(expr) {
  withCallingHandlers({
    expr
  }, warning = function(w) {
    if (grepl(": 403", conditionMessage(w)))
      invokeRestart("muffleWarning")
  })
}

.uri_to_vsi <- function(href, progress, add_zarr = TRUE, streaming = TRUE) {
  s3_root <- stringr::str_extract(href, "(?<=//)[^/]+")
  check <-
    Sys.setenv(AWS_S3_ENDPOINT     = s3_root) &&
    Sys.setenv(AWS_NO_SIGN_REQUEST = "YES") &&
    Sys.setenv(AWS_VIRTUAL_HOSTING = "FALSE")
  
  if (check) {
    vsi <- href |>
      stringr::str_replace("^https?://[^/]+/([^/]+)/(.*)$",
                           sprintf("/vsis3%s/\\1/\\2",
                                   ifelse(streaming, "_streaming", "")))
  } else {
    if (progress)
      cli::cli_progress_message("Failed to set GDAL S3 config, trying alternative")
    vsi <- paste0("/vsicurl/", href)
  }
  result <- if (!add_zarr) vsi else sprintf("ZARR::\"%s\"", vsi)
  .check_vsi(result, href, has_blosc)
  result
}

.get_stars_proxy <- function(vsi, variable) {
  if (length(variable) == 0) {
    mdiminfo <- 
      jsonlite::fromJSON(sf::gdal_utils("mdiminfo", source = vsi, quiet = TRUE))
    variable <- mdiminfo$arrays |> names()
    variable <-
      variable[!variable %in% c("depth", "elevation", "time",
                                "longitude", "latitude")]
  }
  mdim_proxy <- .muffle_403({
    stars::read_mdim(
      vsi,
      proxy = TRUE,
      variable = variable
    )
  })
}