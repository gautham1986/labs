# e07 · Solution

```bash
# 1. restart policy via drop-in
sudo mkdir -p /etc/systemd/system/flaky-api.service.d
sudo tee /etc/systemd/system/flaky-api.service.d/restart.conf > /dev/null <<'UNIT'
[Unit]
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
Restart=always
RestartSec=1
UNIT

# 2. health check that catches hangs
sudo tee /usr/local/bin/flaky-healthcheck > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
# flaky-healthcheck - restart flaky-api after 2 consecutive failed health checks
set -u
URL=http://127.0.0.1:7700/health
STATE=/run/flaky-health.failures
THRESHOLD=2

fails=$(cat "$STATE" 2>/dev/null || echo 0)
if curl -fsS -m 3 -o /dev/null "$URL"; then
  echo 0 > "$STATE"
  exit 0
fi
fails=$((fails + 1))
echo "$fails" > "$STATE"
logger -t flaky-health -p user.warning "health check failed ($fails/$THRESHOLD)"
if (( fails >= THRESHOLD )); then
  logger -t flaky-health -p user.err "restarting flaky-api after $fails consecutive failed health checks"
  systemctl restart flaky-api
  echo 0 > "$STATE"
fi
SCRIPT
sudo chmod 755 /usr/local/bin/flaky-healthcheck

sudo tee /etc/systemd/system/flaky-health.service > /dev/null <<'UNIT'
[Unit]
Description=Health check for flaky-api

[Service]
Type=oneshot
ExecStart=/usr/local/bin/flaky-healthcheck
UNIT
sudo tee /etc/systemd/system/flaky-health.timer > /dev/null <<'UNIT'
[Unit]
Description=Run the flaky-api health check every 10s

[Timer]
OnBootSec=10s
OnUnitActiveSec=10s
AccuracySec=1s

[Install]
WantedBy=timers.target
UNIT
sudo systemctl daemon-reload
sudo systemctl restart flaky-api
sudo systemctl enable --now flaky-health.timer

# 3. runbook
cat > ~/answers/e07-runbook.md <<'MD'
# Runbook: flaky-api

## Symptoms
Alerts for 5xx/timeouts on port 7700, `flaky-health` warnings in the journal, NRestarts climbing.

## Checks
1. `systemctl status flaky-api` - is it active? How long since the last start?
2. `systemctl show -p NRestarts flaky-api` - how often has systemd restarted it today?
3. `journalctl -t flaky-health --since -1h` - how often did the health check restart it?
4. `curl -m 3 -s localhost:7700/health` - does it answer right now?

## Fix
- If it is in `failed` state because of the start limit: read `journalctl -u flaky-api -n 50`,
  fix the cause, then `systemctl reset-failed flaky-api && systemctl start flaky-api`.
- If it hangs and the health check is not acting: check `systemctl list-timers flaky-health.timer`
  and restart the timer. Restart the API by hand as a stopgap.

## Escalation
More than 3 automatic restarts in an hour, or the start limit tripped: page the owning team,
attach the journal output, and open an incident. Self-healing is a bandage, not a fix.
MD
```

## Why

- `Restart=` handles **crashes**; only an external probe (or `WatchdogSec=`) detects **hangs**.
- Requiring consecutive failures avoids restarting on a single slow request (flapping).
- Start limits stop a crash loop from hammering dependencies forever - and make the failure
  visible (`failed` state) instead of hiding it.
