#!/usr/bin/env bash
set -u
SSHLS_LIB=1 source "$(dirname "$0")/../sshls"

fail=0
tmp=$(mktemp)

check() { # desc expected
    local got; got=$(read_columns "$tmp" 2>/dev/null)
    if [ "$got" != "$2" ]; then echo "FAIL $1 (got '$got' want '$2')"; fail=1; fi
}

: >"$tmp"
check "empty file -> default"  "host hostname user tags"

echo 'columns = ["host", "port", "tags"]' >"$tmp"
check "single line"            "host port tags"

printf 'columns = [\n  "User", # login\n  '\''hostname'\'',\n]\n' >"$tmp"
check "multi-line, case, quotes" "user hostname"

echo 'columns = ["host", "bogus"]' >"$tmp"
check "unknown skipped"        "host"

echo 'columns = ["bogus"]' >"$tmp"
check "all unknown -> default" "host hostname user tags"

printf '[other]\ncolumns = ["port"]\n' >"$tmp"
check "key in table ignored"   "host hostname user tags"

got=$(read_columns /nonexistent/file)
[ "$got" = "host hostname user tags" ] || { echo "FAIL missing file"; fail=1; }

got=$(printf 'web1\t1.example.com\troot\t22\t\tprod web\n' | format_table "host port identityfile")
want=$(printf '\tHOST  PORT  IDENTITYFILE\nweb1\tweb1  22    -')
[ "$got" = "$want" ] || { echo "FAIL format_table"; printf '%s\n' "$got"; fail=1; }

rm -f "$tmp"
[ "$fail" = 0 ] && echo "PASS test_columns" || exit 1
