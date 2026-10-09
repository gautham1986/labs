cron fields: `minute hour day-of-month month day-of-week`. Every 15 minutes is `*/15 * * * *`.
Files in `/etc/cron.d/` have an extra **user** field before the command:
`*/15 * * * * root /opt/lab/i03/cleanup.sh`
---
cron ignores files in `/etc/cron.d/` whose names contain a dot, and the file must end with a
newline. Mode 644, owned by root.
---
Weekdays at 02:30: `30 2 * * 1-5 /opt/lab/i03/report.sh`. Edit your crontab with `crontab -e`
(no user field there!), or non-interactively: `{ crontab -l 2>/dev/null || true; echo '...'; } | crontab -`
---
Timer unit skeleton:
```
[Unit]
Description=...

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
```
The service needs `Type=oneshot` and no `[Install]` section - the timer starts it.
---
`sudo systemctl enable --now i03-backup.timer`, then run it once with
`sudo systemctl start i03-backup.service`.
