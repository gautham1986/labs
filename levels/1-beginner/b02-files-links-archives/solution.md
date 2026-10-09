# b02 · Solution

```bash
cd /opt/lab/b02

# 1. symlink: ln -s TARGET LINKNAME (relative target = portable if the tree moves)
ln -sfn release-1.4.2 current

# 2. hard link: a second name for the same inode
ln config/app.conf config/app.conf.hard
ls -li config/

# 3. tarball with relative paths (-C changes directory first)
mkdir -p backup
tar -czf backup/release.tar.gz -C /opt/lab/b02 release-1.4.2
tar -tzf backup/release.tar.gz | head

# 4. extract an xz tarball into a new directory
mkdir -p extracted
tar -xJf incoming/bundle.tar.xz -C extracted

# 5. archive copy keeps modes and timestamps
cp -a release-1.4.2 release-1.4.3

# 6. file type
file -b release-1.4.2/bin/app | awk '{print $1}' > ~/answers/b02-filetype.txt
```

## Why

- A **symlink** is a tiny file containing a path. A **hard link** is another directory entry for
  the same inode: delete the original name and the data is still there.
- `ln -sfn`: `-f` replaces an existing link, `-n` treats an existing symlink-to-directory as a file
  (otherwise you'd create a link *inside* the old target - a classic deploy bug).
- Absolute paths inside tarballs are a footgun: extracting them on another box puts files in
  unexpected places. `-C` keeps them relative.
- `cp -r` resets timestamps and may change modes; `cp -a` is what you want for backups and releases.
