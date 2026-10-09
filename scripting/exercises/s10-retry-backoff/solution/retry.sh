#!/usr/bin/env bash
# retry.sh - run a command until it succeeds, with optional exponential backoff
# usage: retry.sh [-n ATTEMPTS] [-d DELAY] [-b] [--] COMMAND [ARG...]
set -uo pipefail     # no -e: we expect the command to fail sometimes

usage() { echo "usage: retry.sh [-n ATTEMPTS] [-d DELAY] [-b] [--] COMMAND [ARG...]" >&2; exit 2; }

attempts=3 delay=1 backoff=0
while getopts ':n:d:b' opt; do
  case $opt in
    n) attempts=$OPTARG ;;
    d) delay=$OPTARG ;;
    b) backoff=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[[ "$attempts" =~ ^[1-9][0-9]*$ ]] || usage
[[ "$delay" =~ ^[0-9]+([.][0-9]+)?$|^[.][0-9]+$ ]] || usage
(( $# > 0 )) || usage

for (( i = 1; ; i++ )); do
  "$@"
  rc=$?
  (( rc == 0 )) && exit 0
  (( i >= attempts )) && exit "$rc"
  echo "retry: attempt $i/$attempts failed (exit $rc), retrying in ${delay}s" >&2
  sleep "$delay"
  (( backoff )) && delay=$(awk -v d="$delay" 'BEGIN { print d * 2 }')
done
