#!/usr/bin/env bash
set -u
SSHLS_LIB=1 source "$(dirname "$0")/../sshls"

fail=0
assert_eq() { # desc actual expected
    if [ "$2" != "$3" ]; then
        printf 'FAIL %s\n  expected: %q\n  actual:   %q\n' "$1" "$3" "$2"; fail=1
    fi
}
assert_err() { # desc args...
    local d="$1"; shift
    if build_cluster "$@" >/dev/null 2>&1; then
        printf 'FAIL %s (expected non-zero exit)\n' "$d"; fail=1
    fi
}
T=$'\x1f'

# Two ranges, matching counts, different padding; constants broadcast
out=$(build_cluster "connect-prg-{01..03}" "{1..3}.prg.eu" "matej" "22" "" "kafka")
exp="connect-prg-01${T}1.prg.eu${T}matej${T}22${T}${T}kafka
connect-prg-02${T}2.prg.eu${T}matej${T}22${T}${T}kafka
connect-prg-03${T}3.prg.eu${T}matej${T}22${T}${T}kafka"
assert_eq "two ranges zip" "$out" "$exp"

# All constant -> single row
out=$(build_cluster "h" "hn" "u" "" "" "")
assert_eq "single row" "$out" "h${T}hn${T}u${T}${T}${T}"

# Mismatched counts -> error
assert_err "count mismatch" "{1..3}" "{1..2}.eu" "" "" "" ""

# Duplicate aliases (range only in HostName) -> error
assert_err "dup aliases" "fixedhost" "{1..3}.eu" "" "" "" ""

# expand_range error propagates
assert_err "bad range" "{3..1}" "" "" "" "" ""

# Round-trip regression: empty middle field (IdentityFile) must survive parse-back.
# Before the fix (TAB separator) read collapses empty fields and shifts later ones left,
# so 'id' gets "kafka" and 't' gets "".  After the fix (US=\x1f) both are correct.
row=$(build_cluster "connect-prg-{01..01}" "{1..1}.x" "matej" "22" "" "kafka" | head -1)
US=$'\x1f'
IFS="$US" read -r _h _hn _u _p _id _t <<< "$row"
assert_eq "round-trip: empty IdentityFile is empty" "$_id" ""
assert_eq "round-trip: Tags survive past empty field" "$_t" "kafka"

[ "$fail" = 0 ] && echo "PASS test_build_cluster" || exit 1
