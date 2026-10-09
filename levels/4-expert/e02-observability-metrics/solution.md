# e02 · Solution

```bash
sudo tee /usr/local/bin/lab-metrics > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
# lab-metrics - write host metrics for node_exporter's textfile collector (atomically)
set -euo pipefail
DIR=${TEXTFILE_DIR:-/var/lib/prometheus/node-exporter}
OUT=$DIR/lab.prom

gauge() {  # gauge <name> <help> <value> [labels]
  printf '# HELP %s %s\n# TYPE %s gauge\n%s%s %s\n' "$1" "$2" "$1" "$1" "${4:-}" "$3"
}
unit_active() { systemctl is-active --quiet "$1" && echo 1 || echo 0; }

disk_ratio=$(df -P / | awk 'NR == 2 { printf "%.4f", $3 / ($3 + $4) }')
load1=$(cut -d' ' -f1 /proc/loadavg)
mem_avail=$(awk '/^MemAvailable:/ { printf "%d", $2 * 1024 }' /proc/meminfo)
listeners=$(ss -Htln | wc -l)

mkdir -p "$DIR"
tmp=$(mktemp -p "$DIR" .lab.prom.XXXXXX)
trap 'rm -f "$tmp"' EXIT
{
  gauge lab_disk_used_ratio "Used fraction of the filesystem (like df Use%)." "$disk_ratio" '{mountpoint="/"}'
  gauge lab_load1 "1-minute load average." "$load1"
  gauge lab_memory_available_bytes "MemAvailable from /proc/meminfo in bytes." "$mem_avail"
  echo '# HELP lab_systemd_unit_active 1 if the systemd unit is active.'
  echo '# TYPE lab_systemd_unit_active gauge'
  for u in cron.service ssh.service; do
    echo "lab_systemd_unit_active{unit=\"$u\"} $(unit_active "$u")"
  done
  gauge lab_tcp_listeners "Number of listening TCP sockets." "$listeners"
  gauge lab_metrics_last_run_timestamp_seconds "Unix time of the last successful run." "$(date +%s)"
} > "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$OUT"
trap - EXIT
SCRIPT
sudo chmod 755 /usr/local/bin/lab-metrics
sudo lab-metrics && cat /var/lib/prometheus/node-exporter/lab.prom

sudo tee /etc/systemd/system/lab-metrics.service > /dev/null <<'UNIT'
[Unit]
Description=Write lab textfile metrics

[Service]
Type=oneshot
ExecStart=/usr/local/bin/lab-metrics
UNIT
sudo tee /etc/systemd/system/lab-metrics.timer > /dev/null <<'UNIT'
[Unit]
Description=Write lab textfile metrics every 30s

[Timer]
OnBootSec=10s
OnUnitActiveSec=30s
AccuracySec=1s

[Install]
WantedBy=timers.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable --now lab-metrics.timer
sudo systemctl start lab-metrics.service

sudo systemctl enable --now prometheus-node-exporter
sleep 2; curl -s localhost:9100/metrics | grep '^lab_'

cat > ~/answers/e02-alerts.yml <<'YAML'
groups:
  - name: lab-host
    rules:
      - alert: RootDiskAlmostFull
        expr: lab_disk_used_ratio{mountpoint="/"} > 0.9
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Root filesystem above 90% on {{ $labels.instance }}"
YAML
```

## Why

- The textfile collector turns any script into an exporter - perfect for cron-ish facts
  (backup age, certificate expiry, package updates pending).
- Atomic writes matter: a scrape during a partial write gives broken or missing series and
  false alerts. Same filesystem + `rename()` = atomic.
- A `*_last_run_timestamp_seconds` metric lets you alert on the collector itself being dead:
  `time() - lab_metrics_last_run_timestamp_seconds > 300`.
- `for: 10m` prevents paging on short spikes.
