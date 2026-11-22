# [<img src="https://s3.internetdata.io/internetdata-public/brand/mark.svg" alt="InternetData" height="28"/>](https://internetdata.io/) InternetData R Client Library

[![CRAN](https://www.r-pkg.org/badges/version/internetdata)](https://cran.r-project.org/package=internetdata)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/internetdata/sdk-r/blob/main/LICENSE.md)

The official R client library for the [InternetData](https://internetdata.io) API.

## Getting Started

```r
install.packages("internetdata")
```

Requires R 4.1 or newer. [curl](https://cran.r-project.org/package=curl) and [jsonlite](https://cran.r-project.org/package=jsonlite) are its only dependencies.

## Usage

No API key is needed to start. Unlimited, the free plan, answers `location`, `asn`, `company`, `abuse` and every flag but the VPN, proxy, hosting and CDN ones, with no daily or monthly cap.

```r
library(internetdata)

client <- internetdata_client()

answer <- client$lookup("146.70.116.130")
answer$location$country  # "AT"
answer$asn$name          # "M247 Europe SRL"
answer$company$name      # who uses the address
```

The answer is the API's JSON as a list, and a member the API adds later simply appears in it.

### With an API key

Every paid plan answers every field: the VPN, proxy, hosting and CDN flags, the detail behind each flag (`bot` names whose bot uses the address), the city, the Whois records and more. The plans differ only in how many lookups they include, and a free account tries every field. Create a key in the [console](https://app.internetdata.io), then pass it in:

```r
client <- internetdata_client(api_key = Sys.getenv("INTERNETDATA_API_KEY"))

answer <- client$lookup("146.70.116.130")
answer$is_vpn         # TRUE, on a paid plan
answer$vpn$provider   # "mullvad", on a paid plan
answer$location$city  # "Vienna", on a paid plan
```

The key is optional: leave it out, or pass an empty one, and no `Authorization` header is sent at all.

### AS numbers and domains

```r
client$lookup_asn(9009)$name                 # "M247 Europe SRL"
client$lookup_domain("example.com")$has_mx   # TRUE
```

Unlimited answers an AS's registration, and whether a domain is registered and which record types it has. A paid plan adds the AS's Whois record, prefixes, rank, Tier 1 flag, upstreams, peers, downstreams and hosted domains, and the domain's records, the network announcing each of its addresses, the other domains on its first IPv4 address, IP ranges, whether it is disposable, what its home page says and links to, and the domains whose home page redirects or links to it. Neither is cached or batched.

### Your own address

```r
client$my_ip()$ip  # the address we saw this call come from
```

Same answer `lookup` would give for that address, and the same cost against your allowance. It is not cached, since a machine that moves between networks would otherwise be told where it used to be.

### Your plan and usage

```r
account <- client$my_entitlement()
account$plan$key         # "starter"
account$plan$name        # "Starter", the name to show
account$usage$requests   # 580
account$usage$window_end # when the allowance resets
```

Show `name` and compare against `key`: a plan's name can change, and its key never does. Usage counts against the anniversary of your subscription on a paid plan and against its trial on the free plan. `hard_limit` is `NULL` on an uncapped plan, which is not the same as zero.

### Batch lookup

```r
answers <- client$lookup_batch(c("1.1.1.1", "8.8.8.8", "10.0.0.1"))
answers[["8.8.8.8"]]$asn$name
```

The result is a named list with one entry per distinct address. An address that failed holds its error rather than failing the batch. The batch endpoint needs a paid plan, and any number of addresses is sent in chunks of 1000, up to `concurrency` (8) at once.

### Caching

Each client keeps up to 10,000 answers for an hour, so asking about an address again costs nothing. `internetdata_client(cache_size = 0)` turns it off, `cache_ttl` sets the hour in seconds, and `client$clear_cache()` empties it.

### Private and reserved addresses

A private, loopback, link-local, documentation or otherwise reserved address is answered locally, never sent, with `is_bogon` set to `TRUE`, every flag `FALSE` and every detail empty. `is_bogon()` is the same check without a client:

```r
is_bogon("10.0.0.1")  # TRUE
is_bogon("8.8.8.8")   # FALSE
```

An IPv4-mapped IPv6 address is read as the IPv4 address it carries.

### Errors

Every failure is a condition of class `internetdata_error`, carrying `kind`, `status`, `retryable` and `retry_after`:

```r
tryCatch(client$lookup("146.70.116.130"), internetdata_error = function(e) {
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

### Absent is not false

Unlimited leaves out `is_vpn`, the four proxy flags, `is_hosting` and `is_cdn`, the detail behind every flag but Tor's and relay's, the Whois records and `hosted_domains`, and inside `location` the city, region and coordinates. A free-plan key's answer carries `trial_expired`, `TRUE` once its trial is spent, and a paid key's carries `cap_reached`, `TRUE` once its organization's overage cap is reached. A member your plan leaves out is absent from the list, never `FALSE`:

```r
isTRUE(answer$is_vpn)  # when you only want the flag
is.null(answer$is_vpn) # on Unlimited: not in your plan
```

## Documentation

The API reference is at [docs.internetdata.io](https://docs.internetdata.io), and `?internetdata_client` documents every option.

## Other Libraries

There are official InternetData client libraries available for many languages including PHP, Python, Go, Java, and Ruby. See our GitHub at https://github.com/internetdata for more.

## About InternetData

Geolocation, anonymity, ownership, network, service and domain data for any IP address, AS or domain, by API or as databases you download.

[<img src="https://s3.internetdata.io/internetdata-public/brand/mark.svg" alt="InternetData" height="64"/>](https://internetdata.io/)

## License

This project is licensed under the [MIT License](https://github.com/internetdata/sdk-r/blob/main/LICENSE.md).
