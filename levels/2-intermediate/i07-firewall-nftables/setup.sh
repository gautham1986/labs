#!/usr/bin/env bash
# i07 setup: three services listening on all interfaces, no firewall
source "$LAB_ROOT/lib/common.sh"
need_root
need_cmd nft python3 nc
prepare_answers
bash "$LAB_DIR/cleanup.sh"

[[ -f /etc/nftables.conf.lab-orig ]] || cp /etc/nftables.conf /etc/nftables.conf.lab-orig 2>/dev/null || true
install_app /opt/lab/i07/app.py
clone_bin nc /opt/lab/i07/bin/fake-postgres
spawn i07-web python3 /opt/lab/i07/app.py --name web --port 8080
spawn i07-exporter python3 /opt/lab/i07/app.py --name node-exporter --port 9100
spawn i07-db /opt/lab/i07/bin/fake-postgres -dlk 0.0.0.0 5432
sleep 1
ss -tlnp | grep -E ':(8080|9100|5432)\b'
info "Everything is reachable from anywhere. Time to fix that."
