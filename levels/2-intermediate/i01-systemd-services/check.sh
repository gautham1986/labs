#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
U=inventory.service

system_user() { local u; u=$(user_uid inventory); [[ -n "$u" ]] && (( u < 1000 )) && [[ "$(getent passwd inventory | cut -d: -f7)" =~ (nologin|false)$ ]]; }
restart_sec_2() { [[ "$(systemctl show -p RestartUSec --value $U)" =~ ^2(s|\.0+s)?$ ]]; }
health_as_inventory() { curl -fsS -m 3 localhost:8081/health | grep -q '"user": "inventory"'; }
survives_kill() {
  local before
  before=$(systemctl show -p MainPID --value $U); [[ "$before" -gt 0 ]] || return 1
  kill -9 "$before"
  wait_for 15 bash -c "p=\$(systemctl show -p MainPID --value $U); [[ \$p -gt 0 && \$p != $before ]] && curl -fs -m 2 localhost:8081/health"
}

section "User & unit"
check "system user 'inventory' exists with no login shell" system_user
check "unit file /etc/systemd/system/inventory.service exists" file_exists /etc/systemd/system/$U
check "runs as User=inventory" unit_prop_is $U User inventory
check "Restart=on-failure" unit_prop_is $U Restart on-failure
check "RestartSec=2" restart_sec_2
check "WantedBy multi-user.target" file_contains /etc/systemd/system/$U '^WantedBy=.*multi-user\.target'

section "Running"
check "service is enabled (starts on boot)" service_enabled $U
check "service is active" service_active $U
check "GET localhost:8081/health answers, served by user inventory" health_as_inventory
check "systemd restarts it after kill -9" survives_kill

finish
