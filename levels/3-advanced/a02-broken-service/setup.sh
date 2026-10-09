#!/usr/bin/env bash
# a02 setup: a service with four stacked faults
source "$LAB_ROOT/lib/common.sh"
need_root
need_systemd
prepare_answers
bash "$LAB_DIR/cleanup.sh"

id payments >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin payments
install_app /opt/lab/a02/payments.py
mkdir -p /etc/payments
printf '[db]\nhost=10.0.3.4\npassword=s3cr3t-%s\n' "$RANDOM" > /etc/payments/config.ini
chown root:root /etc/payments/config.ini; chmod 600 /etc/payments/config.ini

cat > /etc/systemd/system/payments.service <<'UNIT'
[Unit]
Description=Payments API
After=network.target

[Service]
User=payment
ExecStart=/usr/bin/python /opt/lab/a02/payments.py --name payments --port 8090 --config /etc/payments/config.ini
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload

clone_bin nc /opt/lab/a02/bin/old-payments
spawn old-payments /opt/lab/a02/bin/old-payments -dlk 0.0.0.0 8090

# "the previous on-call tried restarting it a few times"
for _ in 1 2 3; do systemctl restart payments.service >/dev/null 2>&1; sleep 0.3; done
