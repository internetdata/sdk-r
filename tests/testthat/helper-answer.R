# The smallest answer the pinned spec accepts for an address: every required member, nothing else.
answer_body <- function(ip, ...) {
    empty <- structure(list(), names = character(0))
    utils::modifyList(list(ip = ip, is_bogon = FALSE, is_tor = FALSE, is_relay = FALSE, is_bot = FALSE,
        is_anycast = FALSE, is_carrier = FALSE, is_satellite = FALSE, is_ssh = FALSE, is_smtp = FALSE,
        is_web = FALSE, is_dns_resolver = FALSE, is_bittorrent = FALSE, tor = empty, relay = empty,
        location = as.list(stats::setNames(rep("", 10), c("continent", "continent_name", "country",
            "country_name", "timezone", "currency_code", "currency_name", "currency_symbol", "flag_emoji",
            "flag_unicode"))),
        asn = list(asn = 15169L, name = "Google LLC", domain = "google.com", type = "hosting",
            prefix = "8.8.8.0/24", country = "US", rpki_status = "valid"),
        company = list(name = "Google LLC", domain = "google.com"), hostname = "",
        abuse = list(email = "network-abuse@google.com")), list(...))
}
