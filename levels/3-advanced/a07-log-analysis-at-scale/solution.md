# a07 · Solution

```bash
cd /opt/lab/a07
# Parse once, drop malformed lines, keep only what we need as TSV (fast to re-read)
jq -cR 'fromjson? // empty' app.jsonl > /tmp/a07-valid.jsonl
echo $(( $(wc -l < app.jsonl) - $(wc -l < /tmp/a07-valid.jsonl) )) > ~/answers/a07-malformed.txt
jq -r '[.ts[0:16], .path, .status, .latency_ms, .client_ip] | @tsv' /tmp/a07-valid.jsonl > /tmp/a07.tsv

# 2. 5xx count
awk -F'\t' '$3 >= 500 && $3 < 600' /tmp/a07.tsv | wc -l > ~/answers/a07-5xx.txt

# 3. highest 5xx rate among paths with >= 1000 requests
awk -F'\t' '{t[$2]++; if ($3 >= 500 && $3 < 600) e[$2]++}
            END {for (p in t) if (t[p] >= 1000) printf "%.6f %s\n", e[p] / t[p], p}' /tmp/a07.tsv |
  sort -rn | head -1 | cut -d' ' -f2 > ~/answers/a07-worst-endpoint.txt

# 4. p95 latency of /api/checkout (nearest rank)
awk -F'\t' '$2 == "/api/checkout" {print $4}' /tmp/a07.tsv | sort -n > /tmp/a07-lat.txt
N=$(wc -l < /tmp/a07-lat.txt)
awk -v n="$N" 'BEGIN {k = int(0.95 * n); if (k < 0.95 * n) k++} NR == k' /tmp/a07-lat.txt > ~/answers/a07-p95.txt

# 5. minute with most 5xx
awk -F'\t' '$3 >= 500 && $3 < 600 {print $1}' /tmp/a07.tsv | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > ~/answers/a07-spike-minute.txt

# 6. client with most 429s
awk -F'\t' '$3 == 429 {print $5}' /tmp/a07.tsv | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' > ~/answers/a07-top429.txt

head ~/answers/a07-*.txt
```

## Why

- Parse JSON once, project to TSV, then use awk/sort - jq is great for structure, awk for
  aggregation speed.
- `fromjson?` makes the pipeline tolerant of bad input instead of dying halfway through - real
  logs are always a bit broken.
- Rates beat counts: the busiest endpoint usually has the most errors, but not the worst ratio.
- Percentiles need the full distribution (or a histogram); averages hide the slow tail that
  users actually feel.
