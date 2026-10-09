#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=calc.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

section "Arithmetic"
t "3 + 4 = 7"          '[[ "$(S 3 + 4)" == 7 ]]'
t "10 - 25 = -15"      '[[ "$(S 10 - 25)" == -15 ]]'
t "-6 x 7 = -42"       '[[ "$(S -6 x 7)" == -42 ]]'
t "17 / 5 = 3"         '[[ "$(S 17 / 5)" == 3 ]]'
t "17 % 5 = 2"         '[[ "$(S 17 % 5)" == 2 ]]'
t "big numbers: 123456789 x 1000 = 123456789000" '[[ "$(S 123456789 x 1000)" == 123456789000 ]]'

section "Errors"
t "1 / 0 -> exit 1"                     'S 1 / 0 >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "1 / 0 -> 'division by zero' on stderr" 'S 1 / 0 2>&1 >/dev/null | grep -qi "division by zero"'
t "1 % 0 -> exit 1"                     'S 1 % 0 >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "2.5 + 1 -> exit 2"                   'S 2.5 + 1 >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "a + 1 -> exit 2"                     'S a + 1 >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "unknown operator -> exit 2"          'S 1 ^ 2 >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "wrong arg count -> exit 2 + usage"   'S 1 + >/dev/null 2>&1; [[ $? -eq 2 ]] && S 2>&1 | grep -qi usage'
t "errors print nothing on stdout"      '[[ -z "$(S 1 / 0 2>/dev/null)" ]]'
done_testing
