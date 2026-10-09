# i01 · Solution

```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin inventory

sudo tee /etc/systemd/system/inventory.service > /dev/null <<'UNIT'
[Unit]
Description=Inventory API
Documentation=https://wiki.example.com/inventory
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=inventory
Group=inventory
Environment=PORT=8081
ExecStart=/usr/bin/python3 /opt/lab/i01/inventory.py --name inventory
Restart=on-failure
RestartSec=2

# Hardening (optional but good habit)
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=yes

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now inventory
systemctl status inventory --no-pager
sleep 1; curl -s localhost:8081/health
```

## Why

- `Restart=on-failure` restarts on non-zero exit, crash or `kill -9`, but not on a clean
  `systemctl stop`. `Restart=always` also restarts after a clean exit.
- `Type=simple` (default) means "the process in ExecStart *is* the service, don't fork".
- Running as a dedicated unprivileged user limits damage if the app is compromised.
- Everything the app prints to stdout/stderr lands in the journal - no log file wiring needed.
