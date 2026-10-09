# a01 · Solution

```bash
# 1. what's big?
df -h /srv/a01
sudo du -xh --max-depth=3 /srv/a01 | sort -h | tail
sudo find /srv/a01 -xdev -type f -size +1M -exec ls -lh {} + | sort -k5 -h

# logs and cache are safe to clear; data is not
sudo truncate -s 0 /srv/a01/app/logs/debug.log
sudo rm -f /srv/a01/app/logs/old/*.gz
sudo find /srv/a01/app/cache -type f -delete

# 2. the df/du gap: deleted-but-open files
sudo lsof +L1 2>/dev/null | grep /srv/a01 || true
PID=$(sudo find /proc/[0-9]*/fd -lname '/srv/a01/*(deleted)' 2>/dev/null | head -1 | cut -d/ -f3)
ps -o comm= -p "$PID" | tee ~/answers/a01-holder.txt
sudo kill "$PID"           # or: sudo truncate -s 0 /proc/$PID/fd/<FD> to keep it running
sleep 1; df -h /srv/a01

# 3. inode exhaustion
df -i /srv/a01-sessions
sudo find /srv/a01-sessions -type f -mtime +1 | head
sudo find /srv/a01-sessions -type f -mtime +1 -delete
df -i /srv/a01-sessions
```

## Why

- `du` walks directory entries; `df` asks the filesystem. A deleted file with an open handle has
  no directory entry but still has blocks, so only `df` sees it. Classic cause: someone `rm`s a
  log that a daemon is writing to.
- Truncate logs (`: > file`) instead of deleting them when a process may hold them open.
- Inodes are a separate, finite resource. Millions of tiny files (sessions, mail queues, caches)
  exhaust them long before blocks.
- In real life, follow up: log rotation, cache size limits, alerts on `df -i`, a session TTL.
