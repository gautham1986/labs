# a07 · Log analysis at scale: jq, awk & friends

**Level:** Advanced · **Time:** ~60 min · **Needs:** jq, awk

## Scenario

Yesterday's postmortem needs numbers, and the metrics system was down during the incident.
All you have is one day of structured application logs - ~150,000 JSON lines in
`/opt/lab/a07/app.jsonl`:

```json
{"ts":"2026-09-14T13:05:22.123Z","level":"info","service":"shop-api","method":"GET","path":"/api/cart","status":200,"latency_ms":37,"client_ip":"10.1.2.3","trace_id":"9f2c..."}
```

A few lines got **truncated** when a disk filled up - they aren't valid JSON. Your tools must
survive them.

## Tasks

| # | Question | Answer file |
|---|---|---|
| 1 | How many lines are **malformed** (not valid JSON)? | `~/answers/a07-malformed.txt` |
| 2 | Total number of **5xx** responses (valid lines only) | `~/answers/a07-5xx.txt` |
| 3 | Among paths with **at least 1000 requests**, which has the **highest 5xx rate**? | `~/answers/a07-worst-endpoint.txt` |
| 4 | **p95 latency** (ms) of `/api/checkout`, nearest-rank method: sort ascending, take the value at position `ceil(0.95 × N)` (1-based) | `~/answers/a07-p95.txt` |
| 5 | The **minute** with the most 5xx responses, formatted `YYYY-MM-DDTHH:MM` | `~/answers/a07-spike-minute.txt` |
| 6 | The **client IP** that received the most **429** (rate-limited) responses | `~/answers/a07-top429.txt` |

Use shell tools (`jq`, `awk`, `sort`, `uniq`...). Python is cheating - but writing a reusable
**script** in `workspace/` that answers all six is encouraged.

## Commands to learn

`jq -c` `jq -r '.field'` `jq 'select(.status >= 500)'` `jq -R 'fromjson? // empty'` `jq -s`
`jq 'group_by(.path) | map({path: .[0].path, n: length})'` `awk -F'"status":' `
`sort -n` `sort -k2,2nr` `uniq -c` `wc -l` `cut -c1-16` `LC_ALL=C sort` `time`

## Done when

`lab check a07` passes.

## Explore (not graded)

- Time your pipelines with `time`. Compare `jq` per-line vs one `jq -s` (slurp) vs `awk` on the
  raw text. When does slurping 150k lines into memory become a problem?
- `LC_ALL=C sort` vs default locale sort - measure the difference.
- Build a per-minute error histogram and plot it in the terminal with `awk` (`printf "%s %s\n",
  minute, substr("##########...", 1, n/10)`).
- How would you do question 4 in a real system? (Hint: histograms in Prometheus, `histogram_quantile`.)
