#!/usr/bin/env bash
# svc-report.sh - tab-separated service report from a JSON inventory
# usage: svc-report.sh [-s STATUS] FILE
set -euo pipefail

# TODO: parse -s STATUS; FILE is required (exit 2)
# TODO: check FILE exists and is valid JSON (exit 1): jq empty "$file"
# TODO: print the header, the rows (sorted by name, defaults for missing fields) and the total line
#       hint: pass the status filter with --arg, not by pasting it into the jq program

echo "TODO"
