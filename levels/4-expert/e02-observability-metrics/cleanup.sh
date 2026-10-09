#!/usr/bin/env bash
source "$LAB_ROOT/lib/common.sh"
remove_unit lab-metrics.timer lab-metrics.service
rm -f /usr/local/bin/lab-metrics /var/lib/prometheus/node-exporter/lab.prom
has_systemd && systemctl disable --now prometheus-node-exporter >/dev/null 2>&1
exit 0
