#!/usr/bin/env python3
"""e03 reference answers: prints KEY=VALUE."""
import csv, sys
rows = list(csv.DictReader(open(sys.argv[1])))
tot = sum(int(r["total"]) for r in rows); err = sum(int(r["errors"]) for r in rows)
def burn(rs):
    t = sum(int(r["total"]) for r in rs); e = sum(int(r["errors"]) for r in rs)
    return (e / t) / 0.001
allowed = int(tot * 0.001)
b1, b5 = burn(rows[-60:]), burn(rows[-5:])
print(f"SLI_PERCENT={(tot - err) / tot * 100:.3f}")
print(f"BUDGET_TOTAL={allowed}")
print(f"BUDGET_REMAINING_PERCENT={(1 - err / allowed) * 100:.1f}")
print(f"BURN_RATE_1H={b1:.2f}")
print(f"BURN_RATE_5M={b5:.2f}")
print(f"PAGE={'yes' if b1 > 14.4 and b5 > 14.4 else 'no'}")
print(f"LATENCY_SLI_PERCENT={sum(1 for r in rows if int(r['p99_ms']) < 300) / len(rows) * 100:.2f}")
