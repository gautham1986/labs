# s07 · Text-processing pipelines in scripts

**Track:** Shell scripting · **Level:** Intermediate · **File:** `log-summary.sh`

## Spec

```
log-summary.sh FILE...
```
Summarise nginx "combined" access logs. Accept **one or more** files; files ending in `.gz`
are read compressed (rotated logs!). Print **exactly** this format:

```
$ log-summary.sh fixtures/access.log fixtures/access.log.2.gz
requests: 9
unique_ips: 5
status_2xx: 6
status_3xx: 1
status_4xx: 1
status_5xx: 1
bytes: 5100
top_paths:
  3 /
  3 /api
  2 /login
```
(`top_paths`: the 3 most requested paths, count first, ties alphabetical.)

No files given -> usage, exit **2**. A file that doesn't exist -> error on stderr, exit **1**.

## Concepts

`zcat -f` (reads plain and gzip) · `awk` with multiple counters and `END{}` · `printf` for exact
formats · process substitution · don't parse the same file 6 times when one `awk` pass will do
