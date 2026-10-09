# e02 · Observability: custom metrics for Prometheus

**Level:** Expert · **Time:** ~60 min · **Needs:** systemd, prometheus-node-exporter

## Scenario

The team runs Prometheus with `node_exporter` everywhere. You want a few host-specific
metrics that node_exporter doesn't provide, without writing a Go exporter. The standard trick:
node_exporter's **textfile collector** reads `*.prom` files from
`/var/lib/prometheus/node-exporter/` and serves them alongside its own metrics.

## Tasks

1. Write `/usr/local/bin/lab-metrics` that writes **`/var/lib/prometheus/node-exporter/lab.prom`**
   in the Prometheus text format, **atomically** (write a temp file in the same directory, then
   `mv` - Prometheus must never scrape a half-written file). Every metric needs `# HELP` and
   `# TYPE ... gauge` lines:

   | metric | value |
   |---|---|
   | `lab_disk_used_ratio{mountpoint="/"}` | used / (used + available) for `/`, 0..1 (what `df` shows as Use%) |
   | `lab_load1` | 1-minute load average |
   | `lab_memory_available_bytes` | `MemAvailable` from `/proc/meminfo`, in **bytes** |
   | `lab_systemd_unit_active{unit="cron.service"}` | 1 if active, else 0 - also for `ssh.service` |
   | `lab_tcp_listeners` | number of listening TCP sockets |
   | `lab_metrics_last_run_timestamp_seconds` | Unix time of this run |

2. Run it every **30 seconds** with `lab-metrics.service` (oneshot) + `lab-metrics.timer`.
   (Timers are lazy by default - read about `AccuracySec=`.)
3. Enable and start `prometheus-node-exporter` and confirm your metrics appear at
   `curl -s localhost:9100/metrics | grep ^lab_`.
4. Write a Prometheus alerting rule file `~/answers/e02-alerts.yml` with an alert
   `RootDiskAlmostFull` that fires when `lab_disk_used_ratio{mountpoint="/"}` is above **0.9**
   **for 10 minutes**.

## Commands to learn

`/proc/loadavg` `/proc/meminfo` `df -P` `ss -Htln` `systemctl is-active` `mktemp -p DIR` `mv`
`systemd-analyze calendar` `systemctl list-timers` `curl localhost:9100/metrics`
Prometheus docs: *Exposition formats*, *Alerting rules*, *textfile collector*

## Done when

`lab check e02` passes. The checker runs your script itself (stopping and starting `cron`
in between) and validates the output format.

## Explore (not graded)

- Install Prometheus (`apt install prometheus`) and scrape node_exporter. Graph
  `lab_disk_used_ratio` and `node_filesystem_avail_bytes`.
- Why is "disk > 90%" a weak alert? Write `predict_linear(node_filesystem_avail_bytes[6h], 24*3600) < 0`
  instead - "disk will be full within 24h".
- Counter vs gauge: which type would "number of times lab-metrics ran" be? What does `rate()` need?
