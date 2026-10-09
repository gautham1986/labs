#!/usr/bin/env bash
# validate-ip.sh - validate IPv4 addresses
# usage: validate-ip.sh [-q] ADDR...     (also sourceable: provides is_valid_ipv4)

is_valid_ipv4() {
  # TODO: return 0 if "$1" is a valid dotted-quad IPv4 address, 1 otherwise
  return 1
}

main() {
  set -euo pipefail
  # TODO: handle -q, usage/exit 2, loop over addresses, print results, exit 0/1
  echo "TODO"
}

# TODO: only call main when the script is executed, not when it is sourced
main "$@"
