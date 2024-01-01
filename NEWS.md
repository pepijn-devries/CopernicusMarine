CopernicusMarine v0.2.0 (Release date: 2024-01-01)
-------------

 * Added functions for new services (subset, STAC and WMTS)
 * Added warnings to functions interacting with
   deprecated Copernicus Marine services.
 * Added login function
 * Switched from `httr` to `httr2` dependency
 * Switch from `magrittr`'s pipe to R's native pipe operator

CopernicusMarine v0.1.1 (Release date: 2023-11-09)
-------------

 * Fix to pass CRAN checks

CopernicusMarine v0.1.0 (Release date: 2023-11-08)
-------------

 * Fix for migrated Copernicus server

CopernicusMarine v0.0.9 (Release date: 2023-08-21)
-------------

  * Updates in order to comply with latest CRAN
    policies
  * Bug fix in log-in routine

CopernicusMarine v0.0.6 (Release date: 2023-01-23)
-------------

  * Fix in tests in order to comply with CRAN
    policy
  * Catch and handle errors and warnings when connecting
    with internet resources and return gracefully
  * Update documentation on GDAL utils dependency
    in WMS functions

CopernicusMarine v0.0.3 (Release date: 2023-01-16)
-------------

  * Initial implementation features data imports via:
    - MOTU service
    - File Transfer Protocol (FTP)
    - Web Map Service (WMS)
