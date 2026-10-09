#!/usr/bin/env bash
# wordfreq.sh - top N words in a file or stdin
# usage: wordfreq.sh [-n N] [FILE]
set -euo pipefail

n=10
# TODO: parse -n with getopts and validate it (positive integer, else exit 2)
# TODO: read FILE (or stdin when missing or "-"); exit 1 if FILE doesn't exist
# TODO: split into lower-case words (letters only), count them in an associative array
# TODO: print "COUNT WORD", highest count first, ties alphabetical, at most $n lines

echo "TODO $n"
