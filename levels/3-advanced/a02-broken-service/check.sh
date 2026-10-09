#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
CFG=/etc/payments/config.ini

app_healthy() { curl -fsS -m 3 localhost:8090/health | grep -q '"service": "payments"'; }
runs_as_payments() {
  local pid; pid=$(systemctl show -p MainPID --value payments.service)
  [[ "$pid" -gt 0 && "$(ps -o user= -p "$pid")" == payments ]]
}
not_world_readable() { (( ($(stat -c '%a' "$CFG") % 10) == 0 )); }
payments_can_read() { su -s /bin/sh payments -c "cat $CFG" >/dev/null; }

section "Service"
check "payments.service is active" service_active payments.service
check "payments.service is enabled" service_enabled payments.service
check "main process runs as user payments" runs_as_payments
check "GET :8090/health is answered by the payments app" app_healthy
check "the stale old-payments process is gone" process_absent old-payments

section "Secrets"
check "config.ini is not world-readable" not_world_readable
check "the payments user can read config.ini" payments_can_read

finish
