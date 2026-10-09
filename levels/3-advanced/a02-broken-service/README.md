# a02 · The service that won't start

**Level:** Advanced · **Time:** ~40 min · **Needs:** systemd

## Scenario

🚨 *"payments.service is down after last night's maintenance. The on-call before you tried
restarting it a few times and gave up."*

The unit file is `/etc/systemd/system/payments.service`. The app should answer on port
**8090** (`curl localhost:8090/health`). There is **more than one** problem - each fix will
reveal the next error. Read the errors, don't guess.

## Tasks

1. Get `payments.service` **running** and answering on `:8090/health`, running as the
   **`payments`** user (it already exists).
2. Make sure it **starts on boot**.
3. Don't "fix" security by opening things up: `/etc/payments/config.ini` holds secrets and must
   **not** be world-readable. The `payments` user needs to read it, though.
4. Keep notes of each root cause as you go - in real life they become the incident timeline.

## Commands to learn

`systemctl status UNIT` `journalctl -u UNIT -e` `journalctl -u UNIT -b -p warning`
`systemctl cat` `systemctl edit --full` `systemctl daemon-reload` `systemctl reset-failed`
`systemd-analyze verify` `ss -tlnp` `namei -l /path` `sudo -u USER cat FILE` `id`
Exit codes in `status=`: `203/EXEC`, `217/USER`, `1/FAILURE` ... (`man systemd.exec`, "Process Exit Codes")

## Done when

`lab check a02` passes.

## Explore (not graded)

- After a few quick failures systemd says "start request repeated too quickly". Find
  `StartLimitIntervalSec=` / `StartLimitBurst=` in `man systemd.unit`.
- `namei -l /etc/payments/config.ini` shows permissions along the whole path. Why does the
  directory's `x` bit matter?
- Use `systemd-run --uid=payments --pty bash` (or `sudo -u payments -s`) to reproduce
  permission problems exactly as the service sees them.
