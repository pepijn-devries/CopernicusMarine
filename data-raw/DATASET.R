## Use Python package copernicusmarine to download
## a dataset for comparison
library(reticulate)
if (!"py_env" %in% list.dirs(Sys.getenv("RETICULATE_VIRTUALENV_ROOT"),
                             full.names = FALSE, recursive = FALSE)) {
  ## install Python (could be skipped if Python is already installed):
  install_python()
  ## Set up virtual environment with Python:
  virtualenv_create(envname = "py_env")
  ## Install the required Python package:
  virtualenv_install("py_env", packages = c("copernicusmarine"))
}

use_virtualenv("py_env")
cms <- import("copernicusmarine")
success     <- tryCatch({
  cms$subset(
    username          = getOption("CopernicusMarine_uid", ""),
    password          = getOption("CopernicusMarine_pwd", ""),
    dataset_id        = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
    variables         = as.list(c("uo", "vo")),
    output_filename   = "test_data_python.nc",
    output_directory  = normalizePath("data-raw"),
    start_datetime    = "2025-01-01",
    end_datetime      = "2025-01-02",
    minimum_depth     = 0,
    maximum_depth     = 8,
    minimum_longitude = -1,
    maximum_longitude = 10,
    minimum_latitude  = 50,
    maximum_latitude  = 55,
    overwrite         = TRUE
  )
  TRUE
}, error = function(e) FALSE)
