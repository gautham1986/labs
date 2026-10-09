#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
U=flaky-api.service
RB=$LAB_ANSWERS/e07-runbook.md

prop() { systemctl show -p "$1" --value "$U"; }
dropin() { ls /etc/systemd/system/$U.d/*.conf >/dev/null 2>&1; }
healthy() { curl -fsS -m 2 -o /dev/null localhost:7700/health; }
mainpid() { prop MainPID; }
recovers_from() {  # recovers_from <crash|hang> <seconds>
  local before; before=$(mainpid)
  [[ "$before" -gt 0 ]] && healthy || return 1
  touch "/run/flaky/$1"
  curl -s -m 2 -o /dev/null localhost:7700/health   # trigger it
  local deadline=$((SECONDS + $2)) now
  while (( SECONDS < deadline )); do
    now=$(mainpid)
    [[ "$now" -gt 0 && "$now" != "$before" ]] && healthy && return 0
    sleep 1
  done
  return 1
}
logged_restart() { journalctl -t flaky-health --since '-10min' -o cat --no-pager | grep -qi 'restart'; }
rb_section() { grep -Eiq "^#+[[:space:]]*$1" "$RB"; }
rb_words() { (( $(sed 's/<!--.*-->//g' "$RB" | wc -w) >= 100 )); }

section "Restart policy (drop-in)"
check "a drop-in exists in /etc/systemd/system/$U.d/" dropin
check "Restart=always" cmd_output_is always prop Restart
check "RestartSec=1s" cmd_output_is 1s prop RestartUSec
check "StartLimitIntervalSec=60 (in [Unit])" cmd_output_is 1min prop StartLimitIntervalUSec
check "StartLimitBurst=5" cmd_output_is 5 prop StartLimitBurst

section "Health check"
check "/usr/local/bin/flaky-healthcheck is executable" is_executable /usr/local/bin/flaky-healthcheck
check "flaky-health.timer is active" service_active flaky-health.timer
check "flaky-health.timer is enabled" service_enabled flaky-health.timer
check "flaky-api is healthy right now" healthy

section "Chaos test (this takes up to a minute)"
systemctl reset-failed $U >/dev/null 2>&1
check "recovers from a crash within 10s" recovers_from crash 10
check "recovers from a hang within 45s" recovers_from hang 45
check "health check logged the restart (journalctl -t flaky-health)" logged_restart

section "Runbook (~/answers/e07-runbook.md)"
if [[ -s "$RB" ]]; then
  for s in Symptoms Checks Fix Escalation; do check "has a '$s' section" rb_section "$s"; done
  check "at least 100 words" rb_words
else
  check "runbook written" false
fi

finish
