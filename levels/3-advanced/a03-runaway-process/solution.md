# a03 · Solution

```bash
# 1. who's burning CPU? Note the path: no real kernel thread lives in /usr/local/lib/.cache
ps -eo pid,ppid,pcpu,comm,args --sort=-pcpu | head -5
BURNER=$(ps -eo pid=,comm= --sort=-pcpu | awk 'NR == 1 {print $1}')
sudo ls -l /proc/$BURNER/exe
ps -o comm= -p "$BURNER" > ~/answers/a03-burner.txt

# 2. its parent respawns it
PARENT=$(ps -o ppid= -p "$BURNER" | tr -d ' ')
ps -o pid,ppid,comm,args -p "$PARENT"
ps -o comm= -p "$PARENT" > ~/answers/a03-parent.txt

# 3. what starts the parent? search the usual persistence spots for the path
sudo grep -rl '/usr/local/lib/.cache' /etc/cron* /etc/systemd/system /etc/rc.local 2>/dev/null || true
sudo grep -rl '/usr/local/lib/.cache' /etc/cron.d | head -1 > ~/answers/a03-persistence.txt

# 4. eradicate: persistence first, then respawner, then payload, then files
sudo rm -f "$(cat ~/answers/a03-persistence.txt)"
sudo kill "$PARENT"
sudo pkill -x kworker-u8 || true
sudo rm -rf /usr/local/lib/.cache
sleep 5; ps -eo pid,pcpu,comm --sort=-pcpu | head -3
```

## Why

- Order matters: kill the burner first and the watchdog restarts it; kill the watchdog but leave
  the cron entry and it's back within a minute.
- Names lie; paths, parents and `/proc/PID/exe` don't. Kernel threads have PPID 2 and no exe.
- The same "what restarts this?" thinking applies to legit software: systemd `Restart=`,
  supervisord, Kubernetes controllers... Killing a process managed by a supervisor never sticks.
