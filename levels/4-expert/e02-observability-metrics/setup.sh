#!/usr/bin/env bash
# e02 setup: node_exporter installed but off, textfile dir empty
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"
if ! command -v prometheus-node-exporter >/dev/null; then
  warn "prometheus-node-exporter not installed - trying apt"
  DEBIAN_FRONTEND=noninteractive apt-get install -y -q prometheus-node-exporter >/dev/null || die "install prometheus-node-exporter first"
  systemctl disable --now prometheus-node-exporter >/dev/null 2>&1
fi
mkdir -p /var/lib/prometheus/node-exporter
systemctl enable --now cron ssh >/dev/null 2>&1
info "node_exporter reads *.prom files from /var/lib/prometheus/node-exporter/"
