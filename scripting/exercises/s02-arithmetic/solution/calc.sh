#!/usr/bin/env bash
# calc.sh - integer calculator
# usage: calc.sh A OP B     (OP: + - x / %)
set -euo pipefail

die() { echo "error: $2" >&2; exit "$1"; }   # die <exit-code> <message>

(( $# == 3 )) || { echo "usage: calc.sh A OP B   (OP: + - x / %)" >&2; exit 2; }
a=$1 op=$2 b=$3

for n in "$a" "$b"; do
  [[ "$n" =~ ^-?[0-9]+$ ]] || die 2 "not an integer: $n"
done

case "$op" in
  +) echo $(( a + b )) ;;
  -) echo $(( a - b )) ;;
  x|X) echo $(( a * b )) ;;
  /|%)
    (( b != 0 )) || die 1 "division by zero"
    if [[ "$op" == / ]]; then echo $(( a / b )); else echo $(( a % b )); fi
    ;;
  *) die 2 "unknown operator: $op (use + - x / %)" ;;
esac
