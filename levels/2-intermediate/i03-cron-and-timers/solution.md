# i03 · Solution

```bash
# 1. system cron file (note the user column)
echo '*/15 * * * * root /opt/lab/i03/cleanup.sh' | sudo tee /etc/cron.d/i03-cleanup
sudo chmod 644 /etc/cron.d/i03-cleanup

# 2. user crontab (no user column)
{ crontab -l 2>/dev/null || true; echo '30 2 * * 1-5 /opt/lab/i03/report.sh'; } | crontab -
crontab -l

# 3. systemd service + timer
sudo tee /etc/systemd/system/i03-backup.service > /dev/null <<'UNIT'
[Unit]
Description=Hourly backup (lab i03)

[Service]
Type=oneshot
ExecStart=/opt/lab/i03/backup.sh
UNIT

sudo tee /etc/systemd/system/i03-backup.timer > /dev/null <<'UNIT'
[Unit]
Description=Run i03-backup hourly

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now i03-backup.timer
systemctl list-timers i03-backup.timer --no-pager

# 4. run once by hand, through systemd
sudo systemctl start i03-backup.service
journalctl -u i03-backup.service -n 5 --no-pager
cat /var/backups/i03/last-run
```

## Why

- `/etc/cron.d` files are managed by config management (Ansible/Puppet) - one file per job,
  no editing shared crontabs.
- Timers vs cron: logs in the journal, `Persistent=` catches up after downtime,
  `RandomizedDelaySec=` avoids every server hitting the backup target at :00, and
  `systemctl list-timers` shows the next run.
- Always test scheduled jobs *in their real execution context* - cron/systemd environments
  differ from your interactive shell.
