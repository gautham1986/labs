#!/usr/bin/env bash
# retry.sh - run a command until it succeeds, with optional exponential backoff
# usage: retry.sh [-n ATTEMPTS] [-d DELAY] [-b] [--] COMMAND [ARG...]
set -uo pipefail     # no -e: we expect the command to fail sometimes

attempts=3 delay=1 backoff=0
# TODO: parse options (getopts stops at "--" or the first non-option for you)
# TODO: validate attempts (positive int) and delay (number), and that a command was given (exit 2)
# TODO: loop: run "$@"; on success exit 0; otherwise log to stderr, sleep, maybe double the delay
# TODO: exit with the last attempt's exit code

echo "TODO $attempts $delay $backoff"
