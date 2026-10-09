# a03 · The process that keeps coming back

**Level:** Advanced · **Time:** ~40 min · **Needs:** systemd, cron

## Scenario

🚨 *"lab: CPU saturated for 30 min."* The previous on-call killed the top process twice. It came
back both times within seconds. Treat it like a light-weight incident response: identify,
trace, find persistence, eradicate.

## Tasks

1. Identify the process burning CPU. Write its **name** to `~/answers/a03-burner.txt`.
   (Is it really a kernel worker? How can you tell?)
2. Killing it doesn't stick. Find the process that **respawns** it and write that process's
   **name** to `~/answers/a03-parent.txt`.
3. Something also **starts the respawner on a schedule**. Write the **full path** of that
   persistence file to `~/answers/a03-persistence.txt`.
4. **Eradicate** it: nothing running, persistence removed, binaries deleted - and it must stay
   gone.

## Commands to learn

`top` / `htop` (`F5` tree view) `ps -eo pid,ppid,user,pcpu,stat,lstart,cmd --sort=-pcpu`
`ps -ef --forest` `pstree -aps PID` `ls -l /proc/PID/exe` `cat /proc/PID/cmdline | tr '\0' ' '`
`ls -l /proc/PID/cwd` `/etc/cron.d/` `/etc/crontab` `crontab -l -u root` `systemctl list-timers`
`grep -r PATTERN /etc/cron* /etc/systemd/system` `find / -newer FILE` `journalctl -u cron`

## Done when

`lab check a03` passes. (It waits a few seconds to make sure nothing respawns.)

## Explore (not graded)

- Real kernel threads: `ps -eo pid,ppid,comm | awk '$2 == 2' | head`. Their PPID is 2
  (kthreadd), `ps` shows them in `[brackets]`, and `/proc/PID/exe` is empty. Disguised malware
  often borrows their names.
- List every place something can be auto-started on a Linux box: cron (system, user, anacron),
  systemd units and timers, `/etc/rc.local`, `/etc/profile.d`, `~/.bashrc`, `at` jobs,
  udev rules, `LD_PRELOAD`... How would you audit them quickly?
- In a real compromise you would **preserve evidence** (copy the binaries, `ps` output, `/proc/PID/`)
  before deleting. Try `cp /proc/PID/exe /tmp/evidence.bin` before you kill.
