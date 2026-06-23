#!/usr/bin/env bash
# Source only the function definitions from sshls without running the main loop.
# sshls guards its main body behind `if [ "${SSHLS_LIB:-}" != 1 ]`.
set -u
SSHLS_LIB=1 source "$(dirname "$0")/../sshls"

fail=0
assert_eq() {
    if [ "$2" != "$3" ]; then
        printf 'FAIL %s\n  expected: %q\n  actual:   %q\n' "$1" "$3" "$2"
        fail=1
    fi
}

# Full entry with all fields
out=$(format_entry "web1" "1.example.com" "alice" "2222" "~/.ssh/id_ed25519" "prod, eu")
expected='
# Tags: prod, eu
Host web1
    HostName 1.example.com
    User alice
    Port 2222
    IdentityFile ~/.ssh/id_ed25519'
assert_eq "full entry" "$out" "$expected"

# Minimal entry: no tags, no port, no identityfile
out=$(format_entry "web2" "2.example.com" "bob" "" "" "")
expected='
Host web2
    HostName 2.example.com
    User bob'
assert_eq "minimal entry" "$out" "$expected"

[ "$fail" = 0 ] && echo "PASS test_format_entry" || exit 1
