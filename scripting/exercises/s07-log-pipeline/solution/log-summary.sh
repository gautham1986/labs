#!/usr/bin/env bash
# log-summary.sh - summarise nginx access logs (plain or .gz)
# usage: log-summary.sh FILE...
set -euo pipefail

(( $# > 0 )) || { echo "usage: log-summary.sh FILE..." >&2; exit 2; }
for f in "$@"; do
  [[ -r "$f" ]] || { echo "log-summary.sh: cannot read $f" >&2; exit 1; }
done

zcat -f -- "$@" | awk '
  {
    requests++
    ips[$1] = 1
    class = substr($9, 1, 1)
    status[class]++
    bytes += ($10 == "-" ? 0 : $10)
    paths[$7]++
  }
  END {
    n = 0; for (ip in ips) n++
    printf "requests: %d\nunique_ips: %d\n", requests, n
    for (c = 2; c <= 5; c++) printf "status_%dxx: %d\n", c, status[c]
    printf "bytes: %d\ntop_paths:\n", bytes
    for (p in paths) printf "%d %s\n", paths[p], p | "sort -k1,1nr -k2,2 | head -3 | sed \"s/^/  /\""
  }'
