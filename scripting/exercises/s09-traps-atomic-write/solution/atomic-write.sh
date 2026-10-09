#!/usr/bin/env bash
# atomic-write.sh - atomically replace a file with stdin
# usage: some-command | atomic-write.sh [-e] [-m MODE] TARGET
set -euo pipefail

usage() { echo "usage: atomic-write.sh [-e] [-m MODE] TARGET" >&2; exit 2; }

allow_empty=0 mode=""
while getopts ':em:' opt; do
  case $opt in
    e) allow_empty=1 ;;
    m) mode=$OPTARG ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
(( $# == 1 )) || usage
target=$1
[[ -z "$mode" || "$mode" =~ ^[0-7]{3,4}$ ]] || usage

dir=$(dirname -- "$target")
[[ -d "$dir" ]] || { echo "atomic-write.sh: directory does not exist: $dir" >&2; exit 1; }

tmp=$(mktemp "$dir/.$(basename -- "$target").XXXXXX")
child=""
cleanup() { [[ -n "$child" ]] && kill "$child" 2>/dev/null; rm -f -- "$tmp"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Run cat in the background and wait: `wait` returns as soon as a signal arrives,
# so the trap fires immediately instead of after stdin closes.
# (<&0 matters: without job control, background commands get /dev/null as stdin.)
cat <&0 > "$tmp" & child=$!
wait "$child"; child=""

if [[ ! -s "$tmp" ]] && (( ! allow_empty )); then
  echo "atomic-write.sh: refusing to write empty content to $target (use -e)" >&2
  exit 1
fi

if [[ -z "$mode" ]]; then
  if [[ -e "$target" ]]; then mode=$(stat -c %a -- "$target"); else mode=644; fi
fi
chmod "$mode" "$tmp"
mv -f -- "$tmp" "$target"
