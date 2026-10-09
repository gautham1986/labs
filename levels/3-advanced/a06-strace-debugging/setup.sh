#!/usr/bin/env bash
# a06 setup: a degraded "black box" service and an unconfigured dependency
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
need_cmd strace
prepare_answers
bash "$LAB_DIR/cleanup.sh"

install -D -m 0755 "$LAB_DIR/report-svc.py" /opt/lab/a06/report-svc.py
install -D -m 0755 "$LAB_DIR/minicache.py" /opt/lab/a06/bin/minicache
cat > /opt/lab/a06/OPS-NOTES.txt <<'NOTES'
report-svc operations notes (rev 3, 2024)
=========================================
- Feature flags are read from a JSON file at startup and every few seconds.
  Reports only run when the flag "reports_enabled" is true, e.g.  {"reports_enabled": true}
  (The file location changed in v2.0 - TODO: update this doc.)
- report-svc needs the cache. The cache used to run on the default port.
- Status is written to /run/report-svc/status.
NOTES

cat > /etc/systemd/system/report-svc.service <<'UNIT'
[Unit]
Description=Report service (lab a06)
[Service]
ExecStart=/usr/bin/python3 /opt/lab/a06/report-svc.py
RuntimeDirectory=report-svc
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now report-svc >/dev/null 2>&1
sleep 2
cat /run/report-svc/status
