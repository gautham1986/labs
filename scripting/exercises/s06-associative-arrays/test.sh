#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=wordfreq.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
F=$FIXTURES/text.txt

section "Counting"
t "top 3 of the fixture (ties alphabetical)" '[[ "$(S -n 3 "$F")" == $'"'"'6 the\n3 dog\n3 fox'"'"' ]]'
t "case-insensitive (FOX = fox)"      'S "$F" | grep -qx "3 fox"'
t "apostrophes split words (it, s)"   'S -n 50 "$F" | grep -qx "2 s"'
t "ties sorted alphabetically"        '[[ "$(S -n 50 "$F" | grep "^1 " | head -3)" == $'"'"'1 a\n1 and\n1 brown'"'"' ]]'
t "default is 10 lines"               '[[ $(S "$F" | wc -l) -eq 10 ]]'

section "Input handling"
t "reads stdin when no file is given" '[[ "$(echo "b a b" | S)" == $'"'"'2 b\n1 a'"'"' ]]'
t "reads stdin for -"                 '[[ "$(echo "x x y" | S -n 1 -)" == "2 x" ]]'
t "empty input -> no output, exit 0"  '[[ -z "$(S < /dev/null)" ]]'
t "missing file -> exit 1"            'S /nonexistent >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "-n 0 -> exit 2"                    'S -n 0 "$F" >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "-n abc -> exit 2"                  'S -n abc "$F" >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
