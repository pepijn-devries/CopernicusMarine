# Contact Copernicus Marine login page

**\[stable\]** Contact Copernicus Marine login page and check if login
is successful.

## Usage

``` r
cms_login(username = cms_get_username(), password = cms_get_password())
```

## Arguments

- username:

  Your Copernicus marine user name. Can be provided with
  [`cms_get_username()`](https://pepijn-devries.github.io/CopernicusMarine/reference/account.md)
  (default), or as argument here.

- password:

  Your Copernicus marine password. Can be provided as
  [`cms_get_password()`](https://pepijn-devries.github.io/CopernicusMarine/reference/account.md)
  (default), or as argument here.

## Value

Returns a named `list` with your account details if successful, returns
`NULL` otherwise.

## Details

This function will return your account details if successful.

## Author

Pepijn de Vries

## Examples

``` r
if (interactive()) {
  cms_login()
}
```
