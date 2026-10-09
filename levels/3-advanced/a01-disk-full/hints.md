Start broad, then drill down: `df -h /srv/a01`, then `sudo du -xh --max-depth=2 /srv/a01 | sort -h`.
`-x` stays on one filesystem. Big logs and caches are usual suspects - but data is off limits.
---
Add up what `du` reports and compare to `df`'s "Used". The gap is space held by files that were
deleted while a process still had them open. `sudo lsof +L1` (or `sudo lsof /srv/a01 | grep deleted`)
shows the process and its file descriptor number (`lsof +c 0` prints full command names).
---
To reclaim it: restart/kill the process, or truncate the open descriptor:
`sudo truncate -s 0 /proc/<PID>/fd/<FD>`
---
"No space left" with free space = out of **inodes**: `df -i /srv/a01-sessions`. Every file needs
one, no matter how small.
---
`find /srv/a01-sessions -type f -mtime +1` lists files older than 1 day. Check the list first,
then add `-delete`. (`+1` means "more than 1 full 24h period ago".)
