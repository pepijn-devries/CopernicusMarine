has_blosc <-
  tryCatch({
    m <- stars::st_as_stars(matrix(1:100, 10, 10))
    fn <- tempfile("blosc", fileext = ".zarr")
    on.exit({
      unlink(fn, TRUE)
    })
    stars::write_stars(m, fn, driver = "Zarr",
                       options = c("COMPRESS=BLOSC", "BLOSC_CNAME=zstd"))
    TRUE
  }, error = function(e) FALSE)

.onAttach <- function(libname, pkgname) {
  packageStartupMessage({
    if (!has_blosc) {
      cli::cli_inform(
        paste(
          c("Your installation of `sf` does not support BLOSC compression.",
            "Please install a version of {.href [`sf` with BLOSC support](https://pepijn-devries.github.io/CopernicusMarine/articles/blosc.html)}"), sep = "\n")
      )
    } else {
            cli::cli_inform("Your installation supports BLOSC. You are good to go!")
          }
  })
}
