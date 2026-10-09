#!/usr/bin/env bash
# a04 setup: an API that needs 3000 fds, a batch user, default kernel settings
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"

id batch >/dev/null 2>&1 || useradd -m -s /bin/bash batch
install -D -m 0755 "$LAB_DIR/api.py" /opt/lab/a04/api.py
cat > /etc/systemd/system/lab-a04-api.service <<'UNIT'
[Unit]
Description=Connection-heavy API (lab a04)

[Service]
ExecStart=/usr/bin/python3 /opt/lab/a04/api.py
RuntimeDirectory=lab-a04
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now lab-a04-api >/dev/null 2>&1
sleep 2
cat /run/lab-a04/status 2>/dev/null
