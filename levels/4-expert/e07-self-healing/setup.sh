#!/usr/bin/env bash
# e07 setup: a service that crashes and hangs on demand, with no restart policy
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"
install_app /opt/lab/e07/flaky.py
cat > /etc/systemd/system/flaky-api.service <<'UNIT'
[Unit]
Description=Flaky API (lab e07)

[Service]
ExecStart=/usr/bin/python3 /opt/lab/e07/flaky.py --name flaky-api --port 7700 --single-thread --trigger-dir /run/flaky
RuntimeDirectory=flaky
RuntimeDirectoryPreserve=yes

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now flaky-api >/dev/null 2>&1
wait_for 10 curl -fsS -m 1 localhost:7700/health && info "flaky-api is up on :7700 (for now)"
