# a08 · Solution

```bash
sudo tee /usr/local/bin/snapshot-backup > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
# snapshot-backup - hard-linked rsync snapshots with a checksum manifest and retention
set -euo pipefail

SRC=${SRC:-/srv/a08/data}
DEST_ROOT=${DEST_ROOT:-/backup/a08}
KEEP=${KEEP:-5}

log() { printf '%s snapshot-backup: %s\n' "$(date '+%F %T')" "$*"; }

mkdir -p "$DEST_ROOT"
stamp=$(date +%Y-%m-%d_%H%M%S)
dest="$DEST_ROOT/$stamp"
[[ -e "$dest" ]] && { log "snapshot $dest already exists"; exit 1; }

link_opt=()
[[ -d "$DEST_ROOT/latest" ]] && link_opt=(--link-dest="$DEST_ROOT/latest")

# copy into a temp dir first so a failed run never looks like a good snapshot
rsync -a --delete "${link_opt[@]}" "$SRC/" "$dest.partial/"
(cd "$dest.partial" && find . -type f -print0 | sort -z | xargs -0 -r sha256sum) > "$dest.sums"
mv "$dest.sums" "$dest.partial/SHA256SUMS"
mv "$dest.partial" "$dest"
ln -sfn "$dest" "$DEST_ROOT/latest"
log "created $dest"

# retention: keep the newest $KEEP snapshots
find "$DEST_ROOT" -mindepth 1 -maxdepth 1 -type d -name '20*' ! -name '*.partial' | sort | head -n "-$KEEP" |
  while IFS= read -r old; do rm -rf -- "$old"; log "pruned $old"; done
SCRIPT
sudo chmod 755 /usr/local/bin/snapshot-backup
shellcheck /usr/local/bin/snapshot-backup

sudo snapshot-backup
sleep 1
sudo touch /srv/a08/data/README.txt
sudo snapshot-backup
sudo stat -c '%i %h %n' /backup/a08/20*/config/app.yaml     # same inode = hard-linked

sudo a08-disaster
ls -la /srv/a08/data

# restore exactly (delete extras, keep modes/owners/links), without the manifest
sudo rsync -a --delete --exclude SHA256SUMS /backup/a08/latest/ /srv/a08/data/
cd /srv/a08/data && sudo sha256sum --quiet -c /backup/a08/latest/SHA256SUMS && echo "restore verified"
```

## Why

- `--link-dest` gives "full" snapshots for the price of incremental ones: unchanged files are hard
  links to the previous snapshot's inodes.
- Writing to `*.partial` then renaming means `latest` never points at a half-finished copy.
- The manifest lets you verify a restore independently of the tool that made the backup.
- `--delete` on restore removes files the attacker/bug added (like a ransom note).
