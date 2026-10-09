# b01 · Solution

```bash
# 1. Hidden file - find walks the whole tree; -name matches dotfiles too
find /opt/lab/b01/maze -name .treasure
grep -h '^SECRET=' "$(find /opt/lab/b01/maze -name .treasure)" | cut -d= -f2 > ~/answers/b01-secret.txt

# 2. Count regular files ending in .log (-type f skips the directory called archive.log)
find /opt/lab/b01/maze -type f -name '*.log' | wc -l > ~/answers/b01-logcount.txt

# 3. Largest file: print "size path", sort numerically, keep the last line, drop the size
find /opt/lab/b01/maze -type f -printf '%s %p\n' | sort -n | tail -1 | cut -d' ' -f2- > ~/answers/b01-largest.txt

# 4. Brace expansion creates all four directories in one go
mkdir -p ~/projects/webapp/{src,tests,docs,config}
touch ~/projects/webapp/README.md
```

## Why

- `find` is the tool for "somewhere under this directory". `ls -R | grep` breaks on file names
  with spaces, can't tell files from directories, and matches `.log` anywhere in the name.
- `-printf '%s %p\n'` prints the size in bytes and the path. `sort -n` sorts numbers properly
  (plain `sort` would put `9` after `10`).
- `cut -d' ' -f2-` keeps everything from field 2 on, so paths with spaces survive.
- `mkdir -p` creates parent directories and doesn't complain if they already exist, which is
  what you want in scripts.
