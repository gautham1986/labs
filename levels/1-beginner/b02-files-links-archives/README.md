# b02 · Files, links & archives

**Level:** Beginner · **Time:** ~25 min · **Needs:** any Linux

## Scenario

You're preparing a release of a small app that lives in `/opt/lab/b02`. Deploy tooling
expects a `current` symlink, ops wants a backup tarball, and a vendor just sent you a
compressed bundle.

```
/opt/lab/b02/
├── release-1.4.2/      # the app release
├── config/app.conf
└── incoming/bundle.tar.xz
```

## Tasks

1. Create a **symbolic link** `/opt/lab/b02/current` pointing to `release-1.4.2`.
2. Create a **hard link** `/opt/lab/b02/config/app.conf.hard` to `config/app.conf`.
3. Create a gzip-compressed tarball `/opt/lab/b02/backup/release.tar.gz` that contains the
   `release-1.4.2/` directory (paths inside the archive must start with `release-1.4.2/`,
   not `/opt/...`).
4. Extract `incoming/bundle.tar.xz` into `/opt/lab/b02/extracted/`.
5. Copy `release-1.4.2` to `release-1.4.3` **preserving permissions and timestamps**.
6. Write the **file type** of `/opt/lab/b02/release-1.4.2/bin/app` as reported by
   `file -b` (first word only, e.g. `ASCII` or `ELF`) to `~/answers/b02-filetype.txt`.

## Commands to learn

`ln -s` `ln` `ls -li` (inode numbers) `readlink -f` `stat` `cp -a` `mv` `rm -i`
`tar -czf / -xJf / -tzf / -C` `gzip` `xz` `file` `sha256sum`

## Done when

`lab check b02` passes.

## Explore (not graded)

- Delete `config/app.conf`. Is the hard link still readable? Is a symlink to it? Why?
- Run `ls -li config/`. What do the inode numbers and the link count column tell you?
- What happens to `current` if you `mv release-1.4.2 release-old`? This is why deploy tools
  switch symlinks instead of moving directories.
- Compare sizes: `tar -czf`, `tar -cjf`, `tar -cJf`. Time them with `time`.
