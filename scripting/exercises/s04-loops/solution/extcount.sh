#!/usr/bin/env bash
# extcount.sh - count files by extension
# usage: extcount.sh DIR
set -euo pipefail

dir=${1:-}
[[ -n "$dir" ]] || { echo "usage: extcount.sh DIR" >&2; exit 2; }
[[ -d "$dir" ]] || { echo "extcount.sh: not a directory: $dir" >&2; exit 2; }

declare -A count=()
while IFS= read -r -d '' path; do
  name=${path##*/}                      # basename without forking
  base=${name#.}                        # a leading dot doesn't start an extension
  if [[ "$base" == *.* ]]; then
    ext=${base##*.}
    ext=${ext,,}
  else
    ext="(none)"
  fi
  count[$ext]=$(( ${count[$ext]:-0} + 1 ))
done < <(find "$dir" -type f -print0)

for ext in "${!count[@]}"; do
  printf '%d %s\n' "${count[$ext]}" "$ext"
done | sort -k1,1nr -k2,2
