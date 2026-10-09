# a08 · Backups you can actually restore

**Level:** Advanced · **Time:** ~60 min · **Needs:** rsync, root

## Scenario

`/srv/a08/data` holds an app's files (owned by `appuser`, with a private key, a symlink and
file names with spaces). There are no backups. Build a snapshot backup script, prove it works,
then survive a simulated disaster.

## Tasks

1. Write `/usr/local/bin/snapshot-backup` (bash, executable) that:
   - copies `/srv/a08/data/` into a new snapshot directory `/backup/a08/YYYY-MM-DD_HHMMSS/`
     preserving permissions, ownership, timestamps and symlinks;
   - **hard-links unchanged files** to the previous snapshot (`rsync --link-dest`), so each
     snapshot looks complete but only changed files use new space;
   - writes a `SHA256SUMS` manifest inside the snapshot (relative paths, verifiable with
     `cd SNAPSHOT && sha256sum -c SHA256SUMS`) - don't checksum the manifest itself;
   - points the symlink `/backup/a08/latest` at the new snapshot;
   - keeps only the **5 newest** snapshots;
   - uses `set -euo pipefail` and passes `shellcheck`.
2. Run it **at least twice** (change a file in between if you like).
3. Simulate the disaster: `sudo a08-disaster`.
4. **Restore** `/srv/a08/data` from the latest snapshot so it's *exactly* as before: content,
   modes, ownership, symlinks - and nothing extra.

## Commands to learn

`rsync -aHAX --delete --link-dest=DIR` `rsync -n` (dry run) `--itemize-changes` `cp -al`
`ln -sfn` `sha256sum` / `sha256sum -c` `find -printf` `stat -c '%i %h %n'` (inode, link count)
`du -sh` (counts hard links once) `ls -1d | sort | head -n -5` `date +%F_%H%M%S` `shellcheck`

## Done when

`lab check a08` passes. The checker also runs your script several more times to test retention.

## Explore (not graded)

- `du -sh /backup/a08/*` vs `du -sh /backup/a08` - why don't the numbers add up?
- A backup on the same disk isn't a backup. Push snapshots to another host (`make fleet`, then
  `rsync -e ssh` to node1), or look at `restic`/`borg` for encryption + dedup.
- **3-2-1 rule**: 3 copies, 2 media, 1 off-site. And: an untested backup is a rumor.
- Schedule your script with the timer skills from i03 and alert if the newest snapshot is >25h old.
