#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=svc-report.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
F=$FIXTURES/services.json
FULL=$'NAME\tSTATUS\tREPLICAS\tVERSION\napi\trunning\t3\t1.4.2\ncron\tstopped\t0\t0.9.9\nsearch\trunning\t2\t-\nweb\trunning\t4\t2.3.1\nworker\tdegraded\t1\t1.4.0\ntotal: 5 services, 3 running, 10 replicas'
RUN=$'NAME\tSTATUS\tREPLICAS\tVERSION\napi\trunning\t3\t1.4.2\nsearch\trunning\t2\t-\nweb\trunning\t4\t2.3.1\ntotal: 3 services, 3 running, 9 replicas'

section "Report"
t "full report matches exactly (tabs, order, defaults)" '[[ "$(S "$F")" == "$FULL" ]]'
t "-s running filters rows and totals"                  '[[ "$(S -s running "$F")" == "$RUN" ]]'
t "-s with no matches: header + zero totals"            '[[ "$(S -s missing "$F" | tail -1)" == "total: 0 services, 0 running, 0 replicas" ]]'
t "status with quotes can't break the jq program"       'S -s "\"); halt_error(1) #" "$F" >/dev/null'

section "Errors"
t "invalid JSON -> exit 1"   'S "$FIXTURES/broken.json" >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "missing file -> exit 1"   'S /nonexistent.json >/dev/null 2>&1; [[ $? -eq 1 ]]'
t "no FILE -> exit 2"        'S >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
