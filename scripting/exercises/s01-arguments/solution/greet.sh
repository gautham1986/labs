#!/usr/bin/env bash
# greet.sh - greet one or more people
# usage: greet.sh [--shout] NAME...
set -euo pipefail

usage() { echo "usage: greet.sh [--shout] NAME..." >&2; }

shout=0
if [[ "${1:-}" == --shout ]]; then
  shout=1
  shift
fi

if (( $# == 0 )); then
  usage
  exit 2
fi

for name in "$@"; do          # "$@" keeps each argument intact, spaces and all
  msg="Hello, $name!"
  (( shout )) && msg=${msg^^}
  echo "$msg"
done
