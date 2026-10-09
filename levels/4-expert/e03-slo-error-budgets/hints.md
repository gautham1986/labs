Skip the header (`NR > 1`) and use `-F,`. Sums in awk:
`awk -F, 'NR > 1 {t += $2; e += $3} END {printf "%.3f\n", (t - e) / t * 100}' requests-30d.csv`
---
Budget: `int(t * 0.001)` in awk. Remaining: `(1 - e / budget) * 100` - it can go below zero.
---
"Last 60 minutes" = last 60 data rows: `tail -n 60 requests-30d.csv | awk -F, '...'`.
Burn rate = (errors / total) / 0.001 over those rows. Same for `tail -n 5`.
---
Latency SLI: count rows where `$4 < 300`, divide by the number of rows (excluding the header).
---
Format: plain `KEY=VALUE` lines, e.g.
```
SLI_PERCENT=99.912
PAGE=no
```
