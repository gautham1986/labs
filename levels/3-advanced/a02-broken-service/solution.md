# a02 · Solution

The four root causes, in the order you hit them:

1. `User=payment` - typo, the account is `payments` -> `status=217/USER`
2. `ExecStart=/usr/bin/python` - only `python3` exists -> `status=203/EXEC`
3. `/etc/payments/config.ini` is `600 root:root` -> app can't read it
4. a leftover `old-payments` process holds port 8090 -> "Address already in use"

```bash
systemctl status payments --no-pager || true
journalctl -u payments -n 20 --no-pager || true

# 1 + 2: fix the unit
sudo sed -i -e 's/^User=payment$/User=payments/' \
            -e 's|^ExecStart=/usr/bin/python |ExecStart=/usr/bin/python3 |' \
            /etc/systemd/system/payments.service
sudo systemctl daemon-reload

# 3: group-readable config, still private from everyone else
sudo chown root:payments /etc/payments/config.ini
sudo chmod 640 /etc/payments/config.ini
sudo -u payments cat /etc/payments/config.ini > /dev/null && echo "payments can read config"

# 4: who holds the port?
sudo ss -tlnp 'sport = :8090'
sudo pkill -x old-payments

sudo systemctl reset-failed payments
sudo systemctl enable --now payments
sleep 2; curl -s localhost:8090/health
```

## Why

- Each layer has its own failure signature: systemd setup (`217/USER`, `203/EXEC`, `200/CHDIR`...)
  happens *before* your code runs; app errors come after. The status line tells you which layer.
- Fix permissions with the narrowest grant (group read), never `chmod 644`/`777` on secrets.
- "Address already in use" is almost always an old instance, a different service, or a socket
  unit. `ss -tlnp` names it.
