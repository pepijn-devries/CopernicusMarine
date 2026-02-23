## There is no explicit way to test if the user has BLOSC support.
## It's assumed that the user has BLOSC support when the stars
## package is able to write a raster file with BLOSC compression.
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
    if (sf::sf_extSoftVersion()["GDAL"] < "3.11") {
      paste(
        "Your GDAL version is <3.11 and may not support all CopernicusMarine features,",
        "see `vigette(\"blosc\")` for more info and how to fix", sep = "\n"
      )
    }
  })
}