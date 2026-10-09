# e03 · Solution

```bash
F=/opt/lab/e03/requests-30d.csv
burn() { awk -F, '{t += $2; e += $3} END {printf "%.2f", (e / t) / 0.001}'; }
{
  awk -F, 'NR > 1 {t += $2; e += $3}
           END {b = int(t * 0.001)
                printf "SLI_PERCENT=%.3f\n", (t - e) / t * 100
                printf "BUDGET_TOTAL=%d\n", b
                printf "BUDGET_REMAINING_PERCENT=%.1f\n", (1 - e / b) * 100}' "$F"
  b1=$(tail -n 60 "$F" | burn); b5=$(tail -n 5 "$F" | burn)
  echo "BURN_RATE_1H=$b1"
  echo "BURN_RATE_5M=$b5"
  if awk -v a="$b1" -v b="$b5" 'BEGIN {exit !(a > 14.4 && b > 14.4)}'; then echo PAGE=yes; else echo PAGE=no; fi
  awk -F, 'NR > 1 {n++; if ($4 < 300) g++} END {printf "LATENCY_SLI_PERCENT=%.2f\n", g / n * 100}' "$F"
} > ~/answers/e03.env
cat ~/answers/e03.env
```

## How to read it

- **Budget remaining > 0** -> you may spend it on risk (the migration), ideally with a canary.
  **≤ 0** -> freeze risky changes and spend the time on reliability, per your error budget policy.
- **Burn rate 1** means you'd use exactly 100% of the budget in 30 days. **14.4** sustained for an
  hour burns 2% of the monthly budget - worth waking someone up. Requiring the short (5m) window
  too makes the alert reset quickly once the problem is fixed.
- Latency SLI below 99% means the latency objective is missed even if availability is fine -
  users feel slowness as much as errors.
