`ps -eo pid,ppid,pcpu,comm,args --sort=-pcpu | head`. Look at the full path in `args` and at
`ls -l /proc/<PID>/exe`. Real kernel threads have no executable and show up as `[kworker/...]`.
---
Note the burner's **PPID**, then look that process up: `ps -o pid,ppid,comm,args -p <PPID>`
or `pstree -aps <PID>`. Kill order matters: respawner first, then the burner.
---
If the respawner comes back too, something starts it on a schedule. cron is the usual suspect:
`ls -la /etc/cron.d/ && grep -r '.cache' /etc/cron* 2>/dev/null`. Names can look legit.
---
Clean up everything: the cron file, the processes, and the directory both binaries live in.
`journalctl -u cron` shows what cron has been running.
