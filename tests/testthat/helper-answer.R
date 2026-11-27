# The eight flags the API serves on a paid plan and the trial, and no longer to a keyless caller.
paid_flags <- c("is_bot", "is_carrier", "is_satellite", "is_ssh", "is_smtp", "is_web",
    "is_dns_resolver", "is_bittorrent")

# The smallest answer the pinned spec accepts for an address: every required member, nothing else.
# That is a keyless answer's shape, with none of the paid flags and no `asn$type`.
answer_body <- function(ip, ...) {
    empty <- structure(list(), names = character(0))
    utils::modifyList(list(ip = ip, is_bogon = FALSE, is_tor = FALSE, is_relay = FALSE,
        is_anycast = FALSE, tor = empty, relay = empty,
        location = as.list(stats::setNames(rep("", 10), c("continent", "continent_name", "country",
            "country_name", "timezone", "currency_code", "currency_name", "currency_symbol", "flag_emoji",
            "flag_unicode"))),
        asn = list(asn = 15169L, name = "Google LLC", domain = "google.com",
            prefix = "8.8.8.0/24", country = "US", rpki_status = "valid"),
        company = list(name = "Google LLC", domain = "google.com"), hostname = "",
        abuse = list(email = "network-abuse@google.com")), list(...))
}
