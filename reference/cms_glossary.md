# Get Copernicus Marine Terminology Glossary

Function that returns a `data.frame` with a glossary of terminology used
by the Copernicus Marine Data Service. It is the same `data.frame` that
is used to render
[`vignette("glossary")`](https://pepijn-devries.github.io/CopernicusMarine/articles/glossary.md).

## Usage

``` r
cms_glossary(search, match_fun = agrep, ...)
```

## Arguments

- search:

  Search terms to look for in the glossary `data.frame`. Only rows that
  match these terms are returned. If missing, the entire `data.frame` is
  returned.

- match_fun:

  Function used to filter the `data.frame`. It needs to be a function
  that uses a `pattern` argument to match the text in the `data.frame`
  against. It should return a vector of `logical` values or a vector of
  `integer` row index values. By default it uses
  [`agrepl()`](https://rdrr.io/r/base/agrep.html), for a fuzzy match.

- ...:

  Arguments passed to `match_fun`.

## Value

Returns a `data.frame` with glossary info.

## Examples

``` r
cms_glossary("variable", ignore.case = TRUE)
#> # A tibble: 1 × 4
#>   Term      Meaning                                 Details `Example/Reference`
#>   <chr>     <chr>                                   <chr>   <chr>              
#> 1 Variables Physical quantities stored in the array NA      bottomT, thetao    
```
