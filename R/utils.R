int_to_bytes <- function(n) {
    b <- raw(8)
    for (i in seq_along(b)) {
        b[8 - i + 1] <- as.raw(n %% 256L)
        n <- n %/% 256L
    }
    b
}

dymtrunc <- function(h) {
    offset <- as.integer(h[20] & as.raw(0xf))
    u <- h[(offset + 1):(offset + 4)]
    u[1] <- u[1] & as.raw(0x7f)
    sum(as.integer(u) * 256 ^ (3:0))
}


re_match <- function(pattern, x) {
    regmatches(x, regexec(pattern, x, perl = T))
}
