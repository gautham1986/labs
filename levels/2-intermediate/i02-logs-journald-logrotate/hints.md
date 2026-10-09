`journalctl -u orders-worker -p err` shows only error-priority (and worse) messages.
Add `--no-pager` or `-o cat` for cleaner output.
---
`journalctl -t orders-audit` filters by syslog identifier - the `-t` tag that `logger` used.
---
Drop-in: `sudo mkdir -p /etc/systemd/journald.conf.d` and a file like `persistent.conf`:
```
[Journal]
Storage=persistent
SystemMaxUse=200M
```
Then `sudo systemctl restart systemd-journald`. Check with `journalctl --disk-usage`.
---
logrotate directives, one per line inside `/var/log/orders/*.log { ... }`:
`daily`, `rotate 7`, `compress`, `delaycompress`, `missingok`, `notifempty`, `create 0640 root adm`.
Test with `sudo logrotate -d /etc/logrotate.d/orders` (dry run, verbose).
---
`logger -t lab-i02 -p user.warning "hello from i02"`
