#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=atomic-write.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
leftovers() { find "$TMPD" -maxdepth 1 -name '.target*' | grep -q .; }

section "Writing"
t "writes stdin to a new file"          'echo hello | S target && [[ "$(cat target)" == hello ]]'
t "new files get mode 644"              '[[ $(stat -c %a target) == 644 ]]'
t "replaces existing content"           'printf "a\nb\n" | S target && [[ "$(cat target)" == $'"'"'a\nb'"'"' ]]'
t "keeps the existing mode"             'chmod 640 target && echo x | S target && [[ $(stat -c %a target) == 640 ]]'
t "-m sets the mode"                    'echo y | S -m 600 target && [[ $(stat -c %a target) == 600 ]]'
t "replaces via rename (new inode)"     'i1=$(stat -c %i target); echo z | S target; [[ $(stat -c %i target) != "$i1" ]]'
t "no temp files left behind"           '! leftovers'

section "Safety"
t "empty input refused (exit 1), file kept"   'echo keep > target; S target < /dev/null; [[ $? -eq 1 && "$(cat target)" == keep ]] && ! leftovers'
t "-e allows empty content"                   'S -e target < /dev/null && [[ ! -s target ]]'
t "missing directory -> exit 1"               'echo x | S nodir/target >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "no target -> exit 2"                       'S </dev/null >/dev/null 2>&1; [[ $? -eq 2 ]]'

section "Interrupted"
t "SIGTERM mid-write: exit 143, target unchanged, temp removed" '
  echo original > target; mkfifo feed
  ( echo partial; sleep 2; echo rest ) > feed &
  set -m   # job control: otherwise background jobs start with SIGINT ignored
  bash "$SCRIPT_PATH" target < feed & pid=$!
  sleep 0.7; kill -TERM $pid; wait $pid; rc=$?
  wait
  [[ $rc -eq 143 && "$(cat target)" == original ]] && ! leftovers'
t "SIGINT mid-write: exit 130, target unchanged, temp removed" '
  echo original > target; rm -f feed; mkfifo feed
  ( echo partial; sleep 2; echo rest ) > feed &
  set -m   # job control: otherwise background jobs start with SIGINT ignored
  bash "$SCRIPT_PATH" target < feed & pid=$!
  sleep 0.7; kill -INT $pid; wait $pid; rc=$?
  wait
  [[ $rc -eq 130 && "$(cat target)" == original ]] && ! leftovers'
done_testing
