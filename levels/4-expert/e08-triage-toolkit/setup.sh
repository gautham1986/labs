#!/usr/bin/env bash
# e08 setup: leave some real problems lying around for the triage tool to find
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"

cat > /etc/systemd/system/lab-e08-broken.service <<'UNIT'
[Unit]
Description=A service that always fails (lab e08)
[Service]
Type=oneshot
ExecStart=/bin/false
UNIT
systemctl daemon-reload
systemctl start lab-e08-broken.service >/dev/null 2>&1

mkdir -p /srv/e08
mount -t tmpfs -o size=32M e08-data /srv/e08 || die "could not mount tmpfs"
head -c 31M /dev/zero > /srv/e08/fill.bin
df -h /srv/e08 | tail -1
systemctl --failed --no-legend | head -3
