#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"

status_ok() {
  wait_for 6 bash -c '[[ $(( $(date +%s) - $(stat -c %Y /run/report-svc/status) )) -lt 5 ]] && grep -q "^OK" /run/report-svc/status'
}
pong_6380() { [[ "$(printf 'PING\r\nQUIT\r\n' | timeout 3 nc -q1 127.0.0.1 6380 | tr -d '\r')" == +PONG ]]; }
restarts() { [[ "$(systemctl show -p Restart --value minicache.service)" =~ ^(on-failure|always|on-abnormal)$ ]]; }

section "Investigation"
check_answer_is "file report-svc looks for" a06 file /var/lib/report-svc/feature-flags.json
check_answer_is "TCP port it connects to" a06 port 6380

section "Fix"
check "feature flags file exists" file_exists /var/lib/report-svc/feature-flags.json
check "minicache.service is active" service_active minicache.service
check "minicache.service is enabled" service_enabled minicache.service
check "minicache.service restarts on failure" restarts
check "something answers PING with +PONG on 127.0.0.1:6380" pong_6380
check "report-svc status is OK" status_ok

finish
