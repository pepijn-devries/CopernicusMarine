CopernicusMarine v0.2.5
-------------

 * Fix to pass CRAN checks

CopernicusMarine v0.2.4
-------------

 * Added check workflow
 * Added code coverage workflow
 * Removed deprecated functions
 * Updated documentation
 * Fix in `addCmsWMTSTiles`
 * Fix for change in remote API
 * Fix in login function

CopernicusMarine v0.2.3
-------------

 * Some fixes in the subset download routine
 * Additions to documentation

CopernicusMarine v0.2.0
-------------

 * Added functions for new services (subset, STAC and WMTS)
 * Added warnings to functions interacting with
   deprecated Copernicus Marine services.
 * Added login function
 * Switched from `httr` to `httr2` dependency
 * Switch from `magrittr`'s pipe to R's native pipe operator

CopernicusMarine v0.1.1
-------------

 * Fix to pass CRAN checks

CopernicusMarine v0.1.0
-------------

 * Fix for migrated Copernicus server

CopernicusMarine v0.0.9
-------------

  * Updates in order to comply with latest CRAN
    policies
  * Bug fix in log-in routine

CopernicusMarine v0.0.6
-------------

  * Fix in tests in order to comply with CRAN
    policy
  * Catch and handle errors and warnings when connecting
    with internet resources and return gracefully
  * Update documentation on GDAL utils dependency
    in WMS functions

CopernicusMarine v0.0.3
-------------

  * Initial implementation features data imports via:
    - MOTU service
    - File Transfer Protocol (FTP)
    - Web Map Service (WMS)
