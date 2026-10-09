Symlink syntax is `ln -s TARGET LINK_NAME` - target first, like `cp`.
Relative targets are resolved from the link's directory, so from anywhere:
`ln -s release-1.4.2 /opt/lab/b02/current` works.
---
A hard link is the same command without `-s`. `ls -li` shows both names share one inode.
---
`tar -C DIR` changes into DIR before archiving, so the paths inside the archive are relative:
`tar -czf /opt/lab/b02/backup/release.tar.gz -C /opt/lab/b02 release-1.4.2`
(you may need to `mkdir` the backup dir first). Verify with `tar -tzf`.
---
`.tar.xz` is xz-compressed: `tar -xJf FILE -C DEST`. GNU tar also auto-detects with plain `-xf`.
The destination directory must exist.
---
`cp -a` = archive mode: recursive, preserves permissions, ownership, timestamps and links.
