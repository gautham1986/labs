#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=log-summary.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
L=$FIXTURES/access.log G=$FIXTURES/access.log.2.gz

ONE=$'requests: 7\nunique_ips: 4\nstatus_2xx: 4\nstatus_3xx: 1\nstatus_4xx: 1\nstatus_5xx: 1\nbytes: 2752\ntop_paths:\n  3 /\n  2 /api\n  1 /login'
BOTH=$'requests: 9\nunique_ips: 5\nstatus_2xx: 6\nstatus_3xx: 1\nstatus_4xx: 1\nstatus_5xx: 1\nbytes: 5100\ntop_paths:\n  3 /\n  3 /api\n  2 /login'

section "Summary"
t "single plain log: exact output"            '[[ "$(S "$L")" == "$ONE" ]]'
t "plain + .gz rotated log together"          '[[ "$(S "$L" "$G")" == "$BOTH" ]]'
t "status classes counted from the status field" 'S "$L" | grep -qx "status_3xx: 1"'
t "top paths: ties sorted alphabetically"     '[[ "$(S "$L" "$G" | tail -2)" == $'"'"'  3 /api\n  2 /login'"'"' ]]'

section "Errors"
t "no args -> exit 2"                         'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "missing file -> exit 1"                    'S "$L" /nonexistent >/dev/null 2>&1; [[ $? -eq 1 ]]'
done_testing
