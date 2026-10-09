#!/usr/bin/env bash
# healthcheck.sh - run http/tcp checks from a file, in parallel
# usage: healthcheck.sh [-t SECONDS] [-j] FILE
set -uo pipefail

timeout_s=3 json=0
# TODO: parse -t and -j; validate; FILE must be readable (exit 2)
# TODO: read FILE line by line (skip blanks and # comments); for each check start a
#       background job that writes "ok" or "fail REASON" to its own result file
# TODO: wait for all jobs, then print results in file order (text or JSON)
# TODO: exit 0 if all OK, else 1

echo "TODO $timeout_s $json"
