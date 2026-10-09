#!/usr/bin/env bash
# fileinfo.sh - describe what kind of thing each path is
# usage: fileinfo.sh PATH...
set -euo pipefail

(( $# > 0 )) || { echo "usage: fileinfo.sh PATH..." >&2; exit 2; }

rc=0
for p in "$@"; do
  if [[ -L "$p" ]]; then                       # first: -d/-f would follow the link
    echo "$p: symlink -> $(readlink -- "$p")"
  elif [[ -d "$p" ]]; then
    echo "$p: directory"
  elif [[ -f "$p" ]]; then
    size=$(stat -c %s -- "$p")
    if [[ -x "$p" ]]; then echo "$p: executable file ($size bytes)"
    else echo "$p: file ($size bytes)"; fi
  elif [[ -e "$p" ]]; then
    echo "$p: other"
  else
    echo "$p: missing"
    rc=1
  fi
done
exit "$rc"
