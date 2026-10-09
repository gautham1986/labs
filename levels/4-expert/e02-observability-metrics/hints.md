Build the file in a variable or a heredoc, write it to a temp file *in the target directory*
(same filesystem, so `mv` is an atomic rename), then move it:
```
tmp=$(mktemp -p /var/lib/prometheus/node-exporter .lab.prom.XXXXXX)
{ echo '# HELP lab_load1 1-minute load average'; echo '# TYPE lab_load1 gauge'; echo "lab_load1 $load1"; ...; } > "$tmp"
chmod 644 "$tmp"; mv "$tmp" /var/lib/prometheus/node-exporter/lab.prom
```
---
Disk ratio: `df -P / | awk 'NR==2 {printf "%.4f", $3 / ($3 + $4)}'`.
Load: `cut -d' ' -f1 /proc/loadavg`. Memory: `awk '/^MemAvailable:/ {print $2 * 1024}' /proc/meminfo`.
Listeners: `ss -Htln | wc -l`. Unit: `systemctl is-active --quiet cron.service && echo 1 || echo 0`.
---
Timer: `OnBootSec=10s`, `OnUnitActiveSec=30s` and `AccuracySec=1s` in `[Timer]`. Without
`AccuracySec`, systemd may delay the run by up to a minute to batch wakeups.
---
Alert rule file:
```yaml
groups:
  - name: lab
    rules:
      - alert: RootDiskAlmostFull
        expr: lab_disk_used_ratio{mountpoint="/"} > 0.9
        for: 10m
        labels: {severity: warning}
        annotations: {summary: "Root disk above 90% on {{ $labels.instance }}"}
```
