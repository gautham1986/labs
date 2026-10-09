# s04 · Loops over files (safely)

**Track:** Shell scripting · **Level:** Intermediate · **File:** `extcount.sh`

## Spec

```
extcount.sh DIR
```
Count the **regular files** under `DIR` (recursively) by **extension** and print `COUNT EXT`
lines, sorted by count (highest first), then by extension (A-Z) for ties.

- The extension is the part of the file name after the **last** dot, **lower-cased**
  (`photo.JPG` -> `jpg`, `archive.tar.gz` -> `gz`).
- Files with no dot, or whose only dot is the first character (`.bashrc`, `Makefile`), count as `(none)`.
- File names may contain **spaces** and even **newlines**. Your script must not break.
- `DIR` missing or not a directory: message on stderr, exit **2**.

Example:
```
$ extcount.sh ~/project
12 py
3 md
2 (none)
1 gz
```

## Concepts

`find -type f -print0` + `while IFS= read -r -d '' f` · parameter expansion `${f##*/}` `${name##*.}`
`${x,,}` · associative arrays `declare -A` · `sort -k1,1nr -k2,2` · why `for f in $(ls)` is a bug
