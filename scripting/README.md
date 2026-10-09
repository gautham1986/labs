# Shell scripting track

Twelve exercises that take you from "I can write a for loop" to "I'd trust this script in a
deploy pipeline". Each one is a small, real tool with a precise spec and an automated test
suite - the same way you'd work on a team: **spec -> code -> tests green -> shellcheck clean**.

```
lab start s01        # copies the starter to workspace/scripting/s01/greet.sh
lab show s01         # the spec
$EDITOR workspace/scripting/s01/greet.sh
lab check s01        # runs the tests + shellcheck
lab hint s01         # (there are no hints here - read the spec and the failing test name)
lab solution s01     # a reference solution, once you're done (or truly stuck)
```

Debug a failing test with `TEST_DEBUG=1 lab check s01` - it shows each test's output. The test
code itself is in `scripting/exercises/sNN-*/test.sh`; reading it is allowed and encouraged.

## The exercises

| # | Tool you build | You'll learn |
|---|---|---|
| s01 | `greet.sh` | arguments, `"$@"`, stdout vs stderr, exit codes |
| s02 | `calc.sh` | arithmetic, `case`, validating input |
| s03 | `fileinfo.sh` | file tests, test order, accumulating status |
| s04 | `extcount.sh` | `find -print0`, safe loops, parameter expansion, associative arrays |
| s05 | `validate-ip.sh` | functions, `return` vs `exit`, regex, sourceable scripts |
| s06 | `wordfreq.sh` | reading stdin or files, associative arrays, sorting |
| s07 | `log-summary.sh` | awk pipelines, compressed logs, exact output formats |
| s08 | `backup.sh` | `getopts`, dry runs, retention, tar |
| s09 | `atomic-write.sh` | `trap`, signals, temp files, atomic `mv` |
| s10 | `retry.sh` | wrapping commands, exit codes, backoff, float math |
| s11 | `svc-report.sh` | JSON with `jq`, `--arg`, `@tsv`, defaults |
| s12 | `healthcheck.sh` | parallel jobs, timeouts, collecting results, JSON output (capstone) |

## House rules (the tests enforce most of them)

1. Start with `#!/usr/bin/env bash` and `set -euo pipefail` (s10/s12 deliberately drop `-e` - know why).
2. **Quote every expansion**: `"$var"`, `"$@"`, `"$(cmd)"`. Unquoted variables are the #1 bash bug.
3. Results to **stdout**, diagnostics to **stderr** (`>&2`).
4. Exit codes mean something: `0` ok, `1` failure, `2` usage error.
5. Clean up after yourself (`trap ... EXIT`), never leave temp files.
6. `shellcheck` must be clean. When it complains, read the wiki page it links - every one teaches something.
7. Prefer bash builtins (`${var##*/}`, `[[ ]]`, `$(( ))`) over spawning processes in loops.

## Reference material

- `scripting/templates/script-template.sh` - a production-grade skeleton (strict mode, logging,
  usage, getopts, dry-run, cleanup traps, `main` guard). Copy it for new scripts.
- `cheatsheets/bash.md` - syntax you'll look up constantly.
- `man bash` - sections *Parameter Expansion*, *Conditional Expressions*, *Shell Builtin Commands*.
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) ·
  [BashFAQ](https://mywiki.wooledge.org/BashFAQ) · [BashPitfalls](https://mywiki.wooledge.org/BashPitfalls)

## When to stop using bash

Bash is the right tool for gluing commands together. Reach for Python/Go when you need data
structures beyond flat arrays, real error handling, unit tests of logic, or more than ~200 lines.
Knowing where that line is *is* a senior skill.
