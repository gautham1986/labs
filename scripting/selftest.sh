#!/usr/bin/env bash
# selftest.sh - check the scripting track itself:
#   every reference solution must pass its tests, every starter must fail them.
# usage: scripting/selftest.sh [sNN...]
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export LAB_ROOT=$ROOT NO_COLOR=1
fails=0
for ex in "$ROOT"/scripting/exercises/*/; do
  id=$(basename "$ex"); id=${id%%-*}
  if (( $# )) && [[ " $* " != *" $id "* ]]; then continue; fi
  for kind in solution starter; do
    wd=$(mktemp -d)
    cp "$ex/$kind"/* "$wd/"
    out=$(WORK_DIR=$wd LAB_ID=$id bash "$ex/test.sh" 2>&1); rc=$?
    rm -rf "$wd"
    if [[ $kind == solution && $rc -ne 0 ]]; then
      echo "FAIL $id: reference solution does not pass"; echo "$out" | grep -E '✘' | sed 's/^/     /'; fails=$((fails + 1))
    elif [[ $kind == starter && $rc -eq 0 ]]; then
      echo "FAIL $id: starter passes the tests (tests too weak?)"; fails=$((fails + 1))
    else
      echo "ok   $id $kind ($(echo "$out" | tail -1))"
    fi
  done
done
(( fails == 0 )) && echo "selftest: all good" || { echo "selftest: $fails problem(s)"; exit 1; }
