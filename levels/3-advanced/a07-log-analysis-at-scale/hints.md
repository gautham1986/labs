`jq` stops at the first invalid line. Parse raw lines and drop failures:
`jq -R 'fromjson? // empty'`. Malformed count = total lines - valid lines.
`jq -cR 'fromjson? // empty' app.jsonl > /tmp/valid.jsonl` saves re-parsing later.
---
5xx: `jq 'select(.status >= 500 and .status < 600)' /tmp/valid.jsonl | ...` - or use `-c` and
`wc -l`. Faster: `jq -r 'select(.status >= 500) | .path'` and count with `sort | uniq -c`.
---
Error rate per path: count totals and errors per path, then divide. awk is great at this:
`jq -r '[.path, .status] | @tsv' valid.jsonl | awk '{t[$1]++; if ($2 >= 500) e[$1]++} END {for (p in t) if (t[p] >= 1000) print e[p]/t[p], p}' | sort -rn | head -1`
---
p95: extract checkout latencies, `sort -n`, count them (N), then pick line `ceil(0.95*N)`:
`awk -v n=$N 'BEGIN {k = int(0.95*n); if (k < 0.95*n) k++} NR == k'`
---
Per-minute: the first 16 characters of `ts` are `YYYY-MM-DDTHH:MM`: `.ts[0:16]` in jq.
Then `sort | uniq -c | sort -rn | head -1`.
