#!/usr/bin/env bash
set -u
SSHLS_LIB=1 source "$(dirname "$0")/../sshls"

fail=0
assert_eq() { # desc actual expected
    if [ "$2" != "$3" ]; then
        printf 'FAIL %s\n  expected: %q\n  actual:   %q\n' "$1" "$3" "$2"; fail=1
    fi
}
assert_err() { # desc text
    if expand_range "$2" >/dev/null 2>&1; then
        printf 'FAIL %s (expected non-zero exit)\n' "$1"; fail=1
    fi
}

# has_range predicate
has_range "web-{1..3}"      && : || { echo "FAIL has_range simple"; fail=1; }
has_range "web-{1..9..2}"   && : || { echo "FAIL has_range step";   fail=1; }
has_range "plain-host"      && { echo "FAIL has_range none"; fail=1; } || :
has_range "weird-{foo}"     && { echo "FAIL has_range nonnum"; fail=1; } || :

# expand_range: no token -> unchanged
assert_eq "no range" "$(expand_range "plain")" "plain"
assert_eq "empty"    "$(expand_range "")"      ""
assert_eq "literal brace" "$(expand_range "a{foo}b")" "a{foo}b"

# simple, unpadded
assert_eq "simple" "$(expand_range "n{1..3}")" "$(printf 'n1\nn2\nn3')"

# zero-padded (leading zero on operand)
assert_eq "padded" "$(expand_range "{01..03}x")" "$(printf '01x\n02x\n03x')"

# leading-zero values must not be parsed as octal (08, 09 valid)
assert_eq "octal-safe" "$(expand_range "{08..10}")" "$(printf '08\n09\n10')"

# '0' alone is not a leading-zero pad trigger
assert_eq "zero-no-pad" "$(expand_range "{0..3}")" "$(printf '0\n1\n2\n3')"

# step
assert_eq "step" "$(expand_range "{0..30..10}")" "$(printf '0\n10\n20\n30')"
# step that does not land on end stops at last <= end
assert_eq "step-trunc" "$(expand_range "{0..25..10}")" "$(printf '0\n10\n20')"

# prefix + suffix around token
assert_eq "around" "$(expand_range "host-{1..2}.eu")" "$(printf 'host-1.eu\nhost-2.eu')"

# single value range
assert_eq "single" "$(expand_range "{5..5}")" "5"

# errors
assert_err "descending"   "{3..1}"
assert_err "two ranges"   "{1..2}-{1..2}"
assert_err "zero step"    "{1..9..0}"

[ "$fail" = 0 ] && echo "PASS test_expand_range" || exit 1
