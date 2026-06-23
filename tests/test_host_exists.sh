#!/usr/bin/env bash
set -u
SSHLS_LIB=1 source "$(dirname "$0")/../sshls"

fail=0
tmp=$(mktemp)
cat >"$tmp" <<'EOF'
Host web1
    HostName 1.example.com
Host web2 web2-alt
    HostName 2.example.com
EOF

check() { # desc alias expected_exit
    host_exists "$2" "$tmp"; local rc=$?
    if [ "$rc" != "$3" ]; then echo "FAIL $1 (rc=$rc want $3)"; fail=1; fi
}

check "existing host"          web1     0
check "second token on line"   web2-alt 0
check "missing host"           web9     1
check "substring not match"    web      1

host_exists anything /nonexistent/file; [ "$?" = 1 ] || { echo "FAIL missing file"; fail=1; }

rm -f "$tmp"
[ "$fail" = 0 ] && echo "PASS test_host_exists" || exit 1
