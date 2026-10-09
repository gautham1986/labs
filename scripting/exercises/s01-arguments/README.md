# s01 · Arguments, output streams & exit codes

**Track:** Shell scripting · **Level:** Beginner · **File:** `greet.sh`

Every script is a tiny program with an interface: arguments in, text on **stdout**, errors on
**stderr**, and an **exit code** that other programs (cron, CI, `&&`) act on.

## Spec

```
greet.sh [--shout] NAME...
```

| call | stdout | stderr | exit |
|---|---|---|---|
| `greet.sh Ada` | `Hello, Ada!` | | 0 |
| `greet.sh Ada Linus` | `Hello, Ada!` and `Hello, Linus!` (one per line) | | 0 |
| `greet.sh --shout Ada` | `HELLO, ADA!` | | 0 |
| `greet.sh "Grace Hopper"` | `Hello, Grace Hopper!` (one name, with a space) | | 0 |
| `greet.sh` | *(nothing)* | a line starting with `usage:` | **2** |
| `greet.sh --shout` | *(nothing)* | a line starting with `usage:` | **2** |

## Concepts

`$1` `$@` vs `$*` (and why quotes matter) `$#` `shift` `for name in "$@"` `${var^^}`
`echo ... >&2` `exit N` `[[ ... ]]` `set -euo pipefail` · Convention: exit 2 = usage error.

## Workflow

```
lab start s01                  # copies the starter to workspace/scripting/s01/greet.sh
$EDITOR workspace/scripting/s01/greet.sh
lab check s01                  # runs the tests (and shellcheck)
```
