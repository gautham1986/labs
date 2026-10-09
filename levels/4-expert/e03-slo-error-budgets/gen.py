#!/usr/bin/env python3
"""e03 generator: 30 days of per-minute request/error/latency aggregates."""
import math, random, sys
from datetime import datetime, timedelta, timezone

seed, out = int(sys.argv[1]), sys.argv[2]
r = random.Random(seed)
minutes = 30 * 24 * 60
start = datetime(2026, 9, 1, tzinfo=timezone.utc)
# incidents: (start_minute, duration, error_rate, latency_ms)
incidents = [(r.randint(2000, minutes - 5000), r.randint(20, 90), r.uniform(0.05, 0.3), r.randint(400, 2000))
             for _ in range(r.randint(2, 4))]
paging_now = r.random() < 0.5
if paging_now:   # an incident that is still going on at the end of the window
    incidents.append((minutes - r.randint(25, 50), 60, r.uniform(0.03, 0.2), r.randint(300, 900)))
else:            # something noisy but small
    incidents.append((minutes - r.randint(200, 400), 15, 0.012, 280))

with open(f"{out}/requests-30d.csv", "w") as f:
    f.write("minute,total,errors,p99_ms\n")
    for m in range(minutes):
        t = start + timedelta(minutes=m)
        diurnal = 1 + 0.6 * math.sin((t.hour + t.minute / 60 - 9) / 24 * 2 * math.pi)
        total = max(50, int(r.gauss(900, 60) * diurnal))
        err_rate, p99 = 0.0002, int(r.gauss(170, 30))
        for s, d, er, lat in incidents:
            if s <= m < s + d:
                err_rate, p99 = er, lat + r.randint(-50, 50)
        errors = sum(1 for _ in range(total) if r.random() < err_rate) if err_rate > 0.001 else (1 if r.random() < total * err_rate else 0)
        f.write(f"{t:%Y-%m-%dT%H:%M},{total},{errors},{max(20, p99)}\n")
