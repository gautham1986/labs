#!/usr/bin/env bash
# svc-report.sh - tab-separated service report from a JSON inventory
# usage: svc-report.sh [-s STATUS] FILE
set -euo pipefail

usage() { echo "usage: svc-report.sh [-s STATUS] FILE" >&2; exit 2; }

status=""
while getopts ':s:' opt; do
  case $opt in
    s) status=$OPTARG ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
(( $# == 1 )) || usage
file=$1

[[ -r "$file" ]] || { echo "svc-report.sh: cannot read $file" >&2; exit 1; }
jq empty "$file" 2>/dev/null || { echo "svc-report.sh: invalid JSON in $file" >&2; exit 1; }

jq -r --arg status "$status" '
  [ .services[] | select($status == "" or .status == $status) ]
  | sort_by(.name) as $svcs
  | ["NAME", "STATUS", "REPLICAS", "VERSION"],
    ($svcs[] | [.name, .status, (.replicas // 0), (.version // "-")])
  | @tsv
' "$file"

jq -r --arg status "$status" '
  [ .services[] | select($status == "" or .status == $status) ]
  | "total: \(length) services, \(map(select(.status == "running")) | length) running, \(map(.replicas // 0) | add // 0) replicas"
' "$file"
