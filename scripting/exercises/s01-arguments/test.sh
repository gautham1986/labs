#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=greet.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

section "Behaviour"
t "greet.sh Ada -> Hello, Ada!"            '[[ "$(S Ada)" == "Hello, Ada!" ]]'
t "two names -> two lines"                 '[[ "$(S Ada Linus)" == $'"'"'Hello, Ada!\nHello, Linus!'"'"' ]]'
t "a name with a space stays one name"     '[[ "$(S "Grace Hopper")" == "Hello, Grace Hopper!" ]]'
t "--shout upper-cases"                    '[[ "$(S --shout Ada)" == "HELLO, ADA!" ]]'
t "exit code 0 on success"                 'S Ada >/dev/null'

section "Errors"
t "no args -> exit 2"                      'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "no args -> usage on stderr"             'S 2>&1 >/dev/null | grep -qi "^usage:"'
t "no args -> nothing on stdout"           '[[ -z "$(S 2>/dev/null)" ]]'
t "--shout alone -> exit 2"                'S --shout >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
