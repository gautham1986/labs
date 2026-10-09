#!/usr/bin/env bash
# wordfreq.sh - top N words in a file or stdin
# usage: wordfreq.sh [-n N] [FILE]
set -euo pipefail

usage() { echo "usage: wordfreq.sh [-n N] [FILE]" >&2; exit 2; }

n=10
while getopts ':n:' opt; do
  case $opt in
    n) n=$OPTARG ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[[ "$n" =~ ^[1-9][0-9]*$ ]] || usage

file=${1:--}
if [[ "$file" != - ]]; then
  [[ -r "$file" ]] || { echo "wordfreq.sh: cannot read $file" >&2; exit 1; }
  exec < "$file"              # from here on, stdin is the file
fi

declare -A count=()
while IFS= read -r word; do
  [[ -n "$word" ]] && count[$word]=$(( ${count[$word]:-0} + 1 ))
done < <(tr -cs 'A-Za-z' '\n' | tr 'A-Z' 'a-z')

(( ${#count[@]} )) || exit 0
for w in "${!count[@]}"; do
  printf '%d %s\n' "${count[$w]}" "$w"
done | sort -k1,1nr -k2,2 | head -n "$n"
