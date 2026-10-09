# s11 · JSON in shell scripts with jq

**Track:** Shell scripting · **Level:** Advanced · **File:** `svc-report.sh`

Every API, every cloud CLI (`aws`, `gcloud`, `kubectl -o json`) speaks JSON. `jq` is how the
shell speaks it back.

## Spec

```
svc-report.sh [-s STATUS] FILE
```
`FILE` looks like `fixtures/services.json`. Print a **tab-separated** report, sorted by name:

```
NAME	STATUS	REPLICAS	VERSION
api	running	3	1.4.2
cron	stopped	0	0.9.9
search	running	2	-
web	running	4	2.3.1
worker	degraded	1	1.4.0
total: 5 services, 3 running, 10 replicas
```
- Missing `replicas` counts as `0`; missing `version` prints `-`.
- `-s STATUS` shows only services with that status; the `total:` line describes what's shown.
- Missing file or **invalid JSON** -> error on stderr, exit **1**. No FILE / bad option -> exit **2**.

## Concepts

`jq -r` · `.services[]` · `select()` · `sort_by(.name)` · `//` (alternative operator for defaults)
· `@tsv` · `--arg` (never paste shell variables into jq programs!) · `jq -e` / `jq empty` to validate
· `length`, `map`, `add`
