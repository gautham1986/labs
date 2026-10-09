# a01 · Disk full (and the two ways it lies to you)

**Level:** Advanced · **Time:** ~40 min · **Needs:** root (mounts small tmpfs volumes, nothing touches your real disk)

## Scenario

🚨 *PagerDuty: "disk usage > 95% on /srv/a01" and "app can't create sessions: No space left on
device" on `/srv/a01-sessions`.*

Two volumes, two different problems:

```
/srv/a01            64M volume: the app (logs, cache, and important data in app/data/)
/srv/a01-sessions   session store (one small file per user session)
```

## Tasks

1. Bring **/srv/a01** under **50%** usage. Do **not** touch anything in `/srv/a01/app/data/`.
2. You'll notice `df` and `du` disagree about how much space is used on `/srv/a01`. Find the
   **process** holding space via a deleted file, write its **process name** to
   `~/answers/a01-holder.txt`, and get that space back.
3. `/srv/a01-sessions` has free *space* but nothing can be written. Fix it by deleting session
   files **older than 1 day** - sessions newer than that belong to logged-in users and must stay.

## Commands to learn

`df -h` `df -i` `du -xh --max-depth=1 | sort -h` `ncdu -x` `find -size +10M` `find -mtime +1`
`lsof +L1` `lsof /srv/a01` `ls -l /proc/PID/fd` `: > file` / `truncate -s 0` `findmnt`
`journalctl --vacuum-size`

## Done when

`lab check a01` passes. `lab clean a01` unmounts the volumes.

## Explore (not graded)

- Why does deleting a file that a process has open not free space? What's the link count of
  such a file? (`lsof +L1` lists files with link count < 1.)
- You can empty a deleted-but-open file without killing the process: `: > /proc/PID/fd/N`.
  When is that better than a restart?
- `rm huge.log` vs `: > huge.log` when a daemon is still writing to it - which frees space now?
- ext4 reserves 5% for root (`tune2fs -m`). Why can root sometimes write when users can't?
