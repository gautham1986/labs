# Bash cheatsheet

```bash
#!/usr/bin/env bash
set -euo pipefail            # exit on error, unset var = error, pipe fails if any part fails
```

## Variables & expansion
```bash
name="world"; echo "hello $name"         # ALWAYS quote expansions
echo "${name:-default}"                   # default if unset/empty
: "${REQUIRED:?must be set}"              # fail if unset
${#s}            length                   ${s^^} ${s,,}   upper / lower
${path##*/}      basename                 ${path%/*}      dirname
${file%.*}       strip last extension     ${file##*.}     extension
${s/old/new}     replace first            ${s//old/new}   replace all
${s:0:5}         substring
```

## Arrays
```bash
arr=(a "b c" d); echo "${arr[1]}"; echo "${#arr[@]}"; for x in "${arr[@]}"; do ...; done
arr+=(e)                                   # append
declare -A m=([k]=v); m[x]=1; echo "${!m[@]}"     # associative: keys
mapfile -t lines < file                    # file -> array, one line per element
```

## Conditions
```bash
[[ -f f ]] [[ -d d ]] [[ -L l ]] [[ -x f ]] [[ -s f ]] [[ -e p ]] [[ f1 -nt f2 ]]
[[ -z $s ]] [[ -n $s ]] [[ $a == "$b" ]] [[ $a == pre* ]] [[ $s =~ ^[0-9]+$ ]] && echo "${BASH_REMATCH[0]}"
(( n > 5 )) (( n == 0 ))                   # arithmetic
cmd && echo ok || echo fail                # careful: runs 'fail' if echo ok fails too
case "$x" in start|go) ... ;; stop) ... ;; *) ... ;; esac
```

## Loops
```bash
for f in *.log; do [[ -e $f ]] || continue; ...; done          # globs, not $(ls)
for ((i = 0; i < 10; i++)); do ...; done
while IFS= read -r line; do ...; done < file                  # line by line, safely
find . -type f -print0 | while IFS= read -r -d '' f; do ...; done   # any filename
while read -r a b _; do ...; done < <(cmd)                    # keeps variables (no subshell)
```

## Functions
```bash
die() { echo "error: $*" >&2; exit 1; }
f() { local x=$1; ...; return 0; }         # return = status 0-255; output via echo
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi   # run only when executed
```

## I/O & redirection
```bash
cmd > out 2> err      cmd &> both      cmd >> append      cmd 2>/dev/null
cmd 2>&1 | tee log    echo "msg" >&2   cmd < in           cmd <<< "here string"
cat <<'EOF'           # quoted delimiter = no expansion inside
diff <(sort a) <(sort b)                   # process substitution
exec > >(tee -a /var/log/x.log) 2>&1       # log everything from here on
```

## Options
```bash
while getopts ':o:vh' opt; do
  case $opt in o) out=$OPTARG ;; v) verbose=1 ;; h) usage; exit 0 ;; *) usage >&2; exit 2 ;; esac
done; shift $((OPTIND - 1))
```

## Traps, signals, jobs
```bash
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
trap 'echo "failed at line $LINENO" >&2' ERR
trap 'exit 130' INT; trap 'exit 143' TERM
cmd & pid=$!; wait "$pid"; rc=$?            # background + wait
for h in a b c; do check "$h" > "$tmp/$h" & done; wait   # parallel fan-out
timeout 5 cmd                                # bound the runtime
flock -n /run/x.lock cmd                     # single instance
```

## Debugging
```bash
bash -n script.sh      # syntax check
bash -x script.sh      # trace;  PS4='+${BASH_SOURCE}:${LINENO}: ' for line numbers
shellcheck script.sh   # lint - fix everything it says
```

## Classic pitfalls
- `for f in $(ls)` - breaks on spaces. Use globs or `find -print0`.
- `cat file | while read ...; do count++; done` - the loop runs in a subshell; `count` is lost.
- `cd dir; rm -rf *` - if `cd` fails you delete the wrong thing. Use `cd dir || exit`.
- `[ $x = y ]` with empty `$x` - syntax error. Use `[[ ]]` and quotes.
- `local x=$(cmd)` hides `cmd`'s exit status. Declare and assign separately.
- `set -e` doesn't trigger inside `if`, `&&`, `||` or a function called from them.
