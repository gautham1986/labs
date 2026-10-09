`sudo systemctl edit flaky-api` and add:
```
[Unit]
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
Restart=always
RestartSec=1
```
Start-limit settings live in `[Unit]`, not `[Service]` - a very common mistake.
---
Health check script skeleton:
```
#!/usr/bin/env bash
set -u
state=/run/flaky-health.failures
fails=$(cat "$state" 2>/dev/null || echo 0)
if curl -fsS -m 3 -o /dev/null http://127.0.0.1:7700/health; then
  echo 0 > "$state"
else
  fails=$((fails + 1)); echo "$fails" > "$state"
  if (( fails >= 2 )); then ... fi
fi
```
---
Timer: `OnBootSec=10s`, `OnUnitActiveSec=10s`, `AccuracySec=1s`. Without `AccuracySec`, systemd
may run it up to a minute late and the hang test will time out.
---
Runbook sections as markdown headings: `## Symptoms`, `## Checks`, `## Fix`, `## Escalation`.
Write it for a tired human at 3am: concrete commands, what "good" looks like, when to escalate.
