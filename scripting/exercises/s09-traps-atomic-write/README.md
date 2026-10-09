# s09 · Error handling, traps & atomic writes

**Track:** Shell scripting · **Level:** Advanced · **File:** `atomic-write.sh`

Config management tools, deploy scripts and cron jobs constantly rewrite files that other
programs read. Writing in place means readers can see a half-written file - or an empty one
if the writer crashes. The fix: write a temp file **in the same directory**, then `mv` it over
the target (a `rename()` is atomic on the same filesystem).

## Spec

```
some-command | atomic-write.sh [-e] [-m MODE] TARGET
```
- Reads **all of stdin** and atomically replaces `TARGET` with it.
- The temp file lives in TARGET's directory and **never survives** - not on errors, not on
  `Ctrl-C` (SIGINT), not on `kill` (SIGTERM).
- If interrupted, `TARGET` is **unchanged** and the exit code is `128 + signal` (130 / 143).
- **Refuses to write empty content** (exit 1, target untouched) - unless `-e` is given.
- Mode: `-m MODE` (octal, e.g. `600`); default: keep the existing target's mode, or `644` for a new file.
- `TARGET`'s directory doesn't exist -> error, exit 1. No TARGET -> usage, exit 2.

## Concepts

`trap cleanup EXIT` · `trap '...' INT TERM` · `mktemp "$dir/.name.XXXXXX"` · `stat -c %a`
· why `mv` is atomic and `cp` isn't · *advanced:* `cat <&0 > "$tmp" & wait $!` so a signal is
handled immediately instead of after `cat` finishes (the `<&0` matters: in scripts, background
commands get `/dev/null` as stdin unless you say otherwise)
