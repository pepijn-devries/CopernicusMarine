# Navigate through CopernicusMarine native file via S3

**\[experimental\]** Native files (i.e. files as provided by suppliers)
are hosted with the [Amazon Simple Storage Service
(s3)](https://aws.amazon.com/s3/). This function generates a
[`paws::s3()`](https://paws-r.r-universe.dev/paws/reference/s3.html)
object, that can be used to navigate and download these files.

## Usage

``` r
cms_native_s3(
  config = list(),
  credentials = list(anonymous = TRUE),
  endpoint = "https://s3.waw3-1.cloudferro.com",
  region = "us-east-1",
  ...
)
```

## Arguments

- config:

  Optional configuration of credentials, endpoint, and/or region.

  - **credentials**:

    - **creds**:

      - **access_key_id**: AWS access key ID

      - **secret_access_key**: AWS secret access key

      - **session_token**: AWS temporary session token

    - **profile**: The name of a profile to use. If not given, then the
      default profile is used.

    - **anonymous**: Set anonymous credentials.

  - **endpoint**: The complete URL to use for the constructed client.

  - **region**: The AWS Region used in instantiating the client.

  - **close_connection**: Immediately close all HTTP connections.

  - **timeout**: The time in seconds till a timeout exception is thrown
    when attempting to make a connection. The default is 60 seconds.

  - **s3_force_path_style**: Set this to `true` to force the request to
    use path-style addressing, i.e.
    `http://s3.amazonaws.com/BUCKET/KEY`.

  - **sts_regional_endpoint**: Set sts regional endpoint resolver to
    regional or legacy
    <https://docs.aws.amazon.com/sdkref/latest/guide/feature-sts-regionalized-endpoints.html>

- credentials:

  Optional credentials shorthand for the config parameter

  - **creds**:

    - **access_key_id**: AWS access key ID

    - **secret_access_key**: AWS secret access key

    - **session_token**: AWS temporary session token

  - **profile**: The name of a profile to use. If not given, then the
    default profile is used.

  - **anonymous**: Set anonymous credentials.

- endpoint:

  Optional shorthand for complete URL to use for the constructed client.

- region:

  Optional shorthand for AWS Region used in instantiating the client.

- ...:

  Ignored

## Value

Returns a
[`paws::s3()`](https://paws-r.r-universe.dev/paws/reference/s3.html)
object, specifically representing the service that hosts Copernicus
Marine native data.

## Details

Note that alternative functions in this package provide more convenient
routes:

- [`cms_list_native_files()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md)

- [`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md)

- [`cms_native_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_native_proxy.md)

## See also

Other download:
[`cms_download_native()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_native.md),
[`cms_download_subset()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_download_subset.md),
[`cms_native_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_native_proxy.md),
[`cms_zarr_proxy()`](https://pepijn-devries.github.io/CopernicusMarine/reference/cms_zarr_proxy.md)

## Examples

``` r
if (interactive() && requireNamespace("paws")) {
  my_s3 <- cms_native_s3()
  my_s3$list_objects_v2("mdl-native-14", MaxKeys = 5)
}
```
