#' Translate Python code or command line request to R list
#' 
#' `r lifecycle::badge('experimental')` Use the Copernicus Marine Service
#' website to navigate datasets
#' <https://data.marine.copernicus.eu/products>. You can specify
#' a query using the website's download form, and copy it's automation
#' download code (either command line or Python) to the system's clipboard.
#' You can then use this function to translate this code to a named list.
#' The list can be used in combination with `cms_download_subset()` to
#' download data. See `vignette("translate")` for more details.
#' @param text The query code as copied from the Copernicus Marine
#' Service website. Both Python and command line code are accepted.
#' When this argument is omitted, the function will look for a query
#' on the system clipboard.
#' @param ... Ignored
#' @returns Returns a named list with arguments for `cms_download_subset()`
#' @examples
#' python_code <-
#' "import copernicusmarine
#' 
#' copernicusmarine.subset(
#'   dataset_id=\"cmems_mod_glo_phy_anfc_0.083deg_PT1H-m\",
#'   variables=[\"uo\",\"vo\"],
#'   minimum_longitude=-2,
#'   maximum_longitude=8,
#'   minimum_latitude=52,
#'   maximum_latitude=59,
#'   start_datetime=\"2025-01-01T00:00:00\",
#'   end_datetime=\"2025-01-01T23:00:00\",
#'   minimum_depth=0.49402499198913574,
#'   maximum_depth=0.49402499198913574,
#' )"
#' 
#' cli_code <-
#' "copernicusmarine subset
#'   --dataset-id cmems_mod_glo_phy_anfc_0.083deg_PT1H-m
#'   --variable uo
#'   --variable vo
#'   --start-datetime 2025-01-01T00:00:00
#'   --end-datetime 2025-01-01T23:00:00
#'   --minimum-longitude -2
#'   --maximum-longitude 8
#'   --minimum-latitude 52
#'   --maximum-latitude 59
#'   --minimum-depth 0.49402499198913574
#'   --maximum-depth 0.49402499198913574"
#' 
#' if (interactive()) {
#'   cms_translate(python_code)
#'   cms_translate(cli_code)
#'   translated <- cms_translate(cli_code)
#'   do.call(cms_download_subset, translated)
#' }
#' @export
cms_translate <- function(text, ...) {
  if (missing(text)) {
    if (requireNamespace("clipr")) {
      text <- clipr::read_clip()
    } else {
      if (clipr::clipr_available()) {
        rlang::abort(
          c(x = "Trying to get 'text', however, system clipboard is not accessible",
            i = "Pass the Python code explicitly as 'text' argument")
        )
      } else {
        rlang::abort(
          c(x = "Trying to get 'text' from clipboard, but missing required 'clipr' package",
            i = "Install package 'clipr' and try again")
        )
      }
    }
  }
  ## collapse + strip spaces and tabs:
  text <- gsub("^[ \t]", "", paste(text, collapse = "\n"))

  ## determine if it is command line or python code:
  is_python <- (grepl("^import copernicusmarine", text))
  is_cli    <- (grepl("^copernicusmarine subset", text))
  if (!is_python && !is_cli)
    rlang::abort(c(
      x = "Code is not recognised as either 'command line' or 'Python'",
      i = "Check you 'text' argument for correctness"
    ))
  
  args <- NULL
  if (is_python) {
    arg_split  <- stringr::str_split(text, "=")
    arg_names  <- lapply(arg_split, stringr::str_replace, "(.|\n)*\n", "") |> unlist() |> trimws()
    arg_names  <- arg_names[-length(arg_names)]
    arg_values <- lapply(arg_split, stringr::str_replace, "(?<=\n)(?!.*\n).*", "") |> unlist()
    arg_values <- stringr::str_replace_all(arg_values[-1], "(],|,)\n$", "") |>
      stringr::str_replace_all("^\\[", "") |>
      stringr::str_replace_all("[ \n\t]", "") |>
      lapply(stringr::str_split, ",") |>
      lapply(\(x) {
        lapply(x, stringr::str_replace_all, "^\"|\"$", "") |> unlist()
      })
    args <- structure(arg_values, names = arg_names)
  } else if (is_cli) {
    arg_split <- stringr::str_split(text, "--")[[1]][-1] |>
      lapply(trimws) |>
      stringr::str_replace_all(" $", "") |>
      stringr::str_split(" ")
    arg_split <- do.call(rbind, arg_split) |>
      dplyr::as_tibble(.name_repair = ~c("name", "value")) |>
      dplyr::mutate(name = stringr::str_replace_all(.data$name, "-", "_")) |>
      dplyr::group_by(.data$name) |>
      dplyr::summarise(value = list(.data$value))
    args <- arg_split$value
    names(args) <- arg_split$name
  }

  args_new <- list()
  coords <- c("minimum_longitude", "minimum_latitude", "maximum_longitude", "maximum_latitude")
  tr     <- c("start_datetime", "end_datetime")
  vr     <- c("minimum_depth", "maximum_depth")
  args_new[["product"]]       <- cms_products_list2()[[args$dataset_id]]
  args_new[["layer"]]         <- args$dataset_id
  args_new[["variable"]]      <- c(args[["variables"]], args[["variable"]])
  args_new[["region"]]        <- args[coords] |> unlist() |> unname() |> as.numeric()
  args_new[["timerange"]]     <- args[tr] |> unlist() |> unname() |> as.POSIXct(tz = "UTC")
  args_new[["verticalrange"]] <- args[vr] |> unlist() |> unname() |> as.numeric()
  args_new[["verticalrange"]] <- -args_new[["verticalrange"]]
  return(args_new)
}
