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
