# s05 · Functions, return codes & sourceable scripts

**Track:** Shell scripting · **Level:** Intermediate · **File:** `validate-ip.sh`

## Spec

```
validate-ip.sh [-q] ADDR...
```
- For each address print `ADDR: valid` or `ADDR: invalid`.
- `-q` (quiet): print nothing, only set the exit code.
- Exit **0** if all are valid, **1** if any is invalid, **2** (usage on stderr) without addresses.

A valid IPv4 address has exactly **4** dot-separated decimal octets, each **0-255**, with
**no leading zeros** (`0` is fine, `01` is not), and nothing else (no spaces, no trailing dot).

**And:** the script must be **sourceable**. It defines a function `is_valid_ipv4 ADDR` that
returns 0/1, and only runs its main logic when executed - so other scripts can do:

```bash
source validate-ip.sh
is_valid_ipv4 "$ip" || die "bad ip"
```

## Concepts

functions & `local` · `return` vs `exit` (a function must never `exit` the caller's shell)
· `IFS=. read -r a b c d` · `[[ =~ ]]` with `BASH_REMATCH` · arithmetic comparisons
· the `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi` idiom
