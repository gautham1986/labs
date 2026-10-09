# s10 · Wrapping commands: retries, backoff & exit codes

**Track:** Shell scripting · **Level:** Advanced · **File:** `retry.sh`

Networks blip, APIs return 503, package mirrors time out. A retry wrapper with backoff turns a
flaky step in a deploy pipeline into a reliable one - if it preserves arguments and exit codes
exactly.

## Spec

```
retry.sh [-n ATTEMPTS] [-d DELAY] [-b] [--] COMMAND [ARG...]
```
- Runs `COMMAND ARG...` until it succeeds, at most `ATTEMPTS` times (default **3**).
- Waits `DELAY` seconds between attempts (default **1**; fractions like `0.2` allowed).
- `-b` = exponential **backoff**: the delay doubles after each failure (0.1, 0.2, 0.4, ...).
- After each failed attempt that will be retried, print to **stderr**:
  `retry: attempt K/N failed (exit X), retrying in Ys`
- Exit status: **0** on success, otherwise the **exit code of the last attempt**.
- Arguments must reach the command **unchanged** (spaces, globs, empty strings).
- Usage errors (no command, `-n` not a positive integer, bad `-d`) -> exit **2**.
- Command's stdout/stderr pass through untouched.

## Concepts

`"$@"` (exactly once, correctly quoted) · capturing `$?` before anything overwrites it
· `getopts` and `--` · float math with `awk`/`bc` (bash only does integers) · `sleep 0.2`
