# Get information about Copernicus Marine clients

**\[stable\]** This function retrieves the client information from the
Copernicus Marine Service. Among others, it lists where to find the
catalogues required by this package

## Usage

``` r
cms_get_client_info(...)
```

## Arguments

- ...:

  Ignored

## Value

In case of success it returns a named `list` with information about the
available Copernicus Marine clients.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_get_client_info()
}
```
