# s12 · Capstone: a parallel health checker

**Track:** Shell scripting · **Level:** Expert · **File:** `healthcheck.sh`

Put it all together: parse a config file, run checks **concurrently** with timeouts, collect
results in order, print text or JSON, and return a meaningful exit code - the kind of tool you'd
drop into cron, a CI smoke test or a deploy pipeline.

## Spec

```
healthcheck.sh [-t SECONDS] [-j] FILE
```
`FILE` has one check per line; blank lines and `#` comments are ignored:
```
# type  target
http    http://127.0.0.1:8080/health
tcp     db.internal:5432
```
- `http URL` passes if the URL answers with an HTTP **2xx or 3xx** status.
- `tcp HOST:PORT` passes if a TCP connection can be opened.
- Any other type fails with reason `unknown check type`.
- Each check has a timeout of `-t` seconds (default **3**, positive integer).
- All checks run **in parallel**: 10 checks that each time out after 3 s take ~3 s, not 30 s.
- Output, **in the order of the file**, one line per check:
  `OK   http http://127.0.0.1:8080/health` or `FAIL tcp db.internal:5432 (REASON)`
- `-j`: instead print a JSON array, in file order: `[{"type":"http","target":"...","ok":true}, ...]`
- Exit **0** if everything passed, **1** if anything failed, **2** on usage errors
  (no file, unreadable file, bad `-t`, unknown option).

## Concepts

background jobs `&` + `wait` · one temp file per job, read back in order · `timeout`
· `curl -s -o /dev/null -w '%{http_code}' -m T` · bash `/dev/tcp/HOST/PORT` (or `nc -z -w`)
· `jq -n` / `jq -s` to build JSON safely · `trap` to clean up temp files
