# s03 · Conditionals & file tests

**Track:** Shell scripting · **Level:** Beginner · **File:** `fileinfo.sh`

## Spec

```
fileinfo.sh PATH...
```
For each path, print exactly one line, in order:

| path is... | output line |
|---|---|
| a symbolic link (check this **first** - even if broken) | `PATH: symlink -> TARGET` (target as stored in the link) |
| a directory | `PATH: directory` |
| a regular file that's executable | `PATH: executable file (N bytes)` |
| a regular file | `PATH: file (N bytes)` |
| anything else that exists (device, fifo...) | `PATH: other` |
| does not exist | `PATH: missing` |

Exit **0** if every path existed (a broken symlink counts as existing), **1** if any was missing,
**2** (with usage on stderr) if called without arguments.

## Concepts

`[[ -e -f -d -L -x -s -r -w ]]` · order of tests matters (`-f` follows symlinks!) · `readlink`
· `stat -c %s` or `wc -c <` · accumulate a status in a variable and `exit "$rc"` at the end
