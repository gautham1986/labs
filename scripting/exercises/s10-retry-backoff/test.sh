#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=retry.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks
# flaky: fails until it has been called $1 times (counter in ./count)
cat > "$TMPD/flaky.sh" <<'F'
#!/usr/bin/env bash
n=$(( $(cat count 2>/dev/null || echo 0) + 1 )); echo "$n" > count
(( n >= $1 )) && { echo "ok on try $n"; exit 0; }
exit 9
F
chmod +x "$TMPD/flaky.sh"
elapsed() { local s; s=$(date +%s.%N); "$@" >/dev/null 2>&1; awk -v s="$s" -v e="$(date +%s.%N)" 'BEGIN { printf "%.2f", e - s }'; }

section "Retrying"
t "success on first try: exit 0, no retry message" 'rm -f count; [[ -z "$(S -d 0 -- ./flaky.sh 1 2>&1 >/dev/null)" ]]'
t "fails twice then succeeds: exit 0"              'rm -f count; S -d 0 -- ./flaky.sh 3 >/dev/null 2>&1 && [[ $(cat count) -eq 3 ]]'
t "logs 'attempt K/N failed (exit X)' to stderr"   'rm -f count; S -n 3 -d 0 -- ./flaky.sh 3 2>&1 >/dev/null | grep -q "attempt 1/3 failed (exit 9)"'
t "gives up after N attempts with the cmd exit code" 'rm -f count; S -n 4 -d 0 -- ./flaky.sh 99 >/dev/null 2>&1; rc=$?; [[ $rc -eq 9 && $(cat count) -eq 4 ]]'
t "default is 3 attempts"                          'rm -f count; S -d 0 -- ./flaky.sh 99 >/dev/null 2>&1; [[ $(cat count) -eq 3 ]]'
t "command output passes through"                  'rm -f count; [[ "$(S -d 0 -- ./flaky.sh 2 2>/dev/null)" == "ok on try 2" ]]'

section "Arguments"
t "args with spaces, globs and empty strings arrive intact" '[[ "$(S -- printf "[%s]" "a b" "*" "")" == "[a b][*][]" ]]'
t "works without --"                               '[[ "$(S printf x)" == x ]]'

section "Timing"
t "-d 0.3 with 3 attempts sleeps ~0.6s"           'rm -f count; e=$(elapsed S -n 3 -d 0.3 -- false); awk -v e="$e" "BEGIN { exit !(e >= 0.55 && e < 1.5) }"'
t "-b doubles the delay (0.1+0.2+0.4 = 0.7s)"     'e=$(elapsed S -n 4 -d 0.1 -b -- false); awk -v e="$e" "BEGIN { exit !(e >= 0.65 && e < 1.6) }"'

section "Errors"
t "no command -> exit 2"     'S -n 2 >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "-n 0 -> exit 2"           'S -n 0 -- true >/dev/null 2>&1; [[ $? -eq 2 ]]'
t "-d abc -> exit 2"         'S -d abc -- true >/dev/null 2>&1; [[ $? -eq 2 ]]'
done_testing
