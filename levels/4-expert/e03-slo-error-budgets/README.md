# e03 · SLOs, error budgets & burn-rate alerting

**Level:** Expert · **Time:** ~60 min · **Needs:** awk (or any tool you like)

## Scenario

Your team agreed on an SLO for the checkout API:

> **99.9% of requests succeed, measured over a rolling 30 days.**
> (Secondary: in 99% of minutes, p99 latency is below 300 ms.)

Product wants to ship a risky migration today. Are we allowed to? And should someone be paged
*right now*? You have 30 days of per-minute aggregates in `/opt/lab/e03/requests-30d.csv`:

```
minute,total,errors,p99_ms
2026-09-01T00:00,812,0,164
```

The **last row is "now"**.

## Tasks

Write `~/answers/e03.env` with these keys (shell `KEY=VALUE` format, one per line):

| key | meaning | format |
|---|---|---|
| `SLI_PERCENT` | availability over the 30 days: `(total - errors) / total × 100` | 3 decimals, e.g. `99.912` |
| `BUDGET_TOTAL` | error budget for the window, in requests: `floor(total × 0.001)` | integer |
| `BUDGET_REMAINING_PERCENT` | `(1 - errors / BUDGET_TOTAL) × 100` (negative = blown) | 1 decimal |
| `BURN_RATE_1H` | error rate over the **last 60 minutes** ÷ 0.001 | 2 decimals |
| `BURN_RATE_5M` | error rate over the **last 5 minutes** ÷ 0.001 | 2 decimals |
| `PAGE` | `yes` if **both** burn rates are above **14.4**, else `no` | `yes`/`no` |
| `LATENCY_SLI_PERCENT` | % of minutes with `p99_ms < 300` | 2 decimals |

Then answer for yourself: can the migration ship? Is the latency objective met?

## Concepts to learn

SLI vs SLO vs SLA · error budget · burn rate (1.0 = spending the budget exactly over the window)
· multi-window, multi-burn-rate alerts (14.4× over 1h ≈ 2% of a 30-day budget in an hour)
· why ratios of sums ≠ averages of ratios

Reading: Google SRE Workbook, chapter 5 "Alerting on SLOs".

## Done when

`lab check e03` passes.

## Explore (not graded)

- Why must the error rate be `sum(errors) / sum(total)` and not the average of per-minute rates?
  Compute both and compare.
- Write the Prometheus recording rules and the two-window alert (`1h` + `5m` at 14.4×,
  `6h` + `30m` at 6×) as YAML.
- Draft an error budget policy: what happens when the budget is exhausted? Who decides?
