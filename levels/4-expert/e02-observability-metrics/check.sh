#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
source "$LAB_ROOT/lib/check.sh"
S=/usr/local/bin/lab-metrics
F=/var/lib/prometheus/node-exporter/lab.prom
ALERTS=$LAB_ANSWERS/e02-alerts.yml

val() {  # val <metric-with-labels-regex> -> value from the file
  awk -v m="$1" '$0 !~ /^#/ && $1 ~ "^" m "$" { print $2; exit }' "$F"
}
runs_ok() { "$S" && [[ -s "$F" ]]; }
format_ok() { python3 "$LAB_DIR/promlint.py" "$F"; }
disk_ok()   { within "$(val 'lab_disk_used_ratio\{mountpoint="/"\}')" "$(df -P / | awk 'NR == 2 { printf "%.4f", $3 / ($3 + $4) }')" 0.02; }
load_ok()   { within "$(val lab_load1)" "$(cut -d' ' -f1 /proc/loadavg)" 1.0; }
mem_ok()    { local want; want=$(awk '/^MemAvailable:/ { print $2 * 1024 }' /proc/meminfo); within "$(val lab_memory_available_bytes)" "$want" "$(awk -v w="$want" 'BEGIN { print w * 0.25 }')"; }
lsn_ok()    { within "$(val lab_tcp_listeners)" "$(ss -Htln | wc -l)" 2; }
ts_ok()     { within "$(val lab_metrics_last_run_timestamp_seconds)" "$(date +%s)" 10; }
unit_tracks_state() {
  systemctl stop cron; "$S"; local down; down=$(val 'lab_systemd_unit_active\{unit="cron.service"\}')
  systemctl start cron; "$S"; local up; up=$(val 'lab_systemd_unit_active\{unit="cron.service"\}')
  [[ "$down" == 0 && "$up" == 1 && "$(val 'lab_systemd_unit_active\{unit="ssh.service"\}')" =~ ^[01]$ ]]
}
atomic_hint() { grep -Eq '\bmv\b' "$S"; }
fresh() { (( $(date +%s) - $(stat -c %Y "$F") < 75 )); }
timer_fast() { [[ "$(systemctl show -p AccuracyUSec --value lab-metrics.timer)" =~ ^([0-9]+ms|1s|[0-9]+us)$ ]]; }
served() { curl -fsS -m 5 localhost:9100/metrics | grep -q '^lab_tcp_listeners '; }
alert_ok() {
  python3 - "$ALERTS" <<'PY'
import sys, yaml
doc = yaml.safe_load(open(sys.argv[1]))
rules = [r for g in doc["groups"] for r in g["rules"]]
r = next(r for r in rules if r.get("alert") == "RootDiskAlmostFull")
expr = r["expr"].replace(" ", "")
assert "lab_disk_used_ratio" in expr and '>0.9' in expr, expr
assert str(r.get("for")) in ("10m", "600s"), r.get("for")
PY
}

section "Exporter script"
check "$S runs successfully and writes $F" runs_ok
check "output is valid exposition format (HELP/TYPE for every metric)" format_ok
check "lab_disk_used_ratio{mountpoint=\"/\"} matches df" disk_ok
check "lab_load1 matches /proc/loadavg" load_ok
check "lab_memory_available_bytes matches MemAvailable (bytes)" mem_ok
check "lab_tcp_listeners matches ss" lsn_ok
check "lab_metrics_last_run_timestamp_seconds is now" ts_ok
check "lab_systemd_unit_active follows cron.service stop/start" unit_tracks_state
check "writes atomically (temp file + mv)" atomic_hint

section "Scheduling"
check "lab-metrics.timer is active" service_active lab-metrics.timer
check "lab-metrics.timer is enabled" service_enabled lab-metrics.timer
check "timer has AccuracySec of 1s or less" timer_fast
check "lab.prom is fresh (< 75s old)" fresh

section "Serving & alerting"
check "prometheus-node-exporter is active" service_active prometheus-node-exporter
check "your metrics are served on :9100/metrics" served
check "e02-alerts.yml defines RootDiskAlmostFull (> 0.9 for 10m)" alert_ok

finish
