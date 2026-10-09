# i03 · Scheduling: cron & systemd timers

**Level:** Intermediate · **Time:** ~30 min · **Needs:** systemd, cron

## Scenario

Three jobs need scheduling: a temp-file cleanup, a weekday report, and an hourly backup.
You'll do the first two with cron (still everywhere) and the backup with a systemd timer
(the modern way: logging, dependencies, and catch-up after downtime for free).

Scripts are ready in `/opt/lab/i03/`: `cleanup.sh`, `report.sh`, `backup.sh`.

## Tasks

1. **System cron:** run `/opt/lab/i03/cleanup.sh` **every 15 minutes** as **root**, using a file
   in `/etc/cron.d/` named `i03-cleanup`.
2. **User crontab:** in *your own* crontab, run `/opt/lab/i03/report.sh` at **02:30 on weekdays
   (Monday-Friday)** only.
3. **systemd timer:** create `i03-backup.service` (a oneshot running `/opt/lab/i03/backup.sh`) and
   `i03-backup.timer` that fires **hourly**, is **persistent** (runs missed jobs after downtime)
   and has a **randomized delay** of up to 5 minutes. Enable and start the timer.
4. Trigger the backup **once by hand** through systemd (not by running the script directly) so
   you know it works. It writes `/var/backups/i03/last-run`.

## Commands to learn

`crontab -e / -l / -u user` `/etc/cron.d/` format (has a *user* column!) `/etc/crontab`
`run-parts` `systemctl list-timers` `systemd-analyze calendar 'Mon..Fri 02:30'`
`systemctl start foo.service` `journalctl -u i03-backup` `man 5 crontab` `man systemd.timer`
Handy: [crontab.guru](https://crontab.guru)

## Done when

`lab check i03` passes.

## Explore (not graded)

- cron runs jobs with a tiny `PATH` and no profile. Write a cron job that calls `ss` without a full
  path and check `grep CRON /var/log/syslog` or `journalctl -u cron`. Where did its output go?
- `systemd-analyze calendar --iterations=5 hourly` - when exactly will your timer fire?
- What happens if a cron job takes longer than its interval? Look up `flock -n` to prevent overlap.
- `systemd-run --on-active=30s --unit=hello /usr/bin/touch /tmp/hello` - a one-off timer, no files.
