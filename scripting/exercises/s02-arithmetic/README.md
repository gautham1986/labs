# s02 · Arithmetic, `case` & input validation

**Track:** Shell scripting · **Level:** Beginner · **File:** `calc.sh`

## Spec

```
calc.sh A OP B
```
`A` and `B` are integers (may be negative). `OP` is one of `+ - x / %` (use `x` for
multiplication - an unquoted `*` would be expanded by the shell into file names!).

| call | stdout | stderr | exit |
|---|---|---|---|
| `calc.sh 3 + 4` | `7` | | 0 |
| `calc.sh 10 - 25` | `-15` | | 0 |
| `calc.sh -6 x 7` | `-42` | | 0 |
| `calc.sh 17 / 5` | `3` (integer division) | | 0 |
| `calc.sh 17 % 5` | `2` | | 0 |
| `calc.sh 1 / 0` | | `error: division by zero` | **1** |
| `calc.sh 1 % 0` | | `error: division by zero` | **1** |
| `calc.sh 2.5 + 1` / `calc.sh a + 1` | | `error: ...` (not an integer) | **2** |
| `calc.sh 1 ^ 2` | | `error: ...` (unknown operator) | **2** |
| wrong number of arguments | | `usage: calc.sh A OP B` | **2** |

## Concepts

`$(( ))` arithmetic · `case "$op" in ...) ;; esac` · regex test `[[ $a =~ ^-?[0-9]+$ ]]`
· a `die()` helper · why `expr` and `let` are legacy
