System user: `useradd --system --no-create-home --shell /usr/sbin/nologin inventory`
---
A unit has three sections. Skeleton:
```
[Unit]
Description=...
After=network-online.target
Wants=network-online.target

[Service]
User=...
Environment=PORT=8081
ExecStart=...
Restart=...
RestartSec=...

[Install]
WantedBy=multi-user.target
```
---
After creating or changing a unit file, always `sudo systemctl daemon-reload`.
`sudo systemctl enable --now inventory` enables and starts in one go.
---
If it won't start: `systemctl status inventory` shows the last log lines;
`journalctl -u inventory -e` shows more. `systemd-analyze verify /etc/systemd/system/inventory.service`
catches typos.
