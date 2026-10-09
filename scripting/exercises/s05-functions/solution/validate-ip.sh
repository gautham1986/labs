#!/usr/bin/env bash
# validate-ip.sh - validate IPv4 addresses
# usage: validate-ip.sh [-q] ADDR...     (also sourceable: provides is_valid_ipv4)

is_valid_ipv4() {
  local ip=$1 octet
  [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || return 1
  for octet in "${BASH_REMATCH[@]:1}"; do
    [[ "$octet" == 0 || "$octet" != 0* ]] || return 1    # no leading zeros
    (( 10#$octet <= 255 )) || return 1
  done
  return 0
}

main() {
  set -euo pipefail
  local quiet=0 rc=0 ip
  if [[ "${1:-}" == -q ]]; then quiet=1; shift; fi
  (( $# > 0 )) || { echo "usage: validate-ip.sh [-q] ADDR..." >&2; exit 2; }
  for ip in "$@"; do
    if is_valid_ipv4 "$ip"; then
      (( quiet )) || echo "$ip: valid"
    else
      (( quiet )) || echo "$ip: invalid"
      rc=1
    fi
  done
  exit "$rc"
}

# Run main only when executed directly; when sourced, just define the function.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
