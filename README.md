# [<img src="https://s3.internetdata.io/internetdata-public/brand/mark.svg" alt="InternetData" height="28"/>](https://internetdata.io/) InternetData R Client Library

[![CRAN](https://www.r-pkg.org/badges/version/internetdata)](https://cran.r-project.org/package=internetdata)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

The official R client library for the [InternetData](https://internetdata.io) API.

## Getting Started

```r
install.packages("internetdata")
```

Requires R 4.1 or newer. [curl](https://cran.r-project.org/package=curl) and [jsonlite](https://cran.r-project.org/package=jsonlite) are its only dependencies.

## Usage

```r
library(internetdata)

client <- internetdata_client()
```

### With an API key

Create one in the [console](https://app.internetdata.io), then pass it in:

```r
client <- internetdata_client(api_key = Sys.getenv("INTERNETDATA_API_KEY"))
```

The key is optional: leave it out, or pass an empty one, and no `Authorization` header is sent at all.

### Errors

Every failure is a condition of class `internetdata_error`, carrying `kind`, `status`, `retryable` and `retry_after`:

```r
tryCatch(client$clear_cache(), internetdata_error = function(e) {
    message(e$kind, ": ", conditionMessage(e))
})
```

`kind` is one of `bad_request`, `unauthorized`, `forbidden`, `rate_limited`, `quota_exceeded`, `server_error` or `network`, and each is also a class of its own (`internetdata_rate_limited`).

`rate_limited` and `quota_exceeded` both arrive as HTTP 429 and are not the same thing: a rate limit passes if you wait, while a spent quota needs your allowance raised or the window to roll over. The library retries rate limits for you, and server and network failures, but never a spent quota or anything else you sent. It waits the `Retry-After` the API sent, or its own backoff from 250 ms when that is past about 24.8 days.

### Timeouts and retries

Each attempt gives up after 30 seconds, and a transient failure is retried twice. Both can be changed for the client, and for a single call:

```r
client <- internetdata_client(timeout = 10, retries = 4)
```

The timeout is in seconds and applies to each attempt, body included, so a retried call can take longer in total, and 0 means no bound. An attempt that runs out of time fails as a retryable `network` error. A timeout or retry count no call can use is refused where you pass it, before any request.

## Documentation

The API reference is at [docs.internetdata.io](https://docs.internetdata.io), and `?internetdata_client` documents every option.

## Other Libraries

There are official InternetData client libraries available for many languages including PHP, Python, Go, Java, and Ruby. See our GitHub at https://github.com/internetdata for more.

## About InternetData

Geolocation, anonymity, ownership, network, service and domain data for any IP address, AS or domain, by API or as databases you download.

[<img src="https://s3.internetdata.io/internetdata-public/brand/mark.svg" alt="InternetData" height="64"/>](https://internetdata.io/)

## License

This project is licensed under the [MIT License](LICENSE.md).
