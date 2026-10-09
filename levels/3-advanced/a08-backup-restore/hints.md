Core rsync call (note the trailing slash on the source = "contents of"):
`rsync -a --delete --link-dest=/backup/a08/latest /srv/a08/data/ "$dest/"`
On the very first run `latest` doesn't exist yet - rsync just warns and does a full copy,
but you can skip `--link-dest` when there's no previous snapshot.
---
Manifest with relative paths (written outside the tree first, so it doesn't checksum itself):
`(cd "$dest" && find . -type f -print0 | sort -z | xargs -0 sha256sum) > /tmp/sums && mv /tmp/sums "$dest/SHA256SUMS"`
---
Atomic-ish symlink switch: `ln -sfn "$dest" /backup/a08/latest`.
Retention: snapshot names sort chronologically, so
`ls -1d /backup/a08/20*/ | sort | head -n -5 | xargs -r rm -rf`.
---
Prove the hard links: `stat -c '%i %h %n' /backup/a08/*/config/app.yaml` - same inode, link count > 1.
---
Restore: `sudo rsync -a --delete /backup/a08/latest/ /srv/a08/data/` - then remove the
manifest that came along (`SHA256SUMS`) or exclude it with `--exclude SHA256SUMS`.
Verify with `cd /srv/a08/data && sha256sum -c /backup/a08/latest/SHA256SUMS`.
