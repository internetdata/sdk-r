\name{internetdata_client}
\alias{internetdata_client}
\title{A client for the 'InternetData' API}
\description{
Creates a client whose functions look up what an IP address is: where it is, which network and
company it belongs to, and whether it is a VPN, a proxy, a Tor node or a hosting server.
}
\usage{
internetdata_client(api_key = NULL, base_url = NULL, timeout = 30, retries = 2,
  concurrency = 8, cache_size = 10000, cache_ttl = 3600)
}
\arguments{
\item{api_key}{Your API key from the console, or \code{NULL} to look up without one. The key is
trimmed, and a blank one is no key. A key holding a control character is refused.}
\item{base_url}{The API's address. Defaults to \code{https://api.internetdata.io}; a trailing
slash is dropped.}
\item{timeout}{Seconds each attempt may take, body included. 0 means no bound. A retried call can
take longer in total.}
\item{retries}{Attempts after a retryable failure: a 5xx, a transport failure, or a 429 carrying
\code{Retry-After}. Each waits the server's \code{Retry-After}, or a backoff of 250 ms that doubles
per retry.}
\item{concurrency}{Batch chunks in flight at once.}
\item{cache_size}{Answers kept per client, keyed by address. 0 turns the cache off.}
\item{cache_ttl}{Seconds an answer stays cached. 0 turns the cache off.}
}
\value{
A \code{internetdata_client}: a list of functions.
\describe{
\item{\code{lookup(ip, timeout = NULL, retries = NULL)}}{The answer for one address, as a list.
A reserved address is answered locally, with \code{is_bogon} \code{TRUE}.}
\item{\code{lookup_batch(ips, concurrency = NULL, timeout = NULL, retries = NULL)}}{A named
list, one entry per distinct address, in input order. An address that failed holds its
\code{internetdata_error} rather than failing the batch. Any number of addresses is sent in chunks
of 1000.}
\item{\code{lookup_asn(asn, timeout = NULL, retries = NULL)}}{What the API knows about one
autonomous system, by its number: its registration on every plan, and on a paid one its Whois
record, prefixes, rank and neighbors. Sent as given and not cached.}
\item{\code{lookup_domain(domain, timeout = NULL, retries = NULL)}}{What the API knows about one
domain: whether it is registered and which record types it has on every plan, and on a paid one
the records themselves, its IP ranges and whether it is disposable. Sent as given and not cached.}
\item{\code{my_ip(timeout = NULL, retries = NULL)}}{The answer for the address you are calling
from. Never cached.}
\item{\code{my_entitlement(timeout = NULL, retries = NULL)}}{What your API key may spend: its
plan and usage. Never cached.}
\item{\code{clear_cache()}}{Empties the cache.}
}
Every failure is a condition of class \code{internetdata_error} carrying \code{kind}
(\code{bad_request}, \code{unauthorized}, \code{forbidden}, \code{rate_limited},
\code{quota_exceeded}, \code{server_error} or \code{network}), \code{status}, \code{retryable}
and \code{retry_after}.
}
\examples{
client <- internetdata_client()
client$lookup("10.0.0.1")$is_bogon
\donttest{
answer <- tryCatch(client$lookup("8.8.8.8"), internetdata_error = function(e) e)
}
}
