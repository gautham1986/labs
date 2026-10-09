#!/usr/bin/env bash
# backup.sh - timestamped tar.gz backups with retention
# usage: backup.sh -s SRC -d DEST [-k KEEP] [-n] [-h]
set -euo pipefail

usage() { echo "usage: backup.sh -s SRC -d DEST [-k KEEP] [-n] [-h]"; }
bad_usage() { usage >&2; exit 2; }

src="" dest="" keep=3 dry=0
while getopts ':s:d:k:nh' opt; do
  case $opt in
    s) src=${OPTARG%/} ;;
    d) dest=${OPTARG%/} ;;
    k) keep=$OPTARG ;;
    n) dry=1 ;;
    h) usage; exit 0 ;;
    *) bad_usage ;;
  esac
done
shift $((OPTIND - 1))
[[ -n "$src" && -n "$dest" && $# -eq 0 ]] || bad_usage
[[ "$keep" =~ ^[1-9][0-9]*$ ]] || bad_usage
[[ -d "$src" ]] || { echo "backup.sh: not a directory: $src" >&2; exit 1; }

name=$(basename -- "$src")
parent=$(dirname -- "$src")
archive="$dest/$name-$(date +%Y%m%d-%H%M%S).tar.gz"

if (( dry )); then
  echo "would create $archive"
else
  mkdir -p -- "$dest"
  tar -czf "$archive" -C "$parent" "$name"
  echo "created $archive"
fi

# Retention: names sort chronologically, so everything except the last $keep goes.
shopt -s nullglob
archives=("$dest/$name"-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9].tar.gz)
(( dry )) && archives+=("$archive")       # pretend the new one exists
mapfile -t sorted < <(printf '%s\n' "${archives[@]}" | sort -u)
excess=$(( ${#sorted[@]} - keep ))
for (( i = 0; i < excess; i++ )); do
  if (( dry )); then echo "would delete ${sorted[i]}"
  else rm -f -- "${sorted[i]}"; echo "deleted ${sorted[i]}"; fi
done
