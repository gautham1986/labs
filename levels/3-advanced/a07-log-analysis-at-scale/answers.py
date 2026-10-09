#!/usr/bin/env python3
"""a07 reference answers (used by check.sh). Prints key=value lines."""
import json, math, sys
from collections import Counter

total = Counter(); err = Counter(); per_min = Counter(); c429 = Counter()
lat = []; n5xx = 0; malformed = 0
for line in open(sys.argv[1]):
    try:
        r = json.loads(line)
    except ValueError:
        malformed += 1
        continue
    s = r["status"]; total[r["path"]] += 1
    if 500 <= s <= 599:
        n5xx += 1; err[r["path"]] += 1; per_min[r["ts"][:16]] += 1
    if s == 429:
        c429[r["client_ip"]] += 1
    if r["path"] == "/api/checkout":
        lat.append(r["latency_ms"])
lat.sort()
worst = max((p for p in total if total[p] >= 1000), key=lambda p: err[p] / total[p])
print(f"5xx={n5xx}")
print(f"malformed={malformed}")
print(f"worst-endpoint={worst}")
print(f"p95={lat[math.ceil(0.95 * len(lat)) - 1]}")
print(f"spike-minute={per_min.most_common(1)[0][0]}")
print(f"top429={c429.most_common(1)[0][0]}")
