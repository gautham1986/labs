#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2016  # variables are used inside the single-quoted t '...' bodies
SCRIPT=validate-ip.sh
source "$LAB_ROOT/scripting/lib/testlib.sh"
basic_checks

section "Valid addresses"
for ip in 0.0.0.0 10.0.0.1 192.168.1.254 255.255.255.255 8.8.8.8; do
  t "$ip is valid" "[[ \"\$(S $ip)\" == \"$ip: valid\" ]]"
done

section "Invalid addresses"
for ip in 256.1.1.1 1.2.3 1.2.3.4.5 01.2.3.4 1.2.3.-4 a.b.c.d 1..2.3 1.2.3.4. ' 1.2.3.4' 999.999.999.999 ''; do
  t "'$ip' is invalid" "[[ \"\$(S '$ip')\" == '$ip: invalid' ]]"
done

section "Exit codes & quiet mode"
t "all valid -> exit 0"        'S 1.1.1.1 2.2.2.2 >/dev/null'
t "one invalid -> exit 1"      'S 1.1.1.1 300.1.1.1 >/dev/null; [[ $? -eq 1 ]]'
t "-q prints nothing"          '[[ -z "$(S -q 1.1.1.1 300.1.1.1)" ]]'
t "-q still sets exit code"    'S -q 300.1.1.1; [[ $? -eq 1 ]] && S -q 1.1.1.1'
t "no args -> exit 2"          'S >/dev/null 2>&1; [[ $? -eq 2 ]]'

section "Sourceable"
t "sourcing prints nothing and doesn't exit"  '[[ "$(bash -c "source \"$SCRIPT_PATH\"; echo still-here")" == still-here ]]'
t "is_valid_ipv4 works when sourced"          'bash -c "source \"$SCRIPT_PATH\"; is_valid_ipv4 10.1.2.3 && ! is_valid_ipv4 10.1.2.300"'
done_testing
