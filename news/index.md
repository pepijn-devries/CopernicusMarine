# Changelog

## CopernicusMarine v0.4.0.0002

- Added
  [`vignette("proxy")`](https://pepijn-devries.github.io/CopernicusMarine/articles/proxy.md)
- In order to pass CRAN checks:
  - Added safeguards to vignette
  - Improved handling of comparing floating point numbers when slicing
    stars_proxy objects.

## CopernicusMarine v0.4.0

- [`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md)
  now uses GDAL library with Zarr driver. Advantages:
  - Simpler code, easier to maintain
  - Smaller dependency footprint
- Added
  [`cms_zarr_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_zarr_proxy.md)
  and
  [`cms_native_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_native_proxy.md).
  Both can create [`stars_proxy`
  objects](https://r-spatial.github.io/stars/articles/stars2.html#stars-proxy-objects).
- Let `httr2` handle request errors, it has become a lot better at it

## CopernicusMarine v0.3.7

CRAN release: 2025-11-30

- Fix for
  [issue](https://github.com/pepijn-devries/CopernicusMarine/issues/111)
  [\#111](https://github.com/pepijn-devries/CopernicusMarine/issues/111)

## CopernicusMarine v0.3.6

CRAN release: 2025-11-11

- Updated documentation
- Small fix to pass CRAN checks

## CopernicusMarine v0.3.5

CRAN release: 2025-11-07

- Updated documentation
- Fix for
  [issue](https://github.com/pepijn-devries/CopernicusMarine/issues/100)
  [\#100](https://github.com/pepijn-devries/CopernicusMarine/issues/100)
- Fix for
  [issue](https://github.com/pepijn-devries/CopernicusMarine/issues/102)
  [\#102](https://github.com/pepijn-devries/CopernicusMarine/issues/102)

## CopernicusMarine v0.3.2

CRAN release: 2025-10-12

- Added
  [`cms_translate()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_translate.md)
- Added
  [`vignette("translate")`](https://pepijn-devries.github.io/CopernicusMarine/articles/translate.md)
- Fix in dimensioning of Zarr data

## CopernicusMarine v0.3.1

CRAN release: 2025-09-27

- Added support for sub-setting OMI, and downsampled4 assets
- Some minor fixes
- Moved dependency “blosc” to suggests as per CRAN request

## CopernicusMarine v0.3.0

CRAN release: 2025-09-11

- [`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md)
  is operational again!
- Some fixes in native download routines
- Improved test coverage

## CopernicusMarine v0.2.6

CRAN release: 2025-07-14

- Decommissioned STAC functions in order to pass pass CRAN checks.
- Implemented
  [`cms_list_native_files()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md)
  and `csm_download_native()` as alternatives to STAC.
- Updated login routine
- Improved test coverage
- Added code of conduct

## CopernicusMarine v0.2.5

CRAN release: 2025-04-05

- Fix to pass CRAN checks

## CopernicusMarine v0.2.4

CRAN release: 2024-12-22

- Added check workflow
- Added code coverage workflow
- Removed deprecated functions
- Updated documentation
- Fix in `addCmsWMTSTiles`
- Fix for change in remote API
- Fix in login function

## CopernicusMarine v0.2.3

CRAN release: 2024-01-25

- Some fixes in the subset download routine
- Additions to documentation

## CopernicusMarine v0.2.0

CRAN release: 2024-01-08

- Added functions for new services (subset, STAC and WMTS)
- Added warnings to functions interacting with deprecated Copernicus
  Marine services.
- Added login function
- Switched from `httr` to `httr2` dependency
- Switch from `magrittr`’s pipe to R’s native pipe operator

## CopernicusMarine v0.1.1

CRAN release: 2023-11-09

- Fix to pass CRAN checks

## CopernicusMarine v0.1.0

- Fix for migrated Copernicus server

## CopernicusMarine v0.0.9

CRAN release: 2023-08-21

- Updates in order to comply with latest CRAN policies
- Bug fix in log-in routine

## CopernicusMarine v0.0.6

CRAN release: 2023-01-30

- Fix in tests in order to comply with CRAN policy
- Catch and handle errors and warnings when connecting with internet
  resources and return gracefully
- Update documentation on GDAL utils dependency in WMS functions

## CopernicusMarine v0.0.3

CRAN release: 2023-01-18

- Initial implementation features data imports via:
  - MOTU service
  - File Transfer Protocol (FTP)
  - Web Map Service (WMS)
