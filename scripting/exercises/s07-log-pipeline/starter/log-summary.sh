#!/usr/bin/env bash
# log-summary.sh - summarise nginx access logs (plain or .gz)
# usage: log-summary.sh FILE...
set -euo pipefail

# TODO: usage/exit 2 with no args; exit 1 if any file is missing
# TODO: stream all files (gz-aware: zcat -f) into ONE awk program that counts
#       requests, unique IPs, status classes, total bytes, and paths
# TODO: print the exact format from the README (top 3 paths, ties alphabetical)

echo "TODO"
