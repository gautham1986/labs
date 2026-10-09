# b06 · Solution

```bash
# 1. CPU hog
ps -eo pid,ppid,ni,pcpu,stat,comm --sort=-pcpu | head -5
echo cpu-burner > ~/answers/b06-hog.txt
sudo pkill -x cpu-burner          # SIGTERM first; -9 only if it ignores TERM

# 2. renice a running process
sudo renice -n 15 -p "$(pgrep -x report-gen)"
ps -o pid,ni,comm -p "$(pgrep -x report-gen)"

# 3. zombie: find its parent and end the parent
ps -eo pid,ppid,stat,comm | awk '$3 ~ /^Z/'
ps -eo ppid=,stat=,comm= | awk '$2 ~ /^Z/ && $3 == "sleep" {print $1}' > ~/answers/b06-zparent.txt
sudo kill "$(cat ~/answers/b06-zparent.txt)"

# 4. reload via SIGHUP
sudo pkill -HUP -x config-watcher
sleep 2; tail -2 /var/log/b06-config-watcher.log
```

## Why

- `SIGTERM` (15) asks a process to exit cleanly; `SIGKILL` (9) can't be caught and skips cleanup.
- Niceness ranges from -20 (greedy) to 19 (polite). It only matters when the CPU is contended.
- A zombie holds only a PID-table slot. Thousands of them = a buggy parent that never calls
  `wait()`. The fix is always the parent.
- `SIGHUP` -> "reload config" is a Unix convention used by nginx, sshd, rsyslog, haproxy...
