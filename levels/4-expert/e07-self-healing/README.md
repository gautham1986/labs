# e07 · Self-healing services: restarts, health checks & runbooks

**Level:** Expert · **Time:** ~60 min · **Needs:** systemd

## Scenario

`flaky-api.service` (port **7700**) has two failure modes nobody has fixed yet:

1. it sometimes **crashes** (process exits) - and stays down until someone notices;
2. it sometimes **hangs** - the process is alive, systemd thinks all is well, but it stops
   answering requests. Restart policies can't see this.

You can't fix the code today. Make the *system* heal it, and write the runbook for when
self-healing isn't enough.

## Tasks

1. With a **drop-in** for `flaky-api.service`: restart it **always**, **1 s** after it dies, but give
   up if it restarts more than **5 times in 60 s** (so a crash-looping service doesn't flap forever).
2. Write `/usr/local/bin/flaky-healthcheck` and run it every **10 s** with
   `flaky-health.service` + `flaky-health.timer`. It must:
   - request `http://127.0.0.1:7700/health` with a **3 s** timeout;
   - remember consecutive failures between runs (e.g. a counter file under `/run/` or `/var/lib/`);
   - after **2 consecutive** failures: `systemctl restart flaky-api`, reset the counter, and log
     a message with tag **`flaky-health`** to the journal (`logger -t flaky-health ...`);
   - reset the counter on success.
3. Write a runbook `~/answers/e07-runbook.md` for the on-call engineer with the sections
   **Symptoms**, **Checks**, **Fix** and **Escalation** (≥ 100 words of your own).

To trigger failures yourself: `sudo touch /run/flaky/crash` or `sudo touch /run/flaky/hang`,
then send a request (`curl -m 2 localhost:7700/health`).

## Commands to learn

`systemctl edit` `Restart=` `RestartSec=` `StartLimitIntervalSec=` / `StartLimitBurst=` (in `[Unit]`!)
`systemctl show -p NRestarts,MainPID` `systemctl reset-failed` `OnUnitActiveSec=` `AccuracySec=`
`curl -fsS -m 3` `logger -t TAG` `journalctl -t TAG` `WatchdogSec=` + `sd_notify` (explore)

## Done when

`lab check e07` passes. The checker crashes the service (expects recovery in ≤ 10 s), then hangs it
(expects recovery in ≤ 45 s), and looks for your `flaky-health` log line.

## Explore (not graded)

- `WatchdogSec=` is the in-process alternative: the app pings systemd (`sd_notify("WATCHDOG=1")`)
  and systemd kills it if the pings stop. What does the app need to do to support it?
- Kubernetes has the same split: `restartPolicy` (crash) vs `livenessProbe` (hang). What goes wrong
  if a liveness probe checks a *dependency* (like the database)?
- Self-healing hides problems. Make restarts visible: alert on `NRestarts` increasing, or on the
  number of `flaky-health` log lines per hour.
