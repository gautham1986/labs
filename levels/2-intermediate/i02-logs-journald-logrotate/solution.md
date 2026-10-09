# i02 · Solution

```bash
# 1. failed payment: filter by priority
journalctl -u orders-worker -p err --no-pager
journalctl -u orders-worker -p err -o cat | grep -o 'ORD-[0-9]*' | tail -1 > ~/answers/i02-order.txt

# 2. audit log by syslog identifier
journalctl -t orders-audit -o cat
journalctl -t orders-audit -o cat | tail -1 | awk '{print $NF}' > ~/answers/i02-refund-user.txt

# 3. persistent journal via drop-in
sudo mkdir -p /etc/systemd/journald.conf.d
printf '[Journal]\nStorage=persistent\nSystemMaxUse=200M\n' | sudo tee /etc/systemd/journald.conf.d/persistent.conf
sudo systemctl restart systemd-journald
journalctl --disk-usage

# 4. logrotate
sudo tee /etc/logrotate.d/orders > /dev/null <<'CONF'
/var/log/orders/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
}
CONF
sudo logrotate -d /etc/logrotate.d/orders

# 5. write to the journal
logger -t lab-i02 -p user.warning "hello from i02"
journalctl -t lab-i02 -n 1
```

## Why

- Filtering by unit, priority and identifier beats grepping walls of text - and works the same
  on every systemd box.
- Drop-in files (`*.conf.d/`) survive package upgrades; editing the vendor file causes merge
  prompts and surprises.
- `delaycompress` keeps yesterday's file uncompressed, useful if a process still has it open.
- `create` makes a fresh log file after rotation; the app must reopen its log (usually via a
  signal in `postrotate`). `copytruncate` works for apps that can't reopen, but may lose lines.
